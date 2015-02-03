//
//  TBSMStateMachine.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMState.h"
#import "TBSMTransition.h"
#import "TBSMEvent.h"
#import "TBSMEventHandler.h"
#import "TBSMParallelState.h"
#import "TBSMSubState.h"
#import "NSException+TBStateMachine.h"

/**
 *  This class represents a hierarchical state machine.
 *
 *  The state machine is able to switch between nodes.
 *  A node can be:
 *
 *  - a simple state - represented by `TBSMState`
 *  - a wrapper for a sub state machine - represented by `TBSMSubState`
 *  - a wrapper for parallel state machines - represented by `TBSMParallelState`
 *
 *  All classes mentioned above implement the `TBSMNode` protocol.
 *
 *  To set the state machine up properly:
 *
 *  - set at least one state via -setStates:
 *  - set an initial state (optional. The first state in the provided array is always set as the initial state)
 *  - call -setUp to activate the state machine
 *  - call -tearDown to deactivate the state machine
 *
 */
@interface TBSMStateMachine : NSObject <TBSMNode>

/**
 *  The initial state of the state machine. Must be set before calling -setUp.
 */
@property (nonatomic, strong, readonly) TBSMState *initialState;

/**
 *  The current state the state machine resides in. Set to be nil before -setUp and after -tearDown being called.
 */
@property (nonatomic, strong, readonly) TBSMState *currentState;

/**
 *  Creates a `TBSMStateMachine` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified state machine name.
 *
 *  @return The state machine instance.
 */
+ (TBSMStateMachine *)stateMachineWithName:(NSString *)name;

/**
 *  Initializes a `TBSMStateMachine` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of the state machine. Must be unique.
 *
 *  @return An initialized `TBSMStateMachine` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Starts up the state machine. Will switch into the state defined by -setInitialState:.
 *
 *  Throws `TBSMException` if initial state has not been set beforehand.
 */
- (void)setUp:(NSDictionary *)data;

/**
 *  Leaves the current state and shuts down the state machine.
 */
- (void)tearDown:(NSDictionary *)data;

/**
 *  Returns the states the state machine manages.
 *
 *  @return An NSArray containing all `TBSMState` instances.
 */
- (NSArray *)states;

/**
 *  Sets all states the state machine will manage. First state in array wil be set as initialState.
 *
 *  Throws `TBSMException` if states do not conform to the `TBSMState` protocol.
 *
 *  @param states An `NSArray` containing all state objects.
 */
- (void)setStates:(NSArray *)states;

/**
 *  Sets the initial state of the state machine.
 *
 *  Throws `TBSMException` if state has not been set through -setStates:.
 *
 *  @param initialState A given state object.
 */
- (void)setInitialState:(TBSMState *)initialState;

/**
 *  Schedules an event.
 *  The state machine will queue all events it receives until processing of the current event has finished.
 *
 *  @param event The given `TBSMEvent` instance.
 */
- (void)scheduleEvent:(TBSMEvent *)event;

/**
 *  Receives a specified `TBSMEvent` instance.
 *
 *  If the node recognizes the given `TBSMEvent` it will return `YES`.
 *
 *  @param event The given `TBSMEvent` instance.
 *
 *  @return `YES` if teh transition has been handled.
 */
- (BOOL)handleEvent:(TBSMEvent *)event;

/**
 *  Enters a given state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)enterState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data;

/**
 *  Exits a given state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)exitState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data;

@end
