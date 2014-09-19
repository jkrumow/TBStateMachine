//
//  TBStateMachineSubState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineSubState.h"
#import "NSException+TBStateMachine.h"

@interface TBStateMachineSubState ()

@property (nonatomic, strong) TBStateMachine *stateMachine;

@end

@implementation TBStateMachineSubState


+ (TBStateMachineSubState *)subStateWithName:(NSString *)name stateMachine:(TBStateMachine *)stateMachine
{
    return [[TBStateMachineSubState alloc] initWithName:name stateMachine:stateMachine];
}

- (instancetype)initWithName:(NSString *)name stateMachine:(TBStateMachine *)stateMachine
{
    self = [super initWithName:name];
    if (self) {
        _stateMachine = stateMachine;
    }
    return self;
}

@end
