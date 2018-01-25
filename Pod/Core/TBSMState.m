//
//  TBSMState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMState.h"
#import "NSException+TBStateMachine.h"
#import "TBSMEventHandler.h"

NSString * const TBSMStateDidEnterNotification = @"TBSMStateDidEnterNotification";
NSString * const TBSMStateDidExitNotification = @"TBSMStateDidExitNotification";
NSString * const TBSMDataUserInfo = @"data";

@interface TBSMState ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *priv_eventHandlers;
@end

@implementation TBSMState

+ (instancetype)stateWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
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

- (void)removeAllEventHandlers
{
    [self.priv_eventHandlers removeAllObjects];
    self.priv_eventHandlers = nil;
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
    if (target == nil) {
        @throw [NSException tb_ambiguousTransitionAttributes:event source:self.name target:target.name];
    }
    if (kind == TBSMTransitionInternal && target != self) {
        @throw [NSException tb_ambiguousTransitionAttributes:event source:self.name target:target.name];
    }
    TBSMEventHandler *eventHandler = [[TBSMEventHandler alloc] initWithName:event target:target kind:kind action:action guard:guard];
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

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [self _postNotificationWithName:TBSMStateDidEnterNotification data:data];
    
    if (_enterBlock) {
        _enterBlock(data);
    }
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [self _postNotificationWithName:TBSMStateDidExitNotification data:data];
    
    if (_exitBlock) {
        _exitBlock(data);
    }
}

- (void)_postNotificationWithName:(NSString *)name data:(id)data
{
    NSMutableDictionary *userInfo = NSMutableDictionary.new;
    if (data) {
        [userInfo setObject:data forKey:TBSMDataUserInfo];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:userInfo];
}

-(void)removeAllEventHandlers {
    [self.priv_eventHandlers removeAllObjects];
    self.priv_eventHandlers = nil;
}

#pragma mark - TBSMHierarchyVertex

- (NSArray *)path
{
    NSMutableArray *path = [NSMutableArray new];
    id<TBSMHierarchyVertex> state = self;
    while (state) {
        [path insertObject:state atIndex:0];
        state = state.parentVertex;
    }
    return path;
}

@end

