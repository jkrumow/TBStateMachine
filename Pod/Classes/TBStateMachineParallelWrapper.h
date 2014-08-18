//
//  TBStateMachineParallelWrapper.h
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
 *  **Notice:** When sending events into the TBStateMachineParallelWrapper instance each node will handle the event, but only the follow-up node
 *  which was returned first to the wrapper will switch out of the parallel state.
 *
 *  **Concurrency:**
 *  Event handlers, enter and exit handlers will be executed on a background queue.
 *  Make sure the code in these blocks is dispatched back onto the right queue.
 */
@interface TBStateMachineParallelWrapper : NSObject <TBStateMachineNode>

/**
 *  Creates a `TBStateMachineParallelWrapper` instance from a given name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The specified parallel wrapper name.
 *
 *  @return The parallel wrapper instance.
 */
+ (TBStateMachineParallelWrapper *)parallelWrapperWithName:(NSString *)name;

/**
 *  Initializes a `TBStateMachineParallelWrapper` with a specified name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return An initialized `TBStateMachineParallelWrapper` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Sets the `TBStateMachineNode` instances to wrap.
 *
 *  Throws `TBStateMachineException` if the instances are not of type `TBStateMachineNode`.
 *
 *  @param states An array of `TBStateMachineNode` instances.
 */
- (void)setStates:(NSArray *)states;

@end
