//
//  TBStateMachineParallelState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBStateMachineNode.h"

/**
 *  This class wraps multiple `TBStateMachineNode` instances and processes them in parallel.
 *
 *  **Notice:** When sending events into the TBStateMachineParallelState instance each node will handle the event, but only the follow-up node
 *  which was returned first to the wrapper will switch out of the parallel state.
 *
 *  **Concurrency:**
 *  Event handlers, enter and exit handlers will be executed on a background queue.
 *  Make sure the code in these blocks is dispatched back onto the right queue.
 */
@interface TBStateMachineParallelState : NSObject <TBStateMachineNode>

/**
 *  Creates a `TBStateMachineParallelState` instance from a given name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The specified parallel wrapper name.
 *
 *  @return The parallel wrapper instance.
 */
+ (TBStateMachineParallelState *)parallelStateWithName:(NSString *)name;

/**
 *  Initializes a `TBStateMachineParallelState` with a specified name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return An initialized `TBStateMachineParallelState` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Returns the state machines the parallel wrapper manages.
 *
 *  @return An NSArray containing all `TBStateMachine` instances.
 */
- (NSArray *)states;

/**
 *  Sets the `TBStateMachine` instances to wrap.
 *
 *  Throws `TBStateMachineException` if the instances are not of type `TBStateMachine`.
 *
 *  @param states An array of `TBStateMachine` instances.
 */
- (void)setStates:(NSArray *)states;

@end
