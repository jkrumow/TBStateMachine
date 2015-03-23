//
//  TBSMCompoundTransition.m
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMCompoundTransition.h"
#import "TBSMStateMachine.h"
#import "TBSMState.h"
#import "TBSMFork.h"
#import "TBSMJoin.h"

@interface TBSMCompoundTransition ()

@end

@implementation TBSMCompoundTransition

+ (TBSMCompoundTransition *)compoundTransitionWithSourceState:(TBSMState *)sourceState
                                                  targetPseudoState:(TBSMPseudoState *)targetPseudoState
                                                       action:(TBSMActionBlock)action
                                                        guard:(TBSMGuardBlock)guard
{
    return [[TBSMCompoundTransition alloc] initWithSourceState:sourceState targetPseudoState:targetPseudoState action:action guard:guard];
}

- (instancetype)initWithSourceState:(TBSMState *)sourceState
                        targetPseudoState:(TBSMPseudoState *)targetPseudoState
                             action:(TBSMActionBlock)action
                              guard:(TBSMGuardBlock)guard
{
    self = [super init];
    if (self) {
        self.sourceState = sourceState;
        self.targetPseudoState = targetPseudoState;
        self.targetState = targetPseudoState.targetState;
        self.action = action;
        self.guard = guard;
    }
    return self;
}

- (BOOL)performTransitionWithData:(NSDictionary *)data
{
    if (self.guard == nil || self.guard(self.sourceState, self.targetState, data)) {
        if ([self.targetPseudoState isKindOfClass:[TBSMFork class]]) {
            TBSMFork *fork = (TBSMFork *)self.targetPseudoState;
            TBSMStateMachine *lca = [self findLeastCommonAncestor];
            [lca switchState:self.sourceState targetStates:fork.targetStates region:(TBSMParallelState *)fork.targetState action:self.action data:data];
        } else if ([self.targetPseudoState isKindOfClass:[TBSMJoin class]]) {
            TBSMJoin *join = (TBSMJoin *)self.targetPseudoState;
            if ([join joinSourceState:self.sourceState]) {
                TBSMStateMachine *lca = [self findLeastCommonAncestor];
                [lca switchState:self.sourceState targetState:self.targetState action:self.action data:data];
            }
        }
        return YES;
    }
    return NO;
}

@end
