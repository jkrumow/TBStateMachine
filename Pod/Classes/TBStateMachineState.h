//
//  TBStateMachineState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBStateMachineTransition.h"
#import "TBStateMachineEvent.h"
#import "TBStateMachineNode.h"

/**
 *  This type represents a block that is executed on entry and exit of a `TBStateMachineState`.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data The payload data.
 */
typedef void (^TBStateMachineStateBlock)(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data);

/**
 *  This class represents a state in a state machine.
 */
@interface TBStateMachineState : NSObject<TBStateMachineNode>

@property (nonatomic, weak) id<TBStateMachineNode> parentState;

/**
 *  Block that is executed when the state is entered.
 */
@property (nonatomic, strong) TBStateMachineStateBlock enterBlock;

/**
 *  Block that is executed when the state is exited.
 */
@property (nonatomic, strong) TBStateMachineStateBlock exitBlock;

/**
 *  All `TBStateMachineEvent` instances added to this state instance.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *eventHandlers;

/**
 *  Creates a `TBStateMachineState` instance from a given name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The specified state name.
 *
 *  @return The state object.
 */
+ (TBStateMachineState *)stateWithName:(NSString *)name;

/**
 *  Initializes a `TBStateMachineState` with a specified name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The name of the state. Must be unique.
 *
 *  @return An initialized `TBStateMachineState` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Registers a `TBStateMachineEvent` object.
 *
 *  @param event  The given TBStateMachineEvent object.
 *  @param target The follow-up `TBStateMachineState`.
 */
- (void)registerEvent:(TBStateMachineEvent *)event target:(TBStateMachineState *)target;

/**
 *  Registers a `TBStateMachineEvent` object.
 *
 *  @param event  The given TBStateMachineEvent object.
 *  @param target The follow-up `TBStateMachineState`.
 *  @param action The action associated with this event.
 */
- (void)registerEvent:(TBStateMachineEvent *)event target:(TBStateMachineState *)target action:(TBStateMachineActionBlock)action;

/**
 *  Registers a `TBStateMachineEvent` object.
 *
 *  @param event  The given TBStateMachineEvent object.
 *  @param target The follow-up `TBStateMachineState`.
 *  @param action The action associated with this event.
 *  @param guard  The guard function associated with this event.
 */
- (void)registerEvent:(TBStateMachineEvent *)event target:(TBStateMachineState *)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard;

/**
 *  Unregisteres a `TBStateMachineEvent` object.
 *
 *  @param event   The given TBStateMachineEvent object.
 */
- (void)unregisterEvent:(TBStateMachineEvent *)event;

/**
 *  Executes the enter block of the state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)enter:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState data:(NSDictionary *)data;

/**
 *  Executes the exit block of the state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)exit:(TBStateMachineState *)sourceState destinationState:(TBStateMachineState *)destinationState data:(NSDictionary *)data;

@end
