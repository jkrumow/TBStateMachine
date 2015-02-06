//
//  TBSMTransition.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMTransition.h"
#import "TBSMState.h"

@implementation TBSMTransition

+ (TBSMTransition *)transitionWithSourceState:(TBSMState *)sourceState
                                  targetState:(TBSMState *)targetState
                                         kind:(TBSMTransitionKind)kind
                                       action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
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

- (NSString *)name
{
    if (self.targetState == nil) {
        return self.sourceState.name;
    }
    return [NSString stringWithFormat:@"%@_to_%@", self.sourceState.name, self.targetState.name];
}

@end
