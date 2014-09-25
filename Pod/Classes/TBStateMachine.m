//
//  TBStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachine.h"

@interface TBStateMachine ()

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t eventDispatchQueue;
#else
@property (nonatomic, assign) dispatch_queue_t eventDispatchQueue;
#endif

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) TBStateMachineState *parentState;
@property (nonatomic, strong) NSMutableDictionary *priv_states;
@property (nonatomic, strong) NSMutableArray *eventQueue;
@property (nonatomic, assign, getter = isProcessingEvent) BOOL processesEvent;

- (TBStateMachineSubState *)_findNextNodeForState:(TBStateMachineState *)state;
- (TBStateMachine *)_findLowestCommonAncestorForSourceState:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState;
- (TBStateMachineTransition *)_handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data;
- (void)_handleNextEvent;

@end

@implementation TBStateMachine

+ (TBStateMachine *)stateMachineWithName:(NSString *)name;
{
    return [[TBStateMachine alloc] initWithName:name];
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
        _eventQueue = [NSMutableArray new];
        _processesEvent = NO;
        _eventDispatchQueue = dispatch_queue_create("com.tarbrain.TBStateMachine.eventDispatchQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_eventDispatchQueue);
    _eventDispatchQueue = nil;
#endif
}

- (void)setUp
{
    if (_initialState) {
        [self switchState:nil destinationState:_initialState data:nil action:nil];
    } else {
        @throw [NSException tb_nonExistingStateException:@"initialState"];
    }
}

- (void)tearDown
{
    if (_currentState) {
        [self switchState:_currentState destinationState:nil data:nil action:nil];
    }
    _currentState = nil;
    [_priv_states removeAllObjects];
}

- (NSArray *)states
{
    return [NSArray arrayWithArray:_priv_states.allValues];
}

- (void)setStates:(NSArray *)states
{
    [_priv_states removeAllObjects];
    
    for (id object in states) {
        if ([object isKindOfClass:[TBStateMachineState class]])  {
            TBStateMachineState *state = object;
            if (self.parentState) {
                [state setParentState:self.parentState];
            } else {
                [state setParentState:self];
            }
            [_priv_states setObject:state forKey:state.name];
        } else {
            @throw ([NSException tb_notOfTypeTBStateMachineStateException:object]);
        }
    }
    _initialState = states[0];
}

- (void)setInitialState:(TBStateMachineState *)initialState
{
    if ([_priv_states objectForKey:initialState.name]) {
        _initialState = initialState;
    } else {
        @throw [NSException tb_nonExistingStateException:initialState.name];
    }
}

- (void)scheduleEvent:(TBStateMachineEvent *)event
{
    [self scheduleEvent:event data:nil];
}

- (void)scheduleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    @synchronized(_eventQueue) {
        
        NSDictionary *queuedEvent = nil;
        if (data) {
            queuedEvent = @{@"event" : event, @"data" : data};
        } else {
            queuedEvent = @{@"event" : event};
        }
        
        [_eventQueue addObject:queuedEvent];
        
        if (self.isProcessingEvent) {
            NSLog(@"Queuing event %@", event.name);
        } else {
            while (_eventQueue.count > 0) {
                NSLog(@"%lu more scheduled events to handle.", (unsigned long)_eventQueue.count);
                
                dispatch_sync(_eventDispatchQueue, ^{
                    [self _handleNextEvent];
                });
            }
        }
    }
}

- (void)switchState:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState data:(NSDictionary *)data action:(TBStateMachineActionBlock)action
{
    // exit current state
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

- (TBStateMachineState *)_findNextNodeForState:(TBStateMachineState *)state
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

- (TBStateMachine *)_findLowestCommonAncestorForSourceState:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState
{
    NSArray *sourcePath = [sourceState getPath];
    NSArray *destinationPath = [destinationState getPath];
    
    for (NSInteger i = sourcePath.count-1; i >= 0; i--) {
        TBStateMachineState *state = sourcePath[i];
        if (![state isKindOfClass:[TBStateMachine class]]) {
            continue;
        }
        TBStateMachine *stateMachine = (TBStateMachine *)state;
        if ([destinationPath containsObject:stateMachine]) {
            return stateMachine;
        }
    }
    return nil;
}

- (TBStateMachineTransition *)_handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    TBStateMachineTransition *transition;
    if (_currentState) {
        transition = [_currentState handleEvent:event data:data];
    }
    if (transition && transition.destinationState) {
        
        TBStateMachineActionBlock action = transition.action;
        TBStateMachineGuardBlock guard = transition.guard;
        if (guard == nil || guard(transition.sourceState, transition.destinationState, data)) {
            TBStateMachine *lowestCommonAncestor = [self _findLowestCommonAncestorForSourceState:transition.sourceState destinationState:transition.destinationState];
            if (lowestCommonAncestor) {
                [lowestCommonAncestor switchState:_currentState destinationState:transition.destinationState data:data action:action];
            }
        }
    }
    return nil;
}

- (void)_handleNextEvent
{
    if (_eventQueue.count > 0) {
        self.processesEvent = YES;
        NSDictionary *queuedEvent = _eventQueue[0];
        [_eventQueue removeObject:queuedEvent];
        [self handleEvent:queuedEvent[@"event"] data:queuedEvent[@"data"]];
        self.processesEvent = NO;
    }
}

#pragma mark - TBStateMachineNode

- (NSArray *)getPath
{
    NSMutableArray *path = [NSMutableArray new];
    TBStateMachineState *state = self.parentState;
    while (state) {
        [path insertObject:state atIndex:0];
        state = state.parentState;
    }
    return path;
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    return [self _handleEvent:event data:data];
}

@end
