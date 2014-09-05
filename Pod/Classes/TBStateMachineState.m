//
//  TBStateMachineState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineState.h"
#import "NSException+TBStateMachine.h"

@interface TBStateMachineState ()

@property (nonatomic, copy) NSString *name;

- (BOOL)_canHandleEvent:(TBStateMachineEvent *)event;

@end

@implementation TBStateMachineState

+ (TBStateMachineState *)stateWithName:(NSString *)name;
{
    return [[TBStateMachineState alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForNodeException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
        _eventHandlers = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerEvent:(TBStateMachineEvent *)event target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action
{
    
    NSMutableDictionary *eventHandler = [NSMutableDictionary new];
    if (target) {
        eventHandler[@"target"] = target;
    }
    eventHandler[@"action"] = action;
    [_eventHandlers setObject:eventHandler forKey:event.name];
}

- (void)unregisterEvent:(TBStateMachineEvent *)event;
{
    [_eventHandlers removeObjectForKey:event.name];
}

#pragma mark - private methods

- (BOOL)_canHandleEvent:(TBStateMachineEvent *)event
{
    return ([_eventHandlers objectForKey:event.name] != nil);
}

#pragma mark - TBStateMachineNode

- (void)enter:(id<TBStateMachineNode>)previousState data:(NSDictionary *)data
{
    if (_enterBlock) {
        _enterBlock(previousState, data);
    }
}

- (void)exit:(id<TBStateMachineNode>)nextState data:(NSDictionary *)data
{
    if (_exitBlock) {
        _exitBlock(nextState, data);
    }
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    if ([self _canHandleEvent:event]) {
        NSDictionary *eventHandler = [_eventHandlers objectForKey:event.name];
        TBStateMachineActionBlock action = eventHandler[@"action"];
        if (action) {
            action(event, data);
        }
        id<TBStateMachineNode> nextState = eventHandler[@"target"];
        return [TBStateMachineTransition transitionWithSourceState:self destinationState:nextState];
    }
    return nil;
}

@end
