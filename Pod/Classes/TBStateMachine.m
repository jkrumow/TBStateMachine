//
//  TBStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachine.h"

@interface TBStateMachine ()

@property (nonatomic, strong, readonly) NSMutableDictionary *priv_states;
@property (nonatomic, assign) dispatch_queue_t eventQueue;

- (void)_switchState:(id<TBStateMachineNode>)state data:(NSDictionary *)data;
- (TBStateMachineTransition *)_handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data;

@end

@implementation TBStateMachine

+ (TBStateMachine *)stateMachineWithName:(NSString *)name;
{
	return [[TBStateMachine alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name.copy;
        _priv_states = [NSMutableDictionary new];
        _eventQueue = dispatch_queue_create("com.tarbrain.TBStateMachine.EventQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setUp
{
	if (_initialState) {
        [self _switchState:_initialState data:nil];
    } else {
        @throw [NSException tb_nonExistingStateException:@"nil"];
    }
}

- (void)tearDown
{
    if (_currentState) {
        [self _switchState:nil data:nil];
    }
    _currentState = nil;
    [_priv_states removeAllObjects];
}

- (NSArray *)states
{
    return [_priv_states allValues];
}

- (void)setStates:(NSArray *)states
{
    [_priv_states removeAllObjects];
    
    for (id object in states) {
        if ([object conformsToProtocol:@protocol(TBStateMachineNode)])  {
            id<TBStateMachineNode> state = object;
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

- (void)_switchState:(id<TBStateMachineNode>)state data:(NSDictionary *)data
{
    // leave current state
    if (_currentState) {
        [_currentState exit:state data:data];
    }
    
    id<TBStateMachineNode> oldState = _currentState;
    _currentState = state;
    if (_currentState) {
        [_currentState enter:oldState data:data];
    }
}

#pragma mark - TBStateMachineNode

- (void)enter:(id<TBStateMachineNode>)previousState data:(NSDictionary *)data
{
	[self setUp];
}

- (void)exit:(id<TBStateMachineNode>)nextState data:(NSDictionary *)data
{
    [self tearDown];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    __block TBStateMachineTransition *transition = nil;
    dispatch_sync(_eventQueue, ^{
        transition = [self _handleEvent:event data:data];
    });
    
    return transition;
}

- (TBStateMachineTransition *)_handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    TBStateMachineTransition *transition;
    if (_currentState) {
        transition = [_currentState handleEvent:event data:data];
    }
    if (transition && transition.destinationState) {
        if ([_priv_states objectForKey:transition.destinationState.name]) {
            [self _switchState:transition.destinationState data:data];
        } else {
            // exit current state
            [self _switchState:nil data:data];
            
            // bubble up to parent statemachine
            return transition;
        }
    }
    return nil;
}

@end
