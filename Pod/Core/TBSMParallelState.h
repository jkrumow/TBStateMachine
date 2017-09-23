//
//  TBSMParallelState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMState.h"
#import "TBSMContainingVertex.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class wraps multiple `TBSMStateMachine` instances to an orthogonal region.
 */
@interface TBSMParallelState : TBSMState <TBSMContainingVertex>

/**
 *  Creates a `TBSMParallelState` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified parallel wrapper name.
 *
 *  @return The parallel wrapper instance.
 */
+ (instancetype)parallelStateWithName:(NSString *)name;

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
- (NSArray<TBSMStateMachine *> *)stateMachines;

/**
 *  Sets the `TBSMStateMachine` instances to wrap.
 *
 *  Throws `TBSMException` if the instances are not of type `TBSMStateMachine`.
 *
 *  @param stateMachines An array of `TBSMStateMachine` instances.
 */
- (void)setStateMachines:(NSArray<TBSMStateMachine *> *)stateMachines;

/**
 *  Sets all states the parallel state will manage. First state in each array wil be set as initialState.
 *  Creates state machines implicitly.
 *
 *  Throws `TBSMException` if states are not of type `TBSMState`.
 *
 *  @param states An `NSArray` containing arrays with state objects for the corresponding region.
 */
- (void)setStates:(NSArray <NSArray<__kindof TBSMState *> *> *)states;

@end
NS_ASSUME_NONNULL_END
