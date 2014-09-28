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

@interface TBSMSubState ()

@end

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

#pragma mark - TBSMNode

- (void)setStateMachine:(TBSMStateMachine *)stateMachine
{
    _stateMachine = stateMachine;
    [_stateMachine setParentState:self.parentState];
}

- (void)setParentState:(id<TBSMNode>)parentState
{
    [super setParentState:parentState];
    [_stateMachine setParentState:self];
}

- (void)enter:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    [super enter:sourceState destinationState:destinationState data:data];
    
    if (destinationState == self) {
        [_stateMachine setUp];
    } else {
        [_stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
    }
}

- (void)exit:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    if (destinationState == nil) {
        [_stateMachine tearDown];
    } else {
        [_stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
    }
    
    [super exit:sourceState destinationState:destinationState data:data];
}

- (TBSMTransition *)handleEvent:(TBSMEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBSMTransition *)handleEvent:(TBSMEvent *)event data:(NSDictionary *)data
{
    [_stateMachine handleEvent:event data:data];
    return [super handleEvent:event data:data];
    // TODO: check what needs to happen: who handles to event first: the statemachine or self.
}



@end
