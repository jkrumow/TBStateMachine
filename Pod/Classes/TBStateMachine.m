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
@property (nonatomic, weak) TBStateMachine *parentState;
@property (nonatomic, strong) NSMutableDictionary *priv_states;
@property (nonatomic, strong) NSMutableArray *eventQueue;
@property (nonatomic, assign, getter = isProcessingEvent) BOOL processesEvent;

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
        @throw [NSException tb_noNameForNodeException];
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
        @throw [NSException tb_nonExistingStateException:@"nil"];
    }
}

- (void)tearDown
{
    if (_currentState) {
        [self switchState:nil destinationState:nil data:nil action:nil];
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
        if ([object conformsToProtocol:@protocol(TBStateMachineNode)])  {
            id<TBStateMachineNode> state = object;
            [state setParentState:self];
            [_priv_states setObject:state forKey:state.name];
        } else {
            @throw ([NSException tb_doesNotConformToNodeProtocolException:object]);
        }
    }
}

- (void)setInitialState:(id<TBStateMachineNode>)initialState
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

- (void)switchState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data action:(TBStateMachineActionBlock)action
{
    // exit current state
    if (_currentState) {
        [_currentState exit:sourceState destinationState:destinationState data:data];
    }
    
    if (action) {
        action(sourceState, destinationState, data);
    }
    
    id<TBStateMachineNode> oldState = _currentState;
    _currentState = destinationState;
    if (_currentState) {
        [_currentState enter:oldState destinationState:_currentState data:data];
    }
}

#pragma mark - private methods

- (TBStateMachine *)_findLowestCommonAncestorForSourceState:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState
{
    NSArray *sourcePath = [sourceState getPath];
    NSArray *destinationPath = [destinationState getPath];
    
    for (NSInteger i = sourcePath.count-1; i >= 0; i--) {
        id<TBStateMachineNode> node = sourcePath[i];
        if (![node isKindOfClass:[TBStateMachine class]]) {
            continue;
        }
        TBStateMachine *stateMachine = node;
        if ([destinationPath containsObject:stateMachine]) {
            return stateMachine;
        }
    }
    return self;
}

- (TBStateMachineTransition *)_handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    TBStateMachineTransition *transition;
    if (_currentState) {
        transition = [_currentState handleEvent:event data:data];
    }
    if (transition && transition.destinationState) {
        
        if ([_priv_states objectForKey:transition.destinationState.name]) {
            
            TBStateMachineActionBlock action = transition.action;
            TBStateMachineGuardBlock guard = transition.guard;
            if (guard == nil || guard(transition.sourceState, transition.destinationState, data)) {
                TBStateMachine *lowestCommonAncestor = [self _findLowestCommonAncestorForSourceState:transition.sourceState destinationState:transition.destinationState];
                [lowestCommonAncestor switchState:_currentState destinationState:transition.destinationState data:data action:action];
            }
        } else {
            // exit current state
            [self switchState:_currentState destinationState:nil data:data action:nil];
            
            // bubble up to parent statemachine
            return transition;
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
    TBStateMachine *node = self.parentState;
    while (node) {
        [path insertObject:node atIndex:0];
        node = node.parentState;
    }
    return path;
}

- (void)enter:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data
{
    if (destinationState == self) {
        [self setUp];
    } else {
        [self switchState:sourceState destinationState:destinationState data:data action:nil];
    }
}

- (void)exit:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data
{
    if (destinationState == nil) {
        [self tearDown];
    } else {
        [self switchState:sourceState destinationState:destinationState data:data action:nil];
    }
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
