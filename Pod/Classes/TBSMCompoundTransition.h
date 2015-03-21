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

@interface TBSMCompoundTransition : TBSMTransition

@property (nonatomic, strong) TBSMPseudoState *targetPseudoState;

+ (TBSMCompoundTransition *)compoundTransitionWithSourceState:(TBSMState *)sourceState
                                            targetPseudoState:(TBSMPseudoState *)targetPseudoState
                                                       action:(TBSMActionBlock)action
                                                        guard:(TBSMGuardBlock)guard;

- (instancetype)initWithSourceState:(TBSMState *)sourceState
                  targetPseudoState:(TBSMPseudoState *)targetPseudoState
                             action:(TBSMActionBlock)action
                              guard:(TBSMGuardBlock)guard;
@end
