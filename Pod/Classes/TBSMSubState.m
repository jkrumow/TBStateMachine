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

+ (TBSMSubState *)subStateWithName:(NSString *)name stateMachine:(TBSMStateMachine *)stateMachine
{
    return [[TBSMSubState alloc] initWithName:name stateMachine:stateMachine];
}

- (instancetype)initWithName:(NSString *)name stateMachine:(TBSMStateMachine *)stateMachine
{
    if (stateMachine == nil) {
        @throw [NSException tb_missingStateMachineException:name];
    }
    self = [super initWithName:name];
    if (self) {
        self.stateMachine = stateMachine;
    }
    return self;
}

- (void)setStateMachine:(TBSMStateMachine *)stateMachine
{
    _stateMachine = stateMachine;
    [_stateMachine setParentNode:self.parentNode];
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    [super enter:sourceState targetState:targetState data:data];
    [_stateMachine enterState:sourceState targetState:targetState data:data];
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    [_stateMachine tearDown:data];
    [super exit:sourceState targetState:targetState data:data];
}

- (BOOL)handleEvent:(TBSMEvent *)event
{
    return [_stateMachine handleEvent:event];
}

#pragma mark - TBSMNode

- (void)setParentNode:(id<TBSMNode>)parentNode
{
    [super setParentNode:parentNode];
    [_stateMachine setParentNode:self];
}

@end
