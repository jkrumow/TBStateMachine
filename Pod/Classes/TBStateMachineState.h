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
 *  @param state Either the previous state (when entering) or the next state (when exiting)
 *  @param data The payload data.
 */
typedef void (^TBStateMachineStateBlock)(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data);

/**
 *  This class represents a state in a state machine.
 */
@interface TBStateMachineState : NSObject<TBStateMachineNode>

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
 *  @param target The follow-up `TBStateMachineNode`.
 */
- (void)registerEvent:(TBStateMachineEvent *)event target:(id<TBStateMachineNode>)target;

/**
 *  Registers a `TBStateMachineEvent` object.
 *
 *  @param event  The given TBStateMachineEvent object.
 *  @param target The follow-up `TBStateMachineNode`.
 *  @param action The action associated with this event.
 */
- (void)registerEvent:(TBStateMachineEvent *)event target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action;

/**
 *  Registers a `TBStateMachineEvent` object.
 *
 *  @param event  The given TBStateMachineEvent object.
 *  @param target The follow-up `TBStateMachineNode`.
 *  @param action The action associated with this event.
 *  @param guard  The guard function associated with this event.
 */
- (void)registerEvent:(TBStateMachineEvent *)event target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard;

/**
 *  Unregisteres a `TBStateMachineEvent` object.
 *
 *  @param event   The given TBStateMachineEvent object.
 */
- (void)unregisterEvent:(TBStateMachineEvent *)event;

@end
