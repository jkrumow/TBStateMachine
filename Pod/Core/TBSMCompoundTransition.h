//
//  TBSMCompoundTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMTransition.h"
#import "TBSMTransitionVertex.h"
#import "TBSMPseudoState.h"


/**
 *  This class represents a compound transition inside a state machine.
 */
@interface TBSMCompoundTransition : TBSMTransition

/**
 *  The target pseudo state.
 */
@property (nonatomic, strong, nonnull) TBSMPseudoState *targetPseudoState;

/**
 *  Creates a `TBSMCompoundTransition` instance from a given source and target state, action and guard.
 *
 *  @param sourceState       The specified source state.
 *  @param targetPseudoState The specified target pseudostate.
 *  @param action            The action associated with this transition.
 *  @param guard             The guard function associated with the transition.
 *
 *  @return The created compound transition instance.
 */
+ (nonnull TBSMCompoundTransition *)compoundTransitionWithSourceState:(nonnull TBSMState *)sourceState
                                            targetPseudoState:(nonnull TBSMPseudoState *)targetPseudoState
                                                       action:(nullable TBSMActionBlock)action
                                                        guard:(nullable TBSMGuardBlock)guard;

/**
 *  Initializes a `TBSMCompoundTransition` instance from a given source and target state, action and guard.
 *
 *  @param sourceState       The specified source state.
 *  @param targetPseudoState The specified target pseudostate.
 *  @param action            The action associated with this transition.
 *  @param guard             The guard function associated with the transition.
 *
 *  @return The initialized compound transition instance.
 */
- (nullable instancetype)initWithSourceState:(nonnull TBSMState *)sourceState
                  targetPseudoState:(nonnull TBSMPseudoState *)targetPseudoState
                             action:(nullable TBSMActionBlock)action
                              guard:(nullable TBSMGuardBlock)guard;
@end
