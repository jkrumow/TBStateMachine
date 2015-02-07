//
//  TBSMTransition.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMTransition.h"
#import "TBSMState.h"
#import "TBSMStateMachine.h"

@implementation TBSMTransition

+ (TBSMTransition *)transitionWithSourceState:(TBSMState *)sourceState
                                  targetState:(TBSMState *)targetState
                                         kind:(TBSMTransitionKind)kind
                                       action:(TBSMActionBlock)action
                                        guard:(TBSMGuardBlock)guard
{
    return [[TBSMTransition alloc] initWithSourceState:sourceState targetState:targetState kind:kind action:action guard:guard];
}

- (instancetype)initWithSourceState:(TBSMState *)sourceState
                        targetState:(TBSMState *)targetState
                               kind:(TBSMTransitionKind)kind
                             action:(TBSMActionBlock)action
                              guard:(TBSMGuardBlock)guard
{
    self = [super init];
    if (self) {
        _sourceState = sourceState;
        _targetState = targetState;
        _kind = kind;
        _action = action;
        _guard = guard;
    }
    return self;
}

- (TBSMStateMachine *)_findLeastCommonAncestor
{
    NSArray *sourcePath = [self.sourceState path];
    NSArray *destinationPath = [self.targetState path];
    
    __block TBSMStateMachine *lca = nil;
    [sourcePath enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TBSMStateMachine class]]) {
            if ([destinationPath containsObject:obj]) {
                lca = (TBSMStateMachine *)obj;
                *stop = YES;
            }
        }
    }];
    
    if (self.kind == TBSMTransitionLocal) {
        if ([self.sourceState.path containsObject:self.targetState] || [self.targetState.path containsObject:self.sourceState]) {
            TBSMSubState *containingSubState = (TBSMSubState *)lca.currentState;
            lca = containingSubState.stateMachine;
        } else {
            lca = nil;
        }
    }
    if (!lca) {
        @throw [NSException tb_noLcaForTransition:self.name];
    }
    return lca;
}

- (BOOL)performTransitionWithData:(NSDictionary *)data
{
    if (self.guard == nil || self.guard(self.sourceState, self.targetState, data)) {
        if (self.kind == TBSMTransitionInternal) {
            if (self.action) {
                self.action(self.sourceState, self.targetState, data);
            }
        } else {
            TBSMStateMachine *lca = [self _findLeastCommonAncestor];
            [lca switchState:self.sourceState targetState:self.targetState action:self.action data:data];
        }
        return YES;
    }
    return NO;
}

- (NSString *)name
{
    if (self.targetState == nil) {
        return self.sourceState.name;
    }
    return [NSString stringWithFormat:@"%@_to_%@", self.sourceState.name, self.targetState.name];
}

@end
