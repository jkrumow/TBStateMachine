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
#import "TBStateMachineParallelWrapper.h"
#import "NSException+TBStateMachine.h"

/**
 *  This class represents a hierarchical finite state machine.
 *
 *  The state machine is able to switch between nodes.
 *  A node can be:
 *
 *  - a simple state - represented by `TBStateMachineState`
 *  - a sub-state machine - represented by `TBStateMachine`
 *  - a wrapper for multiple parallel nodes - represented by `TBStateMachineParallelWrapper`
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
 *  **Concurrency:**
 *  Event handlers, enter and exit handlers will be executed on a background queue.
 *  Make sure the code in these blocks is dispatched back onto the right queue.
 */
@interface TBStateMachine : NSObject <TBStateMachineNode>

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

@end
