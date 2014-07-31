//
//  TBStateMachineState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineState.h"

@interface TBStateMachineState ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) TBStateMachineStateBlock enterBlock;
@property (nonatomic, strong) TBStateMachineStateBlock exitBlock;

- (BOOL)_canHandleEvent:(TBStateMachineEvent *)event;

@end

@implementation TBStateMachineState

+ (TBStateMachineState *)stateWithName:(NSString *)name enterBlock:(TBStateMachineStateBlock)enterBlock exitBlock:(TBStateMachineStateBlock)exitBlock;
{
	TBStateMachineState *state = [[TBStateMachineState alloc] initWithName:name];
    [state setEnterBlock:enterBlock];
    [state setExitBlock:exitBlock];
    return state;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _eventHandlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addEvent:(TBStateMachineEvent *)event handler:(TBStateMachineEventBlock)handler
{
    [_eventHandlers setObject:handler forKey:event.name];
}

- (void)setEnterBlock:(TBStateMachineStateBlock)enterBlock
{
    _enterBlock = enterBlock;
}

- (void)setExitBlock:(TBStateMachineStateBlock)exitBlock
{
    _exitBlock = exitBlock;
}

- (BOOL)_canHandleEvent:(TBStateMachineEvent *)event
{
    return ([_eventHandlers objectForKey:event.name] != nil);
}

#pragma mark - TBStateMachineNode

- (NSString *)stateName
{
    return _name;
}

- (void)enter:(id<TBStateMachineNode>)previousState transition:(TBStateMachineTransition *)transition
{
    if (_enterBlock) {
        _enterBlock(previousState, transition);
    }
}

- (void)exit:(id<TBStateMachineNode>)nextState transition:(TBStateMachineTransition *)transition
{
    if (_exitBlock) {
        _exitBlock(nextState, transition);
    }
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
	if ([self _canHandleEvent:event]) {
        TBStateMachineEventBlock handler = [_eventHandlers objectForKey:event.name];
        id<TBStateMachineNode> nextState = handler(event);
        return [TBStateMachineTransition transitionWithSourceState:self destinationState:nextState];
    }
    return nil;
}

@end
