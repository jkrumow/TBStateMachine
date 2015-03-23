//
//  TBSMCompoundTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
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
@property (nonatomic, strong) TBSMPseudoState *targetPseudoState;

/**
 *  Creates a `TBSMCompoundTransition` instance from a given source and target state, action and guard.
 *
 *  @param sourceState The specified source state.
 *  @param targetState The specified target state.
 *  @param action      The action associated with this transition.
 *  @param guard       The guard function associated with the transition.
 *
 *  @return The transition object.
 */
+ (TBSMCompoundTransition *)compoundTransitionWithSourceState:(TBSMState *)sourceState
                                            targetPseudoState:(TBSMPseudoState *)targetPseudoState
                                                       action:(TBSMActionBlock)action
                                                        guard:(TBSMGuardBlock)guard;

/**
 *  Initializes a `TBSMCompoundTransition` instance from a given source and target state, action and guard.
 *
 *  @param sourceState The specified source state.
 *  @param targetState The specified target state.
 *  @param action      The action associated with this transition.
 *  @param guard       The guard function associated with the transition.
 *
 *  @return The transition object.
 */
- (instancetype)initWithSourceState:(TBSMState *)sourceState
                  targetPseudoState:(TBSMPseudoState *)targetPseudoState
                             action:(TBSMActionBlock)action
                              guard:(TBSMGuardBlock)guard;
@end
