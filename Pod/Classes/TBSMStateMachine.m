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
@property (nonatomic, weak) TBSMState *parentState;
@property (nonatomic, strong) NSMutableDictionary *priv_states;
@property (nonatomic, strong) NSMutableArray *scheduledEventsQueue;
@property (nonatomic, strong) NSMutableArray *deferredEventsQueue;
@property (nonatomic, assign, getter = isHandlingEvent) BOOL handlesEvent;

- (void)_handleNextEvent;
- (BOOL)_performTransition:(TBSMTransition *)transition withData:(NSDictionary *)data;
- (TBSMStateMachine *)_findLowestCommonAncestorForSourceState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState;
- (TBSMSubState *)_findNextNodeForState:(TBSMState *)state;
- (NSSet *)_compoundDeferralListForActiveStateConfiguration;
- (NSSet *)_leafStatesForActiveStateConfiguration;
- (void)_traverseActiveStatemachineConfiguration:(TBSMStateMachine *)stateMachine usingBlock:(void (^)(TBSMState *currentState))block;
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

- (void)setUp
{
    if (_initialState) {
        [self switchState:nil destinationState:_initialState data:nil action:nil];
    } else {
        @throw [NSException tb_noInitialStateException:@"initialState"];
    }
}

- (void)tearDown
{
    if (_currentState) {
        [self switchState:_currentState destinationState:nil data:nil action:nil];
    }
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
            [state setParentState:self];
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

- (void)scheduleEvent:(TBSMEvent *)event
{
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

- (void)switchState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data action:(TBSMActionBlock)action
{
    if (_currentState) {
        [_currentState exit:sourceState destinationState:destinationState data:data];
    }
    
    if (action) {
        action(sourceState, destinationState, data);
    }
    
    _currentState = [self _findNextNodeForState:destinationState];
    if (_currentState) {
        [_currentState enter:sourceState destinationState:destinationState data:data];
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
        TBSMTransition *transition = nil;
        transition = [_currentState transitionForEvent:event];
        if (transition) {
            return [self _performTransition:transition withData:event.data];
        }
    }
    return NO;
}

#pragma mark - private methods

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
                [self.scheduledEventsQueue insertObjects:self.deferredEventsQueue atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.deferredEventsQueue.count)]];
                [self.deferredEventsQueue removeAllObjects];
            }
        }
    }
}

- (BOOL)_performTransition:(TBSMTransition *)transition withData:(NSDictionary *)data
{
    if (transition.guard == nil || transition.guard(transition.sourceState, transition.destinationState, data)) {
        if (transition.destinationState) {
            TBSMStateMachine *lowestCommonAncestor = [self _findLowestCommonAncestorForSourceState:transition.sourceState destinationState:transition.destinationState];
            if (lowestCommonAncestor) {
                [lowestCommonAncestor switchState:_currentState destinationState:transition.destinationState data:data action:transition.action];
            } else {
                NSLog(@"No transition possible from source state %@ to destination state %@ via statemachine %@.", transition.sourceState.name, transition.destinationState.name, self.name);
            }
        } else {
            // Perform internal transition
            if (transition.action) {
                transition.action(transition.sourceState, transition.destinationState, data);
            }
        }
        return YES;
    }
    return NO;
}

- (TBSMStateMachine *)_findLowestCommonAncestorForSourceState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState
{
    NSArray *sourcePath = [sourceState path];
    NSArray *destinationPath = [destinationState path];
    
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

- (TBSMState *)_findNextNodeForState:(TBSMState *)state
{
    if (state == nil) {
        return nil;
    }
    
    // return destination state right away
    NSArray *path = [state path];
    if (self == [path lastObject]) {
        return state;
    }
    
    if (![path containsObject:self]) {
        return nil;
    }
    
    // return next state in path
    NSUInteger index = [path indexOfObject:self];
    return path[index + 1];
}

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
        if ([currentState isMemberOfClass:[TBSMState class]]) {
            [activeLeafStates unionSet:[NSSet setWithObject:currentState]];
        }
    }];
    return activeLeafStates;
}

- (void)_traverseActiveStatemachineConfiguration:(TBSMStateMachine *)stateMachine usingBlock:(void(^)(TBSMState *currentState))block
{
    TBSMState *currentState = stateMachine.currentState;
    block(currentState);
    if ([currentState isMemberOfClass:[TBSMSubState class]]) {
        TBSMSubState *subState = (TBSMSubState *)currentState;
        [self _traverseActiveStatemachineConfiguration:subState.stateMachine usingBlock:block];
    } else if ([currentState isMemberOfClass:[TBSMParallelState class]]) {
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
    TBSMState *state = self.parentState;
    while (state) {
        [path insertObject:state atIndex:0];
        state = state.parentState;
    }
    return path;
}

@end
