//
//  TBSMStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine.h"

@interface TBSMStateMachine ()
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, weak) id<TBSMNode> parentNode;
@property (nonatomic, strong) NSMutableDictionary *priv_states;
@property (nonatomic, strong) NSMutableArray *scheduledEventsQueue;
@property (nonatomic, strong) NSMutableArray *deferredEventsQueue;
@property (nonatomic, assign, getter = isHandlingEvent) BOOL handlesEvent;
@end

@implementation TBSMStateMachine

+ (TBSMStateMachine *)stateMachineWithName:(NSString *)name
{
    return [[TBSMStateMachine alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForStateException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
        _priv_states = [NSMutableDictionary new];
        _scheduledEventsQueue = [NSMutableArray new];
        _deferredEventsQueue = [NSMutableArray new];
        _handlesEvent = NO;
    }
    return self;
}

- (void)setUp:(NSDictionary *)data
{
    if (self.initialState) {
        [self enterState:nil targetState:self.initialState data:data];
    } else {
        @throw [NSException tb_noInitialStateException:@"initialState"];
    }
}

- (void)tearDown:(NSDictionary *)data
{
    [self exitState:self.currentState targetState:nil data:data];
    _currentState = nil;
    [self.priv_states removeAllObjects];
}

- (NSArray *)states
{
    return [NSArray arrayWithArray:self.priv_states.allValues];
}

- (void)setStates:(NSArray *)states
{
    [self.priv_states removeAllObjects];
    
    for (id object in states) {
        if ([object isKindOfClass:[TBSMState class]])  {
            TBSMState *state = object;
            [state setParentNode:self];
            [self.priv_states setObject:state forKey:state.name];
        } else {
            @throw ([NSException tb_notOfTypeStateException:object]);
        }
    }
    if (states.count > 0) {
        _initialState = states[0];
    }
}

- (void)setInitialState:(TBSMState *)initialState
{
    if ([self.priv_states objectForKey:initialState.name]) {
        _initialState = initialState;
    } else {
        @throw [NSException tb_nonExistingStateException:initialState.name];
    }
}

#pragma mark - handling events

- (void)scheduleEvent:(TBSMEvent *)event
{
    if (self.parentNode) {
        TBSMStateMachine *topStateMachine = [self.parentNode parentNode];
        [topStateMachine scheduleEvent:event];
        return;
    }
    
    @synchronized(self.scheduledEventsQueue) {
        
        [self.scheduledEventsQueue addObject:event];
        
        if (!self.isHandlingEvent) {
            self.handlesEvent = YES;
            while (self.scheduledEventsQueue.count > 0) {
                [self _handleNextEvent];
            }
            self.handlesEvent = NO;
        }
    }
}

- (BOOL)handleEvent:(TBSMEvent *)event
{
    if (_currentState) {
        if ([_currentState respondsToSelector:@selector(handleEvent:)]) {
            if ([_currentState performSelector:@selector(handleEvent:) withObject:event]) {
                return YES;
            }
        }
        NSArray *eventHandlers = [_currentState eventHandlersForEvent:event];
        for (TBSMEventHandler *eventHandler in eventHandlers) {
            TBSMTransition *transition = [TBSMTransition transitionWithSourceState:_currentState
                                                                  targetState:eventHandler.target
                                                                              kind:eventHandler.kind
                                                                            action:eventHandler.action
                                                                             guard:eventHandler.guard];
            if ([self _performTransition:transition withData:event.data]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)_handleNextEvent
{
    if (self.scheduledEventsQueue.count > 0) {
        
        TBSMEvent *queuedEvent = self.scheduledEventsQueue[0];
        [self.scheduledEventsQueue removeObject:queuedEvent];
        
        // Check wether the event is deferred by any state of the active state configuration.
        NSSet *compositeDeferralList = [self _compoundDeferralListForActiveStateConfiguration];
        
        BOOL isDeferred = NO;
        if ([compositeDeferralList containsObject:queuedEvent.name]) {
            isDeferred = YES;
            
            // If the event is deferred check wether higher prioritized states can consume the event.
            NSSet *activeLeafStates = [self _leafStatesForActiveStateConfiguration];
            for (TBSMState *activeLeafState in activeLeafStates) {
                if ([activeLeafState canHandleEvent:queuedEvent]) {
                    isDeferred = NO;
                    break;
                }
            }
        }
        
        if (isDeferred) {
            [self.deferredEventsQueue addObject:queuedEvent];
        } else {
            if ([self handleEvent:queuedEvent]) {
                
                // Since another state has been entered move all deferred events to the beginning of the event queue.
                [self.scheduledEventsQueue insertObjects:self.deferredEventsQueue
                                               atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.deferredEventsQueue.count)]];
                [self.deferredEventsQueue removeAllObjects];
            }
        }
    }
}

#pragma mark - state switching

- (void)_switchState:(TBSMTransition *)transition data:(NSDictionary *)data
{
    [_currentState exit:transition.sourceState targetState:transition.targetState data:data];
    if (transition.action) {
        transition.action(transition.sourceState, transition.targetState, data);
    }
    [self enterState:transition.sourceState targetState:transition.targetState data:data];
}

- (void)enterState:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    NSUInteger targetLevel = [[targetState.parentNode path] count];
    NSUInteger thisLevel = self.path.count;
    
    if (targetLevel < thisLevel) {
        _currentState = self.initialState;
    } else if (targetLevel == thisLevel) {
        _currentState = targetState;
    } else {
        NSArray *destinationPath = [targetState.parentNode path];
        id<TBSMNode> node = destinationPath[thisLevel];
        _currentState = node.parentNode;
    }
    [self.currentState enter:sourceState targetState:targetState data:data];
}

- (void)exitState:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    [self.currentState exit:sourceState targetState:targetState data:data];
}

