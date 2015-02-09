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
    
    for (id object in stateMachines) {
        if ([object isKindOfClass:[TBSMStateMachine class]]) {
            [self.priv_parallelStateMachines addObject:object];
        } else {
            @throw ([NSException tb_notAStateMachineException:object]);
        }
    }
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    [super enter:sourceState targetState:targetState data:data];
    
    for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
        if ([targetState.path containsObject:stateMachine]) {
            [stateMachine enterState:sourceState targetState:targetState data:data];
        } else {
            [stateMachine setUp:data];
        }
    }
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
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

#pragma mark - TBSMNode

- (void)setParentNode:(id<TBSMNode>)parentNode
{
    _parentNode = parentNode;
    for (TBSMStateMachine *subMachine in self.priv_parallelStateMachines) {
        subMachine.parentNode = self;
    }
}

@end
