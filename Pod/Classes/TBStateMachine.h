//
//  TBStateMachine.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBStateMachineState.h"
#import "TBStateMachineTransition.h"
#import "TBStateMachineEvent.h"
#import "TBStateMachineEventHandler.h"
#import "TBStateMachineParallelState.h"
#import "TBStateMachineSubState.h"
#import "NSException+TBStateMachine.h"

/**
 *  This class represents a hierarchical state machine.
 *
 *  The state machine is able to switch between nodes.
 *  A node can be:
 *
 *  - a simple state - represented by `TBStateMachineState`
 *  - a sub-state machine - represented by `TBStateMachine`
 *  - a wrapper for multiple parallel nodes - represented by `TBStateMachineParallelState`
 *
 *  All classes mentioned above implement the `TBStateMachineNode` protocol.
 *
 *  To set the state machine up properly:
 *
 *  - set at least one state via -setStates:
 *  - set an initial state (which has already been added to the state machine) via -setInitialState:
 *  - call -setUp to activate the state machine
 *  - call -tearDown to deactivate the state machine
 *
 */
@interface TBStateMachine : NSObject

/**
 *  The initial state of the state machine. Must be set before calling -setUp.
 */
@property (nonatomic, strong, readonly) id<TBStateMachineNode> initialState;

/**
 *  The current state the state machine resides in. Set to be nil before -setUp and after -tearDown being called.
 */
@property (nonatomic, strong, readonly) id<TBStateMachineNode> currentState;

/**
 *  Creates a `TBStateMachine` instance from a given name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The specified state machine name.
 *
 *  @return The state machine instance.
 */
+ (TBStateMachine *)stateMachineWithName:(NSString *)name;

/**
 *  Initializes a `TBStateMachine` with a specified name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The name of the state machine. Must be unique.
 *
 *  @return An initialized `TBStateMachine` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Starts up the state machine. Will switch into the state defined by -setInitialState:.
 *
 *  Throws `TBStateMachineException` if initial state has not been set beforehand.
 */
- (void)setUp;

/**
 *  Leaves the current state and shuts down the state machine.
 */
- (void)tearDown;

/**
 *  Returns the states the state machine manages.
 *
 *  @return An NSArray containing all `TBStateMachineNode` instances.
 */
- (NSArray *)states;

/**
 *  Sets all states the state machine will manage.
 *
 *  Throws `TBStateMachineException` if states do not conform to the `TBStateMachineNode` protocol.
 *
 *  @param states An `NSArray` containing all state objects.
 */
- (void)setStates:(NSArray *)states;

/**
 *  Sets the initial state of the state machine.
 *
 *  Throws `TBStateMachineException` if state has not been set through -setStates:.
 *
 *  @param initialState A given state object.
 */
- (void)setInitialState:(id<TBStateMachineNode>)initialState;

/**
 *  Schedules an event.
 *  The state machine will queue all events it receives until processing of the current state has finished.
 *
 *  @param event The given `TBStateMachineEvent` instance.
 */
- (void)scheduleEvent:(TBStateMachineEvent *)event;

/**
 *  Schedules an event with a given payload.
 *  The state machine will queue all events it receives until processing of the current state has finished.
 *
 *  @param event The given `TBStateMachineEvent` instance.
 *  @param data  The payload data.
 */
- (void)scheduleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data;

/**
 *  Switches from a given source state into a specified destination state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 *  @param action           The transition action.
 */
- (void)switchState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data action:(TBStateMachineActionBlock)action;

@end
