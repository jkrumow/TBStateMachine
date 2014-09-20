//
//  TBStateMachineSubState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineSubState.h"
#import "TBSTateMachine.h"
#import "NSException+TBStateMachine.h"

@interface TBStateMachineSubState ()

@end

@implementation TBStateMachineSubState


+ (TBStateMachineSubState *)subStateWithName:(NSString *)name stateMachine:(TBStateMachine *)stateMachine
{
    return [[TBStateMachineSubState alloc] initWithName:name stateMachine:stateMachine];
}

- (instancetype)initWithName:(NSString *)name stateMachine:(TBStateMachine *)stateMachine
{
    if (stateMachine == nil) {
        @throw [NSException tb_missingStateMachineException:name];
    }
    self = [super initWithName:name];
    if (self) {
        _stateMachine = stateMachine;
    }
    return self;
}

#pragma mark - TBStateMachineNode

- (void)setStateMachine:(TBStateMachine *)stateMachine
{
    [_stateMachine setParentState:self.parentState];
}

- (void)setParentState:(id<TBStateMachineNode>)parentState
{
    [super setParentState:parentState];
    [_stateMachine setParentState:self];
}

- (void)enter:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState data:(NSDictionary *)data
{
    if (destinationState == self) {
        [_stateMachine setUp];
    } else {
        [_stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
    }
}

- (void)exit:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState data:(NSDictionary *)data
{
    if (destinationState == nil) {
        [_stateMachine tearDown];
    } else {
        [_stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
    }
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    // TODO: check what needs to happen: who handles to event first: the statemachine or self.
    return [_stateMachine handleEvent:event data:data];
}



@end
