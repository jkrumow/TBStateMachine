//
//  TBStateMachineTransition.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineTransition.h"
#import "TBStateMachineNode.h"

@implementation TBStateMachineTransition

+ (TBStateMachineTransition *)transitionWithSourceState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard
{
    return [[TBStateMachineTransition alloc] initWithSourceState:sourceState destinationState:destinationState action:action guard:guard];
}

- (instancetype)initWithSourceState:()sourceState destinationState:()destinationState action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard
{
    self = [super init];
    if (self) {
        _sourceState = sourceState;
        _destinationState = destinationState;
        _action = action;
        _guard = guard;
    }
    return self;
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@-->%@", _sourceState.name, _destinationState.name];
}

@end
