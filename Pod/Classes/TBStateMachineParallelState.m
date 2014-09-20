//
//  TBStateMachineParallelState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineParallelState.h"
#import "TBStateMachine.h"
#import "NSException+TBStateMachine.h"

@interface TBStateMachineParallelState ()

@property (nonatomic, strong) NSMutableArray *priv_parallelStates;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t parallelQueue;
#else
@property (nonatomic, assign) dispatch_queue_t parallelQueue;
#endif

@end

@implementation TBStateMachineParallelState

@synthesize parentState = _parentState;

+ (TBStateMachineParallelState *)parallelStateWithName:(NSString *)name
{
    return [[TBStateMachineParallelState alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _priv_parallelStates = [NSMutableArray new];
        _parallelQueue = dispatch_queue_create("com.tarbrain.TBStateMachine.ParallelStateQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_parallelQueue);
    _parallelQueue = nil;
#endif
}

- (NSArray *)states
{
    return [NSArray arrayWithArray:_priv_parallelStates];
}

- (void)setStates:(NSArray *)states
{
    [_priv_parallelStates removeAllObjects];
    
    for (id object in states) {
        if ([object isKindOfClass:[TBStateMachine class]]) {
            [_priv_parallelStates addObject:object];
        } else {
            @throw ([NSException tb_notAStateMachineException:object]);
        }
    }
}

#pragma mark - TBStateMachineNode

- (void)setParentState:(id<TBStateMachineNode>)parentState
{
    _parentState = parentState;
    for (TBStateMachine *subMachine in _priv_parallelStates) {
        subMachine.parentState = self;
    }
}

- (void)enter:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState data:(NSDictionary *)data
{
    [super enter:sourceState destinationState:destinationState data:data];
    
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        TBStateMachine *stateMachine = _priv_parallelStates[idx];
        if (destinationState == nil || destinationState == self) {
            [stateMachine setUp];
        } else {
            [stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
        }
    });
}

- (void)exit:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState data:(NSDictionary *)data
{
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        TBStateMachine *stateMachine = _priv_parallelStates[idx];
        if (destinationState == nil) {
            [stateMachine tearDown];
        } else {
            [stateMachine switchState:sourceState destinationState:destinationState data:data action:nil];
        }
    });
    
    [super exit:sourceState destinationState:destinationState data:data];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    __block TBStateMachineTransition *nextTransition = nil;
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        TBStateMachine *stateMachine = _priv_parallelStates[idx];
        TBStateMachineTransition *transition = [stateMachine handleEvent:event data:data];
        if (transition.destinationState && nextTransition == nil) {
            nextTransition = transition;
        }
    });
    
    if (nextTransition) {
        // return follow-up state.
        return nextTransition;
    } else {
        return [super handleEvent:event data:data];
    }
}

@end
