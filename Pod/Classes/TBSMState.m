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
#import "TBSMStateMachine.h"

@interface TBSMState ()

@property (nonatomic, copy) NSString *name;

- (BOOL)_canHandleEvent:(TBSMEvent *)event;

@end

@implementation TBSMState

+ (TBSMState *)stateWithName:(NSString *)name;
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
        _eventHandlers = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target
{
    [self registerEvent:event target:target action:nil guard:nil];
}

- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target action:(TBSMActionBlock)action
{
    [self registerEvent:event target:target action:action guard:nil];
}

- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    TBSMEventHandler *eventHandler = [TBSMEventHandler eventHandlerWithName:event.name target:target action:action guard:guard];
    [_eventHandlers setObject:eventHandler forKey:event.name];
}

- (void)unregisterEvent:(TBSMEvent *)event;
{
    [_eventHandlers removeObjectForKey:event.name];
}

#pragma mark - private methods

- (BOOL)_canHandleEvent:(TBSMEvent *)event
{
    return ([_eventHandlers objectForKey:event.name] != nil);
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

- (TBSMTransition *)handleEvent:(TBSMEvent *)event data:(NSDictionary *)data
{
    if ([self _canHandleEvent:event]) {
        TBSMEventHandler *eventHandler = [_eventHandlers objectForKey:event.name];
        return [TBSMTransition transitionWithSourceState:self destinationState:eventHandler.target action:eventHandler.action guard:eventHandler.guard];
    }
    return nil;
}

@end
