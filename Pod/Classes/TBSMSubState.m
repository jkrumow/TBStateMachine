//
//  TBSMSubState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMSubState.h"
#import "TBSMStateMachine.h"
#import "NSException+TBStateMachine.h"


@implementation TBSMSubState

+ (TBSMSubState *)subStateWithName:(NSString *)name
{
    return [[TBSMSubState alloc] initWithName:name];
}

- (void)setStateMachine:(TBSMStateMachine *)stateMachine
{
    if ([stateMachine isKindOfClass:[TBSMStateMachine class]]) {
        _stateMachine = stateMachine;
        [_stateMachine setParentNode:self];
    } else {
        @throw ([NSException tb_notAStateMachineException:stateMachine]);
    }
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    if (self.stateMachine == nil) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    [super enter:sourceState targetState:targetState data:data];
    [_stateMachine enter:sourceState targetState:targetState data:data];
}

- (void)enter:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region data:(NSDictionary *)data
{
    if (self.stateMachine == nil) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    [super enter:sourceState targetState:region data:data];
    [_stateMachine enter:sourceState targetStates:targetStates region:region data:data];
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    if (self.stateMachine == nil) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    [_stateMachine tearDown:data];
    [super exit:sourceState targetState:targetState data:data];
}

- (BOOL)handleEvent:(TBSMEvent *)event
{
    return [_stateMachine handleEvent:event];
}

@end
