//
//  TBSMTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMTransitionKind.h"

@class TBSMState;
@class TBSMStateMachine;

/**
 *  This type represents an action of a given `TBSMTransition`.
 *
 *  @param sourceState      The source state.
 *  @param targetState The destination state.
 *  @param data             The payload data.
 */
typedef void(^TBSMActionBlock)(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data);

/**
 *  This type represents a guard function of a given `TBSMTransition`.
 *
 *  @param sourceState      The source state.
 *  @param targetState The destination state.
 *  @param data             The payload data.
 */
typedef BOOL(^TBSMGuardBlock)(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data);


/**
 *  This class represents a transition in a state machine.
 */
@interface TBSMTransition : NSObject

/**
 *  The source state.
 */
@property (nonatomic, weak) TBSMState *sourceState;

/**
 *  The destination state.
 */
@property (nonatomic, weak) TBSMState *targetState;

/**
 *  The kind of transition.
 */
@property (nonatomic, assign, readonly) TBSMTransitionKind kind;

/**
 *  The action associated with the transition.
 */
@property (nonatomic, copy, readonly) TBSMActionBlock action;

/**
 *  The guard function associated with the transition.
 */
@property (nonatomic, copy, readonly) TBSMGuardBlock guard;

/**
 *  Creates a `TBSMTransition` instance from a given source and destination state, action and guard.
 *
 *  @param sourceState      The specified source state.
 *  @param targetState The specified destination state.
 *  @param kind             The kind of transition.
 *  @param action           The action associated with this transition.
 *  @param guard            The guard function associated with the transition.
 *
 *  @return The transition object.
 */
+ (TBSMTransition *)transitionWithSourceState:(TBSMState *)sourceState
                                  targetState:(TBSMState *)targetState
                                         kind:(TBSMTransitionKind)kind
                                       action:(TBSMActionBlock)action
                                        guard:(TBSMGuardBlock)guard;

/**
 *  Initializes a `TBSMTransition` instance from a given source and destination state, action and guard.
 *
 *  @param sourceState      The specified source state.
 *  @param targetState The specified destination state.
 *  @param kind             The kind of transition.
 *  @param action           The action associated with this transition.
 *  @param guard            The guard function associated with the transition.
 *
 *  @return The transition object.
 */
- (instancetype)initWithSourceState:(TBSMState *)sourceState
                        targetState:(TBSMState *)targetState
                               kind:(TBSMTransitionKind)kind
                             action:(TBSMActionBlock)action
                              guard:(TBSMGuardBlock)guard;


/**
 *  Performs the transition between source and target state.
 *  Evaluates guard and action blocks.
 *  Calculates the lca regarding the transiton kind.
 *
 *  @param data The payload data.
 *
 *  @return Returns YES if the transition could be performed.
 */
- (BOOL)performTransitionWithData:(NSDictionary *)data;

/**
 *  The transition's name.
 *
 *  @return The name.
 */
- (NSString *)name;

@end
