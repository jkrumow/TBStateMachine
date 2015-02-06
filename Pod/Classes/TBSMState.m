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
    [self registerEvent:event target:target kind:TBSMTransitionExternal];
}

- (void)registerEvent:(NSString *)event target:(TBSMState *)target kind:(TBSMTransitionKind)kind
{
    [self registerEvent:event target:target kind:kind action:nil guard:nil];
}

- (void)registerEvent:(NSString *)event target:(TBSMState *)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action
{
    [self registerEvent:event target:target kind:kind action:action guard:nil];
}

- (void)registerEvent:(NSString *)event target:(TBSMState *)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    if ([_priv_deferredEvents objectForKey:event])  {
        @throw [NSException tb_cannotRegisterDeferredEvent:event];
    }
    TBSMEventHandler *eventHandler = [TBSMEventHandler eventHandlerWithName:event target:target kind:kind action:action guard:guard];
    NSMutableArray *eventHandlers = _priv_eventHandlers[event];
    if (!eventHandlers) {
        eventHandlers = NSMutableArray.new;
        [_priv_eventHandlers setObject:eventHandlers forKey:event];
    }
    [eventHandlers addObject:eventHandler];
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

- (NSArray *)eventHandlersForEvent:(TBSMEvent *)event
{
    if ([self canHandleEvent:event]) {
        return [_priv_eventHandlers objectForKey:event.name];
    }
    return nil;
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    NSString *name = [NSString stringWithFormat:@"%@_DidEnterNotification", self.name];
    [self _postNotificationWithName:name sourceState:sourceState targetState:targetState data:data];
    
    if (_enterBlock) {
        _enterBlock(sourceState, targetState, data);
    }
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    NSString *name = [NSString stringWithFormat:@"%@_DidExitNotification", self.name];
    [self _postNotificationWithName:name sourceState:sourceState targetState:targetState data:data];
    
    if (_exitBlock) {
        _exitBlock(sourceState, targetState, data);
    }
}

- (void)_postNotificationWithName:(NSString *)name sourceState:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    NSMutableDictionary *userInfo = NSMutableDictionary.new;
    if (sourceState) {
        [userInfo setObject:sourceState forKey:@"sourceState"];
    }
    if (targetState) {
        [userInfo setObject:targetState forKey:@"targetState"];
    }
    if (data) {
        [userInfo setObject:data forKey:@"data"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:userInfo];
}

#pragma mark - TBSMNode

- (NSArray *)path
{
    NSMutableArray *path = [NSMutableArray new];
    id<TBSMNode> state = self;
    while (state) {
        [path insertObject:state atIndex:0];
        state = state.parentNode;
    }
    return path;
}

@end
