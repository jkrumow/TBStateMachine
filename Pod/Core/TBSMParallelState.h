//
//  TBSMParallelState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMState.h"
#import "TBSMContainingNode.h"

/**
 *  This class wraps multiple `TBSMStateMachine` instances to an orthogonal region.
 */
@interface TBSMParallelState : TBSMState <TBSMContainingNode>

/**
 *  Creates a `TBSMParallelState` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified parallel wrapper name.
 *
 *  @return The parallel wrapper instance.
 */
+ (nullable TBSMParallelState *)parallelStateWithName:(nonnull NSString *)name;

/**
 *  Initializes a `TBSMParallelState` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return An initialized `TBSMParallelState` instance.
 */
- (nullable instancetype)initWithName:(nonnull NSString *)name;

/**
 *  Returns the state machines the parallel wrapper manages.
 *
 *  @return An NSArray containing all `TBSMStateMachine` instances.
 */
- (nonnull NSArray<TBSMStateMachine *> *)stateMachines;

/**
 *  Sets the `TBSMStateMachine` instances to wrap.
 *
 *  Throws `TBSMException` if the instances are not of type `TBSMStateMachine`.
 *
 *  @param stateMachines An array of `TBSMStateMachine` instances.
 */
- (void)setStateMachines:(nonnull NSArray<TBSMStateMachine *> *)stateMachines;

@end
