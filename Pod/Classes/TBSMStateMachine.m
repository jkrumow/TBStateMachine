//
//  TBSMStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine.h"

@interface TBSMStateMachine ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) TBSMState *parentState;
@property (nonatomic, strong) NSMutableDictionary *priv_states;
@property (nonatomic, strong) NSMutableArray *scheduledEventsQueue;
@property (nonatomic, strong) NSMutableArray *deferredEventsQueue;
@property (nonatomic, assign, getter = isProcessingEvent) BOOL processesEvent;

- (TBSMSubState *)_findNextNodeForState:(TBSMState *)state;
- (TBSMStateMachine *)_findLowestCommonAncestorForSourceState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState;
- (NSArray *)_findActiveLeafStatesInStateMachine:(TBSMStateMachine *)stateMachine;
- (TBSMTransition *)_handleEvent:(TBSMEvent *)event data:(NSDictionary *)data;
- (void)_handleNextEvent;

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
        _processesEvent = NO;
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
    [self scheduleEvent:event data:nil];
}

- (void)scheduleEvent:(TBSMEvent *)event data:(NSDictionary *)data
{
    @synchronized(self.scheduledEventsQueue) {
        
        NSDictionary *queuedEvent = nil;
        if (data) {
            queuedEvent = @{@"event" : event, @"data" : data};
        } else {
            queuedEvent = @{@"event" : event};
        }
        
        [self.scheduledEventsQueue addObject:queuedEvent];
        
        if (!self.isProcessingEvent) {
            while (self.scheduledEventsQueue.count > 0) {
                [self _handleNextEvent];
            }
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

#pragma mark - private methods

- (TBSMState *)_findNextNodeForState:(TBSMState *)state
{
    if (state == nil) {
        return nil;
    }
    
    // return destination state right away
    NSArray *path = [state getPath];
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

- (TBSMStateMachine *)_findLowestCommonAncestorForSourceState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState
{
    NSArray *sourcePath = [sourceState getPath];
    NSArray *destinationPath = [destinationState getPath];
    
    for (NSInteger i = sourcePath.count-1; i >= 0; i--) {
        TBSMState *state = sourcePath[i];
        if (![state isKindOfClass:[TBSMStateMachine class]]) {
            continue;
        }
        TBSMStateMachine *stateMachine = (TBSMStateMachine *)state;
        if ([destinationPath containsObject:stateMachine]) {
            return stateMachine;
        }
    }
    return nil;
}

- (NSArray *)_findActiveLeafStatesInStateMachine:(TBSMStateMachine *)stateMachine
{
    NSMutableArray *activeLeafStates = [NSMutableArray new];
    
    TBSMState *currentState = stateMachine.currentState;
    if ([currentState isMemberOfClass:[TBSMState class]]) {
        
        [activeLeafStates addObject:currentState];
        
    } else if ([currentState isMemberOfClass:[TBSMSubState class]]) {
        
        TBSMSubState *subState = (TBSMSubState *)currentState;
        NSArray *subLeafs = [self _findActiveLeafStatesInStateMachine:subState.stateMachine];
        [activeLeafStates addObjectsFromArray:subLeafs];
        
    } else if ([currentState isMemberOfClass:[TBSMParallelState class]]) {
        
        TBSMParallelState *parallelState = (TBSMParallelState *)currentState;
        for (TBSMStateMachine *stateMachine in parallelState.stateMachines) {
            NSArray *parallelLeafs = [self _findActiveLeafStatesInStateMachine:stateMachine];
            [activeLeafStates addObjectsFromArray:parallelLeafs];
        }
    }
    
    return activeLeafStates;
}

- (TBSMTransition *)_handleEvent:(TBSMEvent *)event data:(NSDictionary *)data
{
    TBSMTransition *transition;
    if (_currentState) {
        transition = [_currentState handleEvent:event data:data];
    }
    if (transition) {
        TBSMActionBlock action = transition.action;
        TBSMGuardBlock guard = transition.guard;
        if (guard == nil || guard(transition.sourceState, transition.destinationState, data)) {
            if (transition.destinationState) {
                TBSMStateMachine *lowestCommonAncestor = [self _findLowestCommonAncestorForSourceState:transition.sourceState destinationState:transition.destinationState];
                if (lowestCommonAncestor) {
                    [lowestCommonAncestor switchState:_currentState destinationState:transition.destinationState data:data action:action];
                } else {
                    NSLog(@"No transition possible from source state %@ to destination state %@ via statemachine %@.", transition.sourceState.name, transition.destinationState.name, self.name);
                }
            } else {
                // Perform internal transition
                if (action) {
                    action(transition.sourceState, transition.destinationState, data);
                }
            }
        }
    }
    return nil;
}

- (void)_handleNextEvent
{
    self.processesEvent = YES;
    
    if (self.scheduledEventsQueue.count > 0) {
        
        NSDictionary *queuedEventInfo = self.scheduledEventsQueue[0];
        [self.scheduledEventsQueue removeObject:queuedEventInfo];
        
        TBSMEvent *queuedEvent = queuedEventInfo[@"event"];
        NSDictionary *queuedEventData = queuedEventInfo[@"data"];
        
        NSArray *activeLeafStates = [self _findActiveLeafStatesInStateMachine:self];
        BOOL isDeferred = YES;
        
        for (TBSMState *activeLeafState in activeLeafStates) {
            
            // First state which can consume the queued event wins.
            if (![activeLeafState canDeferEvent:queuedEvent]) {
                isDeferred = NO;
                break;
            }
        }
        
        if (isDeferred) {
            [self.deferredEventsQueue addObject:queuedEventInfo];
        } else {
            [self handleEvent:queuedEvent data:queuedEventData];
            
            // Now that we have entered another state we will reschedule the deferred events at the beginning of the event queue.
            [self.scheduledEventsQueue insertObjects:self.deferredEventsQueue atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.deferredEventsQueue.count)]];
            [self.deferredEventsQueue removeAllObjects];
        }
    }
    self.processesEvent = NO;
}

#pragma mark - TBSMNode

- (NSArray *)getPath
{
    NSMutableArray *path = [NSMutableArray new];
    TBSMState *state = self.parentState;
    while (state) {
        [path insertObject:state atIndex:0];
        state = state.parentState;
    }
    return path;
}

- (TBSMTransition *)handleEvent:(TBSMEvent *)event data:(NSDictionary *)data
{
    return [self _handleEvent:event data:data];
}

@end
