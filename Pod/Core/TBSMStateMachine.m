//
//  TBSMStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine.h"

@interface TBSMStateMachine ()
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, weak) id<TBSMHierarchyVertex> parentVertex;
@property (nonatomic, strong) NSMutableArray *priv_states;
@end

@implementation TBSMStateMachine

+ (instancetype)stateMachineWithName:(NSString *)name
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
        _priv_states = [NSMutableArray new];
        _scheduledEventsQueue = [NSOperationQueue mainQueue];
    }
    return self;
}

- (NSArray *)states
{
    return self.priv_states.copy;
}

- (void)setStates:(NSArray *)states
{
    [self.priv_states removeAllObjects];
    
    for (id object in states) {
        if (![object isKindOfClass:[TBSMState class]])  {
            @throw ([NSException tb_notOfTypeStateException:object]);
        }
        TBSMState *state = object;
        [state setParentVertex:self];
        [self.priv_states addObject:state];
    }
    if (states.count > 0) {
        _initialState = states[0];
    }
}

- (void)setInitialState:(TBSMState *)initialState
{
    if (![self.priv_states containsObject:initialState]) {
        @throw [NSException tb_nonExistingStateException:initialState.name];
    }
    _initialState = initialState;
}

- (void)setScheduledEventsQueue:(NSOperationQueue *)scheduledEventsQueue
{
    if (scheduledEventsQueue.maxConcurrentOperationCount > 1) {
        @throw [NSException tb_noSerialQueueException:scheduledEventsQueue.name];
    }
    _scheduledEventsQueue = scheduledEventsQueue;
}

- (void)setUp:(id)data
{
    if (!self.initialState) {
        @throw [NSException tb_noInitialStateException:self.name];
    }
    [self enter:nil targetState:self.initialState data:data];
}

- (void)tearDown:(id)data
{
    [self.scheduledEventsQueue cancelAllOperations];
    [self exit:self.currentState targetState:nil data:data];
    _currentState = nil;
}

#pragma mark - handling events

- (void)scheduleEvent:(TBSMEvent *)event
{
    if (self.parentVertex) {
        TBSMStateMachine *topStateMachine = (TBSMStateMachine *)[self.parentVertex parentVertex];
        [topStateMachine scheduleEvent:event];
        return;
    }
    
    [self.scheduledEventsQueue addOperationWithBlock:^{
        [self handleEvent:event];
    }];
}

- (void)scheduleEventNamed:(NSString *)name data:(id)data
{
    [self scheduleEvent:[TBSMEvent eventWithName:name data:data]];
}

- (BOOL)handleEvent:(TBSMEvent *)event
{
    if (self.currentState) {
        if ([self.currentState respondsToSelector:@selector(handleEvent:)]) {
            if ([self.currentState performSelector:@selector(handleEvent:) withObject:event]) {
                return YES;
            }
        }
        NSArray *eventHandlers = [self.currentState eventHandlersForEvent:event];
        for (TBSMEventHandler *eventHandler in eventHandlers) {
            
            TBSMTransition *transition = nil;
            if ([eventHandler.target isKindOfClass:[TBSMState class]]) {
                transition = [[TBSMTransition alloc] initWithSourceState:self.currentState
                                                             targetState:(TBSMState *)eventHandler.target
                                                                    kind:eventHandler.kind
                                                                  action:eventHandler.action
                                                                   guard:eventHandler.guard];
            } else {
                transition = [[TBSMCompoundTransition alloc] initWithSourceState:self.currentState
                                                               targetPseudoState:(TBSMPseudoState *)eventHandler.target
                                                                          action:eventHandler.action
                                                                           guard:eventHandler.guard];
            }
            if ([transition performTransitionWithData:event.data]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - State switching

- (void)switchState:(TBSMState *)sourceState targetState:(TBSMState *)targetState action:(TBSMActionBlock)action data:(id)data
{
    [self.currentState exit:sourceState targetState:targetState data:data];
    if (action) {
        action(data);
    }
    [self enter:sourceState targetState:targetState data:data];
}

- (void)switchState:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region action:(TBSMActionBlock)action data:(id)data
{
    [self.currentState exit:sourceState targetState:region data:data];
    if (action) {
        action(data);
    }
    [self enter:sourceState targetStates:targetStates region:region data:data];
}

- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    NSUInteger targetLevel = targetState.parentVertex.path.count;
    NSUInteger thisLevel = self.path.count;
    
    if (targetLevel < thisLevel) {
        _currentState = self.initialState;
    } else if (targetLevel == thisLevel) {
        _currentState = targetState;
    } else {
        NSArray *targetPath = [targetState.parentVertex path];
        id<TBSMHierarchyVertex> vertex = targetPath[thisLevel];
        _currentState = (TBSMState *)vertex.parentVertex;
    }
    [self.currentState enter:sourceState targetState:targetState data:data];
}

- (void)enter:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region data:(id)data
{
    NSUInteger targetLevel = [[region.parentVertex path] count];
    NSUInteger thisLevel = self.path.count;
    
    if (targetLevel == thisLevel) {
        _currentState = region;
    } else if (targetLevel > thisLevel) {
        NSArray *targetPath = [region.parentVertex path];
        id<TBSMHierarchyVertex> vertex = targetPath[thisLevel];
        _currentState = (TBSMState *)vertex.parentVertex;
    }
    id<TBSMContainingVertex> vertex = (id <TBSMContainingVertex>)_currentState;
    [vertex enter:sourceState targetStates:targetStates region:region data:data];
}

- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [self.currentState exit:sourceState targetState:targetState data:data];
}

#pragma mark - TBSMHierarchyVertex

- (NSArray *)path
{
    NSMutableArray *path = [NSMutableArray new];
    TBSMStateMachine *stateMachine = self;
    while (stateMachine) {
        [path insertObject:stateMachine atIndex:0];
        stateMachine = (TBSMStateMachine *)stateMachine.parentVertex.parentVertex;
    }
    return path;
}

@end
