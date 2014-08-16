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
    @synchronized(self) {
        for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
            [stateMachineNode enter:previousState data:data];
        }
    }
}

- (void)exit:(id<TBStateMachineNode>)nextState data:(NSDictionary *)data
{
    @synchronized(self) {
        for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
            [stateMachineNode exit:nextState data:data];
        }
    }
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    TBStateMachineTransition *nextTransition = nil;
    
    @synchronized(self) {
        for (id<TBStateMachineNode> stateMachineNode in _priv_parallelStates) {
            
            TBStateMachineTransition *transition = [stateMachineNode handleEvent:event data:data];
            if (transition.destinationState && nextTransition == nil) {
                nextTransition = transition;
            }
        }
    }
    
    // return follow-up state.
    return nextTransition;
}


@end
