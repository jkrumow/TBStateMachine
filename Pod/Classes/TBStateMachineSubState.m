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

#pragma mark - TBStateMachineNode

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
    return nil; // [_stateMachine _handleEvent:event data:data];
}



@end
