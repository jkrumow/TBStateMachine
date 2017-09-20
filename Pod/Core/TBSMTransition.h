//
//  TBSMTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMTransitionKind.h"

NS_ASSUME_NONNULL_BEGIN

@class TBSMState;
@class TBSMStateMachine;

/**
 *  This type represents an action of a `TBSMTransition`.
 *
 *  @param data The payload data.
 */
typedef void(^TBSMActionBlock)(id _Nullable data);

/**
 *  This type represents a guard function of a `TBSMTransition`.
 *
 *  @param data The payload data.
 */
typedef BOOL(^TBSMGuardBlock)(id _Nullable data);


/**
 *  This class represents a transition between two states.
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
 *  The name of the event being handled.
 *
 */
@property (nonatomic, strong) NSString *eventName;

/**
 *  Initializes a `TBSMTransition` instance from a given source and target state, action and guard.
 *
 *  @param sourceState The specified source state.
 *  @param targetState The specified target state.
 *  @param kind        The kind of transition.
 *  @param action      The action associated with this transition.
 *  @param guard       The guard function associated with the transition.
 *  @param eventName   The name of the event being handled.
 *
 *  @return The transition object.
 */
- (instancetype)initWithSourceState:(TBSMState *)sourceState
                        targetState:(nullable TBSMState *)targetState
                               kind:(TBSMTransitionKind)kind
                             action:(nullable TBSMActionBlock)action
                              guard:(nullable TBSMGuardBlock)guard
                          eventName:(NSString *)eventName;


- (TBSMStateMachine *)findLeastCommonAncestor;

/**
 *  Checks wether the transition can be performed by evaluating its guards.
 *
 *  @param data The payload data.
 *
 *  @return Returns YES if the transition can be performed.
 */
- (BOOL)canPerformTransitionWithData:(id)data;

/**
 *  Performs the transition between source and target state.
 *  Evaluates guard and action blocks.
 *  Determines the lca considering the transiton kind.
 *
 *  Throws a `TBSMException` if transition could not be resolved.
 *
 *  @param data The payload data.
 *
 *  @return Returns YES if the transition can be performed.
 */
- (BOOL)performTransitionWithData:(nullable id)data;

/**
 *  The transition's name.
 *
 *  @return The name.
 */
- (NSString *)name;

@end

NS_ASSUME_NONNULL_END
