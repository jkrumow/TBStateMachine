//
//  TBSMState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMState.h"
#import "NSException+TBStateMachine.h"
#import "TBSMEventHandler.h"

NSString * const TBSMStateDidEnterNotification = @"TBSMStateDidEnterNotification";
NSString * const TBSMStateDidExitNotification = @"TBSMStateDidExitNotification";
NSString * const TBSMSourceStateUserInfo = @"sourceState";
NSString * const TBSMTargetStateUserInfo = @"targetState";
NSString * const TBSMDataUserInfo = @"data";

@interface TBSMState ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *priv_eventHandlers;
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
    }
    return self;
}

- (NSDictionary *)eventHandlers
{
    return self.priv_eventHandlers.copy;
}

- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target
{
    [self addHandlerForEvent:event target:target kind:TBSMTransitionExternal];
}

- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind
{
    [self addHandlerForEvent:event target:target kind:kind action:nil guard:nil];
}

- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action
{
    [self addHandlerForEvent:event target:target kind:kind action:action guard:nil];
}

- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    if (kind == TBSMTransitionInternal) {
        if (!(self == target || target == nil)) {
            @throw [NSException tb_ambiguousTransitionAttributes:event source:self.name target:target.name];
        }
    } else if (target == nil) {
        @throw [NSException tb_ambiguousTransitionAttributes:event source:self.name target:target.name];
    }
    TBSMEventHandler *eventHandler = [TBSMEventHandler eventHandlerWithName:event target:target kind:kind action:action guard:guard];
    NSMutableArray *eventHandlers = self.priv_eventHandlers[event];
    if (!eventHandlers) {
        eventHandlers = NSMutableArray.new;
        [self.priv_eventHandlers setObject:eventHandlers forKey:event];
    }
    [eventHandlers addObject:eventHandler];
}

- (BOOL)hasHandlerForEvent:(TBSMEvent *)event
{
    return ([self.priv_eventHandlers objectForKey:event.name] != nil);
}

- (NSArray *)eventHandlersForEvent:(TBSMEvent *)event
{
    if ([self hasHandlerForEvent:event]) {
        return [self.priv_eventHandlers objectForKey:event.name];
    }
    return nil;
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    [self _postNotificationWithName:TBSMStateDidEnterNotification sourceState:sourceState targetState:targetState data:data];
    
    if (_enterBlock) {
        _enterBlock(sourceState, targetState, data);
    }
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    [self _postNotificationWithName:TBSMStateDidExitNotification sourceState:sourceState targetState:targetState data:data];
    
    if (_exitBlock) {
        _exitBlock(sourceState, targetState, data);
    }
}

- (void)_postNotificationWithName:(NSString *)name sourceState:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    NSMutableDictionary *userInfo = NSMutableDictionary.new;
    if (sourceState) {
        [userInfo setObject:sourceState forKey:TBSMSourceStateUserInfo];
    }
    if (targetState) {
        [userInfo setObject:targetState forKey:TBSMTargetStateUserInfo];
    }
    if (data) {
        [userInfo setObject:data forKey:TBSMDataUserInfo];
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
