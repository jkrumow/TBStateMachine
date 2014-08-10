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
 *  This class represents a state machine.
 *
 * TODO: add features etc.
 */
@interface TBStateMachine : NSObject <TBStateMachineNode>

/**
 *  The state machine's name.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  The initial state of the state machine. Must be set before calling @see -setup.
 */
@property (nonatomic, strong, readonly) id<TBStateMachineNode> initialState;

/**
 *  The current state the state machine resides in. Set to `nil` if the state machine currently travels a transition.
 */
@property (nonatomic, strong, readonly) id<TBStateMachineNode> currentState;

/**
 *  Creates a `TBStateMachine` instance from a given name.
 *
 *  @param name The specified state machine name.
 *
 *  @return The state machine instance.
 */
+ (TBStateMachine *)stateMachineWithName:(NSString *)name;

/**
 *  Initializes a `TBStateMachine` with a specified name.
 *
 *  @param name The name of the state machine. Must be unique.
 *
 *  @return An initialized `TBStateMachine` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Starts up the state machine. Will switch into the state defined by @see -setInitialState:.
 *
 *  Throws a `TBStateMachineException` if initial state has not been set beforehand.
 */
- (void)setUp;

/**
 *  Leaves the current state or cancelles the current transition. Shuts down the state machine.
 */
- (void)tearDown;

/**
 *  Returns the states the state machine manages.
 *
 *  @return An NSArray containing all `TBStateMachineNode` instances
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
 *  Throws a `TBStateMachineException` if state has not been set through @see -setStates:.
 *
 *  @param initialState A given state object.
 */
- (void)setInitialState:(id<TBStateMachineNode>)initialState;

@end
