//
//  TBStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachine.h"

@interface TBStateMachine ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSMutableDictionary *priv_states;
@property (nonatomic, strong) NSOperationQueue *workerQueue;

- (void)switchState:(id<TBStateMachineNode>)state transition:(TBStateMachineTransition *)transition;

@end

@implementation TBStateMachine

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _priv_states = [[NSMutableDictionary alloc] init];
        _allowReentrantStates = NO;
        _workerQueue = [[NSOperationQueue alloc] init];
        _workerQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)setUp
{
	if (_initialState) {
        TBStateMachineTransition *transition = [TBStateMachineTransition transitionWithSourceState:nil destinationState:_initialState];
        [self switchState:_initialState transition:transition];
    } else {
        @throw [NSException tb_nonExistingStateException:@"nil"];
    }
}

- (void)tearDown
{
    if (_currentState) {
        TBStateMachineTransition *transition = [TBStateMachineTransition transitionWithSourceState:_currentState destinationState:nil];
        [self switchState:nil transition:transition];
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

- (void)switchState:(id<TBStateMachineNode>)state transition:(TBStateMachineTransition *)transition
{
    if (!_allowReentrantStates && state == _currentState) {
        @throw [NSException tb_reEntryStateDisallowedException:state.name];
    }
    
    // leave current state
    if (_currentState) {
        [_currentState exit:state transition:transition];
    }
    
    id<TBStateMachineNode> oldState = _currentState;
    _currentState = state;
    if (_currentState) {
        [_currentState enter:oldState transition:transition];
    }
}

#pragma mark - TBStateMachineNode

- (NSString *)stateName
{
    return _name;
}

- (void)enter:(id<TBStateMachineNode>)previousState transition:(TBStateMachineTransition *)transition
{
	[self setUp];
}

- (void)exit:(id<TBStateMachineNode>)nextState transition:(TBStateMachineTransition *)transition
{
    [self tearDown];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    TBStateMachineTransition *transition;
    if (_currentState) {
        transition = [_currentState handleEvent:event];
    }
    if (transition && transition.destinationState) {
        
        if ([_priv_states objectForKey:transition.destinationState.name]) {
            [self switchState:transition.destinationState transition:transition];
        } else {
            // exit current state
            [self switchState:nil transition:transition];
            // bubble up to parent statemachine
            return transition;
        }
    }
    return nil;
}

@end