- (BOOL)_performTransition:(TBSMTransition *)transition withData:(NSDictionary *)data
{
    if (transition.guard == nil || transition.guard(transition.sourceState, transition.targetState, data)) {
        if (transition.kind == TBSMTransitionInternal) {
            if (transition.action) {
                transition.action(transition.sourceState, transition.targetState, data);
            }
        } else {
            TBSMStateMachine *leastCommonAncestor = [self _findLeastCommonAncestorForTransition:transition];
            if (leastCommonAncestor) {
                [leastCommonAncestor _switchState:transition data:data];
            } else {
                NSLog(@"No transition possible for transition %@ via statemachine %@.", transition.name, self.name);
            }
        }
        return YES;
    }
    return NO;
}

- (TBSMStateMachine *)_findLeastCommonAncestorForTransition:(TBSMTransition *)transition
{
    NSArray *sourcePath = [transition.sourceState path];
    NSArray *destinationPath = [transition.targetState path];
    
    __block TBSMStateMachine *lca = nil;
    [sourcePath enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TBSMStateMachine class]]) {
            if ([destinationPath containsObject:obj]) {
                lca = (TBSMStateMachine *)obj;
                *stop = YES;
            }
        }
    }];
    return lca;
}

#pragma Helper methods

- (NSSet *)_compoundDeferralListForActiveStateConfiguration
{
    NSMutableSet *deferralList = NSMutableSet.new;
    [self _traverseActiveStatemachineConfiguration:self usingBlock:^void(TBSMState *currentState) {
        [deferralList unionSet:[NSSet setWithArray:currentState.deferredEvents.allKeys]];
    }];
    return deferralList;
}

- (NSSet *)_leafStatesForActiveStateConfiguration
{
    NSMutableSet *activeLeafStates = NSMutableSet.new;
    [self _traverseActiveStatemachineConfiguration:self usingBlock:^void(TBSMState *currentState) {
        if (!([currentState isKindOfClass:[TBSMSubState class]] || [currentState isKindOfClass:[TBSMParallelState class]])) {
            [activeLeafStates unionSet:[NSSet setWithObject:currentState]];
        }
    }];
    return activeLeafStates;
}

- (void)_traverseActiveStatemachineConfiguration:(TBSMStateMachine *)stateMachine usingBlock:(void(^)(TBSMState *currentState))block
{
    TBSMState *currentState = stateMachine.currentState;
    block(currentState);
    if ([currentState isKindOfClass:[TBSMSubState class]]) {
        TBSMSubState *subState = (TBSMSubState *)currentState;
        [self _traverseActiveStatemachineConfiguration:subState.stateMachine usingBlock:block];
    } else if ([currentState isKindOfClass:[TBSMParallelState class]]) {
        TBSMParallelState *parallelState = (TBSMParallelState *)currentState;
        for (TBSMStateMachine *stateMachine in parallelState.stateMachines) {
            [self _traverseActiveStatemachineConfiguration:stateMachine usingBlock:block];
        }
    }
}

#pragma mark - TBSMNode

- (NSArray *)path
{
    NSMutableArray *path = [NSMutableArray new];
    TBSMStateMachine *stateMachine = self;
    while (stateMachine) {
        [path insertObject:stateMachine atIndex:0];
        stateMachine = stateMachine.parentNode.parentNode;
    }
    return path;
}

@end
