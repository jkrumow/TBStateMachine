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
            id<TBStateMachineNode> stateMachineNode = object;
            [_priv_parallelStates addObject:stateMachineNode];
        } else {
            @throw ([NSException tb_notAStateMachineException:object]);
        }
    }
}

#pragma mark - TBStateMachineNode

- (void)enter:(id<TBStateMachineNode>)previousState data:(NSDictionary *)data
{
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        id<TBStateMachineNode> stateMachineNode = _priv_parallelStates[idx];
        [stateMachineNode enter:previousState data:data];
    });
}

- (void)exit:(id<TBStateMachineNode>)nextState data:(NSDictionary *)data
{
    dispatch_apply(_priv_parallelStates.count, _parallelQueue, ^(size_t idx) {
        
        id<TBStateMachineNode> stateMachineNode = _priv_parallelStates[idx];
        [stateMachineNode exit:nextState data:data];
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
