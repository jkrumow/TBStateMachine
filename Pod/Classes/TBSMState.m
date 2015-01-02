//
//  TBSMState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMState.h"
#import "NSException+TBStateMachine.h"
#import "TBSMEventHandler.h"

@interface TBSMState ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *priv_eventHandlers;
@property (nonatomic, strong) NSMutableDictionary *priv_deferredEvents;
@end

@implementation TBSMState

+ (TBSMState *)stateWithName:(NSString *)name
{
    return [[TBSMState alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForStateException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
        _priv_eventHandlers = [NSMutableDictionary new];
        _priv_deferredEvents = [NSMutableDictionary new];
    }
    return self;
}

- (NSDictionary *)eventHandlers
{
    return _priv_eventHandlers.copy;
}

- (NSDictionary *)deferredEvents
{
    return _priv_deferredEvents.copy;
}

- (void)registerEvent:(NSString *)event target:(TBSMState *)target
{
    [self registerEvent:event target:target action:nil guard:nil];
}

- (void)registerEvent:(NSString *)event target:(TBSMState *)target action:(TBSMActionBlock)action
{
    [self registerEvent:event target:target action:action guard:nil];
}

- (void)registerEvent:(NSString *)event target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    if ([_priv_deferredEvents objectForKey:event])  {
        @throw [NSException tb_cannotRegisterDeferredEvent:event];
    }
    TBSMEventHandler *eventHandler = [TBSMEventHandler eventHandlerWithName:event target:target action:action guard:guard];
    [_priv_eventHandlers setObject:eventHandler forKey:event];
}

- (void)deferEvent:(NSString *)event
{
    if ([_priv_eventHandlers objectForKey:event])  {
        @throw [NSException tb_cannotDeferRegisteredEvent:event];
    }
    [_priv_deferredEvents setObject:event forKey:event];
}

- (BOOL)canHandleEvent:(TBSMEvent *)event
{
    return ([_priv_eventHandlers objectForKey:event.name] != nil);
}

- (BOOL)canDeferEvent:(TBSMEvent *)event
{
    return ([_priv_deferredEvents objectForKey:event.name] != nil);
}

#pragma mark - TBSMNode

- (NSArray *)getPath
{
    NSMutableArray *path = [NSMutableArray new];
    TBSMState *state = self.parentState;
    while (state) {
        [path insertObject:state atIndex:0];
        state = state.parentState;
    }
    return path;
}

- (void)enter:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    if (_enterBlock) {
        _enterBlock(sourceState, destinationState, data);
    }
}

- (void)exit:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data
{
    if (_exitBlock) {
        _exitBlock(sourceState, destinationState, data);
    }
}

- (TBSMTransition *)handleEvent:(TBSMEvent *)event
{
    if ([self canHandleEvent:event]) {
        TBSMEventHandler *eventHandler = [_priv_eventHandlers objectForKey:event.name];
        return [TBSMTransition transitionWithSourceState:self destinationState:eventHandler.target action:eventHandler.action guard:eventHandler.guard];
    }
    return nil;
}

@end
