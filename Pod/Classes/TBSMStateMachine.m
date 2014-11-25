//
//  TBSMStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine.h"

@interface TBSMStateMachine ()

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t eventDispatchQueue;
#else
@property (nonatomic, assign) dispatch_queue_t eventDispatchQueue;
#endif

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) TBSMState *parentState;
@property (nonatomic, strong) NSMutableDictionary *priv_states;
@property (nonatomic, strong) NSMutableArray *eventQueue;
@property (nonatomic, assign, getter = isProcessingEvent) BOOL processesEvent;

- (TBSMSubState *)_findNextNodeForState:(TBSMState *)state;
- (TBSMStateMachine *)_findLowestCommonAncestorForSourceState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState;
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
    _initialState = states[0];
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
    @synchronized(self.eventQueue) {
        
        NSDictionary *queuedEvent = nil;
        if (data) {
            queuedEvent = @{@"event" : event, @"data" : data};
        } else {
            queuedEvent = @{@"event" : event};
        }
        
        [self.eventQueue addObject:queuedEvent];
        
        if (self.isProcessingEvent) {
            NSLog(@"Queuing event %@", event.name);
        } else {
            while (self.eventQueue.count > 0) {
                NSLog(@"%lu more scheduled events to handle.", (unsigned long)self.eventQueue.count);
                
                dispatch_sync(_eventDispatchQueue, ^{
                    [self _handleNextEvent];
                });
            }
        }
    }
}

- (void)switchState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data action:(TBSMActionBlock)action
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

- (TBSMTransition *)_handleEvent:(TBSMEvent *)event data:(NSDictionary *)data
{
    TBSMTransition *transition;
    if (_currentState) {
        transition = [_currentState handleEvent:event data:data];
    }
    if (transition && transition.destinationState) {
        
        TBSMActionBlock action = transition.action;
        TBSMGuardBlock guard = transition.guard;
        if (guard == nil || guard(transition.sourceState, transition.destinationState, data)) {
            TBSMStateMachine *lowestCommonAncestor = [self _findLowestCommonAncestorForSourceState:transition.sourceState destinationState:transition.destinationState];
            if (lowestCommonAncestor) {
                [lowestCommonAncestor switchState:_currentState destinationState:transition.destinationState data:data action:action];
            } else {
                NSLog(@"No transition possible from source state %@ to destination state %@ via statemachine %@.", transition.sourceState.name, transition.destinationState.name, self.name);
            }
        }
    }
    return nil;
}

- (void)_handleNextEvent
{
    if (self.eventQueue.count > 0) {
        self.processesEvent = YES;
        NSDictionary *queuedEvent = self.eventQueue[0];
        [self.eventQueue removeObject:queuedEvent];
        [self handleEvent:queuedEvent[@"event"] data:queuedEvent[@"data"]];
        self.processesEvent = NO;
    }
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
