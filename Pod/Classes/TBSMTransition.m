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
                             destinationState:(TBSMState *)destinationState
                                         type:(TBSMTransitionType)type
                                       action:(TBSMActionBlock)action
                                        guard:(TBSMGuardBlock)guard
{
    return [[TBSMTransition alloc] initWithSourceState:sourceState destinationState:destinationState type:type action:action guard:guard];
}

- (instancetype)initWithSourceState:(TBSMState *)sourceState
                   destinationState:(TBSMState *)destinationState
                               type:(TBSMTransitionType)type
                             action:(TBSMActionBlock)action
                              guard:(TBSMGuardBlock)guard
{
    self = [super init];
    if (self) {
        _sourceState = sourceState;
        _destinationState = destinationState;
        _type = type;
        _action = action;
        _guard = guard;
    }
    return self;
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ --> %@", _sourceState.name, _destinationState.name];
}

@end
