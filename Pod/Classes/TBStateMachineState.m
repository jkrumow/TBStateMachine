//
//  TBStateMachineState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineState.h"
#import "NSException+TBStateMachine.h"
#import "TBStateMachineEventHandler.h"
#import "TBStateMachine.h"

@interface TBStateMachineState ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) TBStateMachine *parentState;

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

- (void)registerEvent:(TBStateMachineEvent *)event target:(id<TBStateMachineNode>)target
{
    [self registerEvent:event target:target action:nil guard:nil];
}

- (void)registerEvent:(TBStateMachineEvent *)event target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action
{
    [self registerEvent:event target:target action:action guard:nil];
}

- (void)registerEvent:(TBStateMachineEvent *)event target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard
{
    TBStateMachineEventHandler *eventHandler = [TBStateMachineEventHandler eventHandlerWithName:event.name target:target action:action guard:guard];
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

- (void)enter:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data
{
    if (_enterBlock) {
        _enterBlock(sourceState, data);
    }
}

- (void)exit:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState data:(NSDictionary *)data
{
    if (_exitBlock) {
        _exitBlock(destinationState, data);
    }
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event
{
    return [self handleEvent:event data:nil];
}

- (TBStateMachineTransition *)handleEvent:(TBStateMachineEvent *)event data:(NSDictionary *)data
{
    if ([self _canHandleEvent:event]) {
        TBStateMachineEventHandler *eventHandler = [_eventHandlers objectForKey:event.name];
        return [TBStateMachineTransition transitionWithSourceState:self destinationState:eventHandler.target action:eventHandler.action guard:eventHandler.guard];
    }
    return nil;
}

@end
