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
#import "TBSMCompoundTransition.h"
#import "TBSMEvent.h"
#import "TBSMEventHandler.h"
#import "TBSMParallelState.h"
#import "TBSMSubState.h"
#import "TBSMFork.h"
#import "TBSMJoin.h"
#import "NSException+TBStateMachine.h"

/**
 *  This class represents a hierarchical state machine.
 *
 *  To set the state machine up properly:
 *
 *  - set at least one state via -setStates:
 *  - set an initial state (by default the first state in the provided array will be set)
 *  - call -setUp: to activate the state machine
 *  - call -tearDown: to deactivate the state machine
 */
@interface TBSMStateMachine : NSObject <TBSMNode>

/**
 *  The operation queue to handle the run to completion steps.
 *  Should be serial.
 *
 *  Throws an exception when trying to set a queue which is not serial.
 */
@property (nonatomic, strong) NSOperationQueue *scheduledEventsQueue;

/**
 *  The state the state machine wil enter on setup (by default the first state in the provided array will be set).
 *
 *  Throws an exception if the state does not exist in the statemachine.
 */
@property (nonatomic, strong) TBSMState *initialState;

/**
 *  The current state the state machine resides in. Set to be nil before -setUp: and after -tearDown: being called.
 */
@property (nonatomic, strong, readonly) TBSMState *currentState;

/**
 *  Creates a `TBSMStateMachine` instance from a given name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The specified state machine name.
 *
 *  @return The state machine instance.
 */
+ (TBSMStateMachine *)stateMachineWithName:(NSString *)name;

/**
 *  Initializes a `TBSMStateMachine` with a specified name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The name of the state machine. Must be unique.
 *
 *  @return An initialized `TBSMStateMachine` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Starts up the state machine. Will enter the initial state.
 *
 *  Throws `TBSMException` if initial state has not been set beforehand.
 */
- (void)setUp:(NSDictionary *)data;

/**
 *  Leaves the current state and shuts down the state machine.
 */
- (void)tearDown:(NSDictionary *)data;

/**
 *  Returns all states inside the state machine.
 *
 *  @return An NSArray containing all `TBSMState` instances.
 */
- (NSArray *)states;

/**
 *  Sets all states the state machine will manage. First state in array wil be set as initialState.
 *
 *  Throws `TBSMException` if states are not of type `TBSMState`.
 *
 *  @param states An `NSArray` containing all state objects.
 */
- (void)setStates:(NSArray *)states;

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
 *  @param event The given `TBSMEvent` instance.
 *
 *  @return `YES` if the event has been handled.
 */
- (BOOL)handleEvent:(TBSMEvent *)event;

/**
 *  Switches between states defined in a specified transition.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param action      The action to execute.
 *  @param data        The payload data.
 */
- (void)switchState:(TBSMState *)sourceState targetState:(TBSMState *)targetState action:(TBSMActionBlock)action data:(NSDictionary *)data;

/**
 *  Enters a specified state.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
- (void)enterState:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data;

/**
 *  Exits a specified state.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
- (void)exitState:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data;

@end
