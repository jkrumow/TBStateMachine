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
@property (nonatomic, assign) dispatch_queue_t parallelQueue;

@end

@implementation TBStateMachineParallelWrapper

+ (TBStateMachineParallelWrapper *)parallelWrapperWithName:(NSString *)name;
{
	return [[TBStateMachineParallelWrapper alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name.copy;
        _priv_parallelStates = [NSMutableArray new];
        _parallelQueue = dispatch_queue_create("com.tarbrain.TBStateMachine.ParallelWrapperQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)setStates:(NSArray *)states
{
    [_priv_parallelStates removeAllObjects];
    
    for (id object in states) {
        if ([object conformsToProtocol:@protocol(TBStateMachineNode)])  {
            id<TBStateMachineNode> stateMachineNode = object;
            [_priv_parallelStates addObject:stateMachineNode];
        } else {
            @throw ([NSException tb_doesNotConformToNodeProtocolException:object]);
        }
    }
}

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
