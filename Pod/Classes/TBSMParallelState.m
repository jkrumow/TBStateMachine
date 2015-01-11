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

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t parallelQueue;
#else
@property (nonatomic, assign) dispatch_queue_t parallelQueue;
#endif

@end

@implementation TBSMParallelState

@synthesize parentState = _parentState;

+ (TBSMParallelState *)parallelStateWithName:(NSString *)name
{
    return [[TBSMParallelState alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _priv_parallelStateMachines = [NSMutableArray new];
        _parallelQueue = dispatch_queue_create("com.tarbrain.TBStateMachine.ParallelStateQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(self.parallelQueue);
    self.parallelQueue = nil;
#endif
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

#pragma mark - TBSMNode

- (void)setParentState:(id<TBSMNode>)parentState
{
    _parentState = parentState;
    for (TBSMStateMachine *subMachine in self.priv_parallelStateMachines) {
        subMachine.parentState = self;
    }
}

- (void)enter:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    [super enter:sourceState destinationState:destinationState data:data];
    
    dispatch_apply(self.priv_parallelStateMachines.count, self.parallelQueue, ^(size_t idx) {
        
        TBSMStateMachine *stateMachine = self.priv_parallelStateMachines[idx];
        if ([destinationState.getPath containsObject:stateMachine]) {
            [stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
        } else {
            [stateMachine setUp];
        }
    });
}

- (void)exit:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    dispatch_apply(self.priv_parallelStateMachines.count, self.parallelQueue, ^(size_t idx) {
        
        TBSMStateMachine *stateMachine = self.priv_parallelStateMachines[idx];
        if (destinationState == nil) {
            [stateMachine tearDown];
        } else {
            [stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
        }
    });
    
    [super exit:sourceState destinationState:destinationState data:data];
}

- (TBSMTransition *)handleEvent:(TBSMEvent *)event
{
    __block TBSMTransition *transition = nil;
    dispatch_apply(self.priv_parallelStateMachines.count, self.parallelQueue, ^(size_t idx) {
        
        TBSMStateMachine *stateMachine = self.priv_parallelStateMachines[idx];
        transition = [stateMachine handleEvent:event];
    });
    if (transition) {
        return nil;
    }
    return [super handleEvent:event];
}

@end
