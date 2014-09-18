//
//  TBStateMachineNode.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBStateMachine;
@class TBStateMachineEvent;
@class TBStateMachineTransition;

/**
 *  This protocol defines a node in a state machine.
 *
 *  Classes which implement this protocol can be managed by state machine.
 */
@protocol TBStateMachineNode <NSObject>

/**
 *  Returns the node's name.
 *
 *  Classes which implement this method must return a unique name.
 *
 *  @return The name as a string.
 */
- (NSString *)name;

/**
 *  Returns the path of the node inside the state machine hierarchy.
 *
 *  @return An array containing all parent TBStateMachine instances - top state machine at index 0.
 */
- (NSMutableArray *)getPath;

/**
 *  Returns the parent state machine.
 *
 *  @return THe parent TBStateMachine instance.
 */
- (TBStateMachine *)parentState;

/**
 *  Sets the parent state machine.
 *
 *  @param parentStateMachine The parent state machine.
 */
- (void)setParentState:(TBStateMachine *)parentStateMachine;

/**
 *  Executes the enter block of the state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)enter:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data;

/**
 *  Executes the exit block of the state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)exit:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data;

/**
 *  Receives a specified `TBStateMachineEvent` instance.
 *
 *  If the node recognizes the given `TBStateMachineEvent` the corresponding `TBStateMachineEventBlock` is executed.
 *
 *  @param event The given `TBStateMachineEvent` instance.
 *
 *  @return The next state or `nil`.
 */
- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event;

/**
 *  Receives a specified `TBStateMachineEvent` instance and payload dictionary.
 *
 *  If the node recognizes the given `TBStateMachineEvent` the corresponding `TBStateMachineEventBlock` is executed
 *  and the paylod data is passed into the block.
 *
 *  @param event The given `TBStateMachineEvent` instance.
 *  @param data  The payload data.
 *
 *  @return The next state or `nil`.
 */
- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data;

@end
