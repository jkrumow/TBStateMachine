//
//  TBSMParallelState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMParallelState.h"
#import "TBSMStateMachine.h"
#import "NSException+TBStateMachine.h"

@interface TBSMParallelState ()
@property (nonatomic, strong) NSMutableArray *priv_parallelStateMachines;
@end

@implementation TBSMParallelState

@synthesize parentVertex = _parentVertex;

+ (instancetype)parallelStateWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
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
        if (![stateMachine isKindOfClass:[TBSMStateMachine class]]) {
            @throw ([NSException tb_notAStateMachineException:stateMachine]);
        }
        stateMachine.parentVertex = self;
        [self.priv_parallelStateMachines addObject:stateMachine];
    }
}

- (void)setStates:(NSArray <NSArray<__kindof TBSMState *> *> *)states;
{
    NSMutableArray *stateMachines = [NSMutableArray new];
    [states enumerateObjectsUsingBlock:^(NSArray<__kindof TBSMState *> *array, NSUInteger idx, BOOL *stop) {
        NSString *name = [NSString stringWithFormat:@"%@SubMachine-%lu",self.name, (unsigned long)idx];
        TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:name];
        stateMachine.states = array;
        [stateMachines addObject:stateMachine];
    }];
    [self setStateMachines:stateMachines];
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [super enter:sourceState targetState:targetState data:data];
    
    if (self.priv_parallelStateMachines.count == 0) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
        if ([targetState.path containsObject:stateMachine]) {
            [stateMachine enter:sourceState targetState:targetState data:data];
        } else {
            [stateMachine setUp:data];
        }
    }
}

- (void)enter:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region data:(id)data
{
    [super enter:sourceState targetState:region data:data];
    
    if (self.priv_parallelStateMachines.count == 0) {
        @throw [NSException tb_missingStateMachineException:self.name];
    }
    for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
        BOOL isEntered = NO;
        for (TBSMState *targetState in targetStates) {
            if ([targetState.path containsObject:stateMachine]) {
                [stateMachine enter:sourceState targetState:targetState data:data];
                isEntered = YES;
            }
        }
        if (!isEntered) {
            [stateMachine setUp:data];
        }
    }
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
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
