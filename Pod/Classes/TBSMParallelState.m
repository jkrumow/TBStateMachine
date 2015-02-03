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
        _parallelQueue = nil;
    }
    return self;
}

- (void)dealloc
{
    self.parallelQueue = nil;
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

- (void)enter:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    [super enter:sourceState destinationState:destinationState data:data];
    
    if (self.parallelQueue) {
        dispatch_apply(self.priv_parallelStateMachines.count, self.parallelQueue, ^(size_t idx) {
            
            TBSMStateMachine *stateMachine = self.priv_parallelStateMachines[idx];
            if ([destinationState.path containsObject:stateMachine]) {
                [stateMachine enterState:sourceState destinationState:destinationState data:data];
            } else {
                [stateMachine setUp:data];
            }
        });
    } else {
        for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
            if ([destinationState.path containsObject:stateMachine]) {
                [stateMachine enterState:sourceState destinationState:destinationState data:data];
            } else {
                [stateMachine setUp:data];
            }
        }
    }
}

- (void)exit:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    if (self.parallelQueue) {
        dispatch_apply(self.priv_parallelStateMachines.count, self.parallelQueue, ^(size_t idx) {
            
            TBSMStateMachine *stateMachine = self.priv_parallelStateMachines[idx];
            if ([destinationState.path containsObject:stateMachine]) {
                [stateMachine exitState:sourceState destinationState:destinationState data:data];
            } else {
                [stateMachine tearDown:data];
            }
        });
    } else {
        for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
            if ([destinationState.path containsObject:stateMachine]) {
                [stateMachine exitState:sourceState destinationState:destinationState data:data];
            } else {
                [stateMachine tearDown:data];
            }
        }
    }
    
    [super exit:sourceState destinationState:destinationState data:data];
}

- (BOOL)handleEvent:(TBSMEvent *)event
{
    if (self.parallelQueue) {
        __block BOOL didHandleEvent = NO;
        dispatch_apply(self.priv_parallelStateMachines.count, self.parallelQueue, ^(size_t idx) {
            
            TBSMStateMachine *stateMachine = self.priv_parallelStateMachines[idx];
            if ([stateMachine handleEvent:event]) {
                didHandleEvent = YES;
            }
        });
        return didHandleEvent;
    } else {
        BOOL didHandleEvent = NO;
        for (TBSMStateMachine *stateMachine in self.priv_parallelStateMachines) {
            if ([stateMachine handleEvent:event]) {
                didHandleEvent = YES;
            }
        }
        return didHandleEvent;
    }
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
