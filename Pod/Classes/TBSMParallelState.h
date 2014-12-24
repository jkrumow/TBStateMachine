//
//  TBSMParallelState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMState.h"

/**
 *  This class wraps multiple `TBSMStateMachine` instances and processes them in parallel.
 *
 *  **Notice:** When sending events into the TBSMParallelState instance each sub machine will handle the event, but only the follow-up state
 *  which was returned first to the wrapper will switch out of the parallel state.
 *
 *  **Concurrency:**
 *  Event handlers, enter and exit handlers will be executed on a background queue.
 *  Make sure the code in these blocks is dispatched back onto the right queue.
 */
@interface TBSMParallelState : TBSMState

/**
 *  Creates a `TBSMParallelState` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified parallel wrapper name.
 *
 *  @return The parallel wrapper instance.
 */
+ (TBSMParallelState *)parallelStateWithName:(NSString *)name;

/**
 *  Initializes a `TBSMParallelState` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return An initialized `TBSMParallelState` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Returns the state machines the parallel wrapper manages.
 *
 *  @return An NSArray containing all `TBSMStateMachine` instances.
 */
- (NSArray *)stateMachines;

/**
 *  Sets the `TBSMStateMachine` instances to wrap.
 *
 *  Throws `TBSMException` if the instances are not of type `TBSMStateMachine`.
 *
 *  @param states An array of `TBSMStateMachine` instances.
 */
- (void)setStateMachines:(NSArray *)states;

@end
