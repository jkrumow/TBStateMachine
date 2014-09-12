//
//  TBStateMachineParallelWrapper.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineParallelWrapper.h"
#import "TBStateMachine.h"
#import "NSException+TBStateMachine.h"

@interface TBStateMachineParallelWrapper ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) TBStateMachine *parentState;
@property (nonatomic, strong) NSMutableArray *priv_parallelStates;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t parallelQueue;
#else
@property (nonatomic, assign) dispatch_queue_t parallelQueue;
#endif

@end

@implementation TBStateMachineParallelWrapper

+ (TBStateMachineParallelWrapper *)parallelWrapperWithName:(NSString *)name;
{
    return [[TBStateMachineParallelWrapper alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForNodeException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
        _priv_parallelStates = [NSMutableArray new];
        _parallelQueue = dispatch_queue_create("com.tarbrain.TBStateMachine.ParallelWrapperQueue", DISPATCH_QUEUE_CONCURRENT);
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

- (NSArray *)getPath
{
    NSMutableArray *path = [NSMutableArray new];
    TBStateMachine *node = self.parentState;
    while (node) {
        [path insertObject:node atIndex:0];
        node = node.parentState;
    }
    return path;
}

#pragma mark - TBStateMachineNode

- (void)setParentState:(TBStateMachine *)parentState
{
    _parentState = parentState;
    for (id<TBStateMachineNode> node in _priv_parallelStates) {
        node.parentState = _parentState;
    }
}

- (void)enter:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data
{
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        TBStateMachine *stateMachine = _priv_parallelStates[idx];
        if (destinationState == nil || self) {
            [stateMachine setUp];
        } else {
            [stateMachine exit:sourceState destinationState:destinationState data:data];
        }
    });
}

- (void)exit:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data
{
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        TBStateMachine *stateMachine = _priv_parallelStates[idx];
        if (destinationState == nil) {
            [stateMachine tearDown];
        } else {
            [stateMachine exit:sourceState destinationState:destinationState data:data];
        }
    });
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    __block TBStateMachineTransition *nextTransition = nil;
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        id<TBStateMachineNode> stateMachineNode = _priv_parallelStates[idx];
        TBStateMachineTransition *transition = [stateMachineNode handleEvent:event data:data];
        if (transition.destinationState && nextTransition == nil) {
            nextTransition = transition;
        }
    });
    
    // return follow-up state.
    return nextTransition;
}

@end
