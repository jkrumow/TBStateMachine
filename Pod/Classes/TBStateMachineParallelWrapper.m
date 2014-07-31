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

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *priv_parallelStates;
@property (nonatomic, strong) NSOperationQueue *parallelQueue;

@end

@implementation TBStateMachineParallelWrapper

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _priv_parallelStates = [[NSMutableArray alloc] init];
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

- (NSString *)stateName
{
	return _name;
}

- (void)enter:(id<TBStateMachineNode>)previousState transition:(TBStateMachineTransition *)transition
{
	for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
        [stateMachineNode enter:previousState transition:transition];
    }
}

- (void)exit:(id<TBStateMachineNode>)nextState transition:(TBStateMachineTransition *)transition
{
	for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
        [stateMachineNode exit:nextState transition:transition];
    }
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    TBStateMachineTransition *nextParentTransition = nil;
    for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
        
        // first come first serve
        nextParentTransition = [stateMachineNode handleEvent:event];
    }
    // return first parent state
    return nextParentTransition;
}


@end
