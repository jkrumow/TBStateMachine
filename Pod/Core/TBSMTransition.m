//
//  TBSMTransition.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMTransition.h"
#import "TBSMState.h"
#import "TBSMStateMachine.h"

@implementation TBSMTransition

- (instancetype)initWithSourceState:(TBSMState *)sourceState
                        targetState:(TBSMState *)targetState
                               kind:(TBSMTransitionKind)kind
                             action:(TBSMActionBlock)action
                              guard:(TBSMGuardBlock)guard
{
    self = [super init];
    if (self) {
        self.sourceState = sourceState;
        self.targetState = targetState;
        self.kind = kind;
        self.action = action;
        self.guard = guard;
    }
    return self;
}

- (NSString *)name
{
    if (self.targetState == nil) {
        return self.sourceState.name;
    }
    return [NSString stringWithFormat:@"%@ --> %@", self.sourceState.name, self.targetState.name];
}

- (TBSMStateMachine *)findLeastCommonAncestor
{
    NSArray *sourcePath = [self.sourceState path];
    NSArray *targetPath = [self.targetState path];
    
    __block TBSMStateMachine *lca = nil;
    [sourcePath enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TBSMStateMachine class]]) {
            if ([targetPath containsObject:obj]) {
                lca = (TBSMStateMachine *)obj;
                *stop = YES;
            }
        }
    }];
    
    if (self.kind == TBSMTransitionLocal) {
        if ([self.sourceState.path containsObject:self.targetState] || [self.targetState.path containsObject:self.sourceState]) {
            TBSMSubState *containingSubState = (TBSMSubState *)lca.currentState;
            lca = containingSubState.stateMachine;
        }
    }
    if (!lca) {
        @throw [NSException tb_noLcaForTransition:self.name];
    }
    return lca;
}

- (BOOL)performTransitionWithData:(id)data
{
    if (self.guard == nil || self.guard(self.sourceState, self.targetState, data)) {
        if (self.kind == TBSMTransitionInternal) {
            if (self.action) {
                self.action(self.sourceState, self.targetState, data);
            }
        } else {
            TBSMStateMachine *lca = [self findLeastCommonAncestor];
            [lca switchState:self.sourceState targetState:self.targetState action:self.action data:data];
        }
        return YES;
    }
    return NO;
}

@end
