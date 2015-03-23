//
//  TBSMParallelState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMParallelState.h"
#import "TBSMStateMachine.h"
#import "NSException+TBStateMachine.h"

@interface TBSMParallelState ()
@property (nonatomic, strong) NSMutableArray *priv_parallelStateMachines;
@end

@implementation TBSMParallelState

@synthesize parentNode = _parentNode;

+ (TBSMParallelState *)parallelStateWithName:(NSString *)name
{
    return [[TBSMParallelState alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _priv_parallelStateMachines = [NSMutableArray new];
    }
    return self;
}

- (NSArray *)stateMachines
{
    return [NSArray arrayWithArray:self.priv_parallelStateMachines];
}

- (void)setStateMachines:(NSArray *)stateMachines
{
    [self.priv_parallelStateMachines removeAllObjects];
    
    for (TBSMStateMachine *stateMachine in stateMachines) {
        if ([stateMachine isKindOfClass:[TBSMStateMachine class]]) {
            stateMachine.parentNode = self;
            [self.priv_parallelStateMachines addObject:stateMachine];
        } else {
            @throw ([NSException tb_notAStateMachineException:stateMachine]);
        }
    }
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    [super enter:sourceState targetState:targetState data:data];
    
    if (self.priv_parallelStateMachines.count == 0) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
        if ([targetState.path containsObject:stateMachine]) {
            [stateMachine enterState:sourceState targetState:targetState data:data];
        } else {
            [stateMachine setUp:data];
        }
    }
}

- (void)enter:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region data:(NSDictionary *)data
{
    [super enter:sourceState targetState:region data:data];
    
    if (self.priv_parallelStateMachines.count == 0) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
        BOOL isEntered = NO;
        for (TBSMState *targetState in targetStates) {
            if ([targetState.path containsObject:stateMachine]) {
                [stateMachine enterState:sourceState targetState:targetState data:data];
                isEntered = YES;
            }
        }
        if (!isEntered) {
            [stateMachine setUp:data];
        }
    }
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    if (self.priv_parallelStateMachines.count == 0) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
        [stateMachine tearDown:data];
    }
    [super exit:sourceState targetState:targetState data:data];
}

- (BOOL)handleEvent:(TBSMEvent *)event
{
    BOOL didHandleEvent = NO;
    for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
        if ([stateMachine handleEvent:event]) {
            didHandleEvent = YES;
        }
    }
    return didHandleEvent;
}

@end
