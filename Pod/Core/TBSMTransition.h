//
//  TBSMTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMTransitionKind.h"

@class TBSMState;
@class TBSMStateMachine;

/**
 *  This type represents an action of a `TBSMTransition`.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
typedef void(^TBSMActionBlock)(TBSMState *_Nullable sourceState, TBSMState * _Nullable targetState, id _Nullable data);

/**
 *  This type represents a guard function of a `TBSMTransition`.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
typedef BOOL(^TBSMGuardBlock)(TBSMState *_Nullable sourceState, TBSMState *_Nullable targetState, id _Nullable data);


/**
 *  This class represents a transition inside a state machine.
 */
@interface TBSMTransition : NSObject

/**
 *  The source state.
 */
@property (nonatomic, weak) TBSMState *sourceState;

/**
 *  The target state.
 */
@property (nonatomic, weak) TBSMState *targetState;

/**
 *  The kind of transition.
 */
@property (nonatomic, assign) TBSMTransitionKind kind;

/**
 *  The action associated with the transition.
 */
@property (nonatomic, copy, nullable) TBSMActionBlock action;

/**
 *  The guard function associated with the transition.
 */
@property (nonatomic, copy, nullable) TBSMGuardBlock guard;

/**
 *  Creates a `TBSMTransition` instance from a given source and target state, action and guard.
 *
 *  @param sourceState The specified source state.
 *  @param targetState The specified target state.
 *  @param kind        The kind of transition.
 *  @param action      The action associated with this transition.
 *  @param guard       The guard function associated with the transition.
 *
 *  @return The transition object.
 */
+ (nullable TBSMTransition *)transitionWithSourceState:(nonnull TBSMState *)sourceState
                                  targetState:(nonnull TBSMState *)targetState
                                         kind:(TBSMTransitionKind)kind
                                       action:(nullable TBSMActionBlock)action
                                        guard:(nullable TBSMGuardBlock)guard;

/**
 *  Initializes a `TBSMTransition` instance from a given source and target state, action and guard.
 *
 *  @param sourceState The specified source state.
 *  @param targetState The specified target state.
 *  @param kind        The kind of transition.
 *  @param action      The action associated with this transition.
 *  @param guard       The guard function associated with the transition.
 *
 *  @return The transition object.
 */
- (nullable instancetype)initWithSourceState:(nonnull TBSMState *)sourceState
                        targetState:(nonnull TBSMState *)targetState
                               kind:(TBSMTransitionKind)kind
                             action:(nullable TBSMActionBlock)action
                              guard:(nullable TBSMGuardBlock)guard;


- (nonnull TBSMStateMachine *)findLeastCommonAncestor;

/**
 *  Performs the transition between source and target state.
 *  Evaluates guard and action blocks.
 *  Determines the lca considering the transiton kind.
 *
 *  Throws a `TBSMException` if transition could not be resolved.
 *
 *  @param data The payload data.
 *
 *  @return Returns YES if the transition could be performed.
 */
- (BOOL)performTransitionWithData:(nullable id)data;

/**
 *  The transition's name.
 *
 *  @return The name.
 */
- (nonnull NSString *)name;

@end
