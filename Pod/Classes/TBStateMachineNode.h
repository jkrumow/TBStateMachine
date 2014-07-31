//
//  TBStateMachineNode.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBStateMachineEvent;
@class TBStateMachineTransition;

/**
 *  This protocol defines a node in a state machine. Nodes are objects that can represent states or sub state machines.
 *  and can be switched by the state machine.
 *
 */
@protocol TBStateMachineNode <NSObject>

/**
 *  Returns the node's name.
 *
 *  Classes that implement this method must return a unique name.
 *
 *  @return The name as a string.
 */
- (NSString *)name;

/**
 *  Executes the enter block of the state.
 *
 *  @param previousState The previous state.
 *  @param transition    The transition from the previous state.
 */
- (void)enter:(id<TBStateMachineNode>)previousState transition:(TBStateMachineTransition *)transition;

/**
 *  Executes the exit block of the state.
 *
 *  @param nextState  The next state.
 *  @param transition The transition to the next state.
 */
- (void)exit:(id<TBStateMachineNode>)nextState transition:(TBStateMachineTransition *)transition;

/**
 *  Receives a specified `TBStateMachineEvent` instance.
 *  If the node contains the matching `TBStateMachineEvent` instance the corresponding `TBStateMachineEventBlock` is executed.
 *
 *  @param event The given `TBStateMachineEvent` instance.
 *
 *  @return The next state or `nil`.
 */
- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event;

@end
