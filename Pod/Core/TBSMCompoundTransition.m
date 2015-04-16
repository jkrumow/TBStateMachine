//
//  TBSMCompoundTransition.m
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
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

- (NSString *)name
{
    NSString *source = nil;
    NSString *target = nil;
    if ([self.targetPseudoState isKindOfClass:[TBSMJoin class]]) {
        TBSMJoin *join = (TBSMJoin *)self.targetPseudoState;
        source = [NSString stringWithFormat:@"[%@](%@)", [[join.sourceStates valueForKeyPath:@"name"] componentsJoinedByString:@","], join.region.name];
        target = self.targetState.name;
    }
    if ([self.targetPseudoState isKindOfClass:[TBSMFork class]]) {
        TBSMFork *fork = (TBSMFork *)self.targetPseudoState;
        source = self.sourceState.name;
        target = [NSString stringWithFormat:@"[%@](%@)", [[fork.targetStates valueForKeyPath:@"name"] componentsJoinedByString:@","], fork.region.name];
    }
    return [NSString stringWithFormat:@"%@ --> %@ --> %@", source, self.targetPseudoState.name, target];
}

- (BOOL)performTransitionWithData:(NSDictionary *)data
{
    if (self.guard == nil || self.guard(self.sourceState, self.targetState, data)) {
        if ([self.targetPseudoState isKindOfClass:[TBSMFork class]]) {
            [self _performForkTransitionWithData:data];
        } else if ([self.targetPseudoState isKindOfClass:[TBSMJoin class]]) {
            [self _performJoinTransitionWithData:data];
        }
        return YES;
    }
    return NO;
}

- (void)_performForkTransitionWithData:(NSDictionary *)data
{
    TBSMFork *fork = (TBSMFork *)self.targetPseudoState;
    [self _validatePseudoState:fork states:fork.targetStates region:fork.region];
    TBSMStateMachine *lca = [self findLeastCommonAncestor];
    [lca switchState:self.sourceState targetStates:fork.targetStates region:(TBSMParallelState *)fork.targetState action:self.action data:data];
}

- (void)_performJoinTransitionWithData:(NSDictionary *)data
{
    TBSMJoin *join = (TBSMJoin *)self.targetPseudoState;
    [self _validatePseudoState:join states:join.sourceStates region:join.region];
    if ([join joinSourceState:self.sourceState]) {
        TBSMStateMachine *lca = [self findLeastCommonAncestor];
        [lca switchState:self.sourceState targetState:self.targetState action:self.action data:data];
    } else {
        if (self.action) {
            self.action(self.sourceState, self.targetState, data);
        }
    }
}

- (void)_validatePseudoState:(TBSMPseudoState *)pseudoState states:(NSArray *)states region:(TBSMParallelState *)region
{
    for (TBSMState *state in states) {
        if (![state.path containsObject:region]) {
            @throw [NSException tb_ambiguousCompoundTransitionAttributes:pseudoState.name];
        }
    }
}

@end
