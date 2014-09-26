//
//  TBSMState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMTransition.h"
#import "TBSMEvent.h"
#import "TBSMNode.h"

/**
 *  This type represents a block that is executed on entry and exit of a `TBSMState`.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data The payload data.
 */
typedef void (^TBSMStateBlock)(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data);

/**
 *  This class represents a state in a state machine.
 */
@interface TBSMState : NSObject<TBSMNode>

/**
 *  The state's parent state inside the state machine hierarchy.
 */
@property (nonatomic, weak) id<TBSMNode> parentState;

/**
 *  Block that is executed when the state is entered.
 */
@property (nonatomic, strong) TBSMStateBlock enterBlock;

/**
 *  Block that is executed when the state is exited.
 */
@property (nonatomic, strong) TBSMStateBlock exitBlock;

/**
 *  All `TBSMEvent` instances added to this state instance.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *eventHandlers;

/**
 *  Creates a `TBSMState` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified state name.
 *
 *  @return The state object.
 */
+ (TBSMState *)stateWithName:(NSString *)name;

/**
 *  Initializes a `TBSMState` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of the state. Must be unique.
 *
 *  @return An initialized `TBSMState` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Registers a `TBSMEvent` object.
 *
 *  @param event  The given TBSMEvent object.
 *  @param target The follow-up `TBSMState`.
 */
- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target;

/**
 *  Registers a `TBSMEvent` object.
 *
 *  @param event  The given TBSMEvent object.
 *  @param target The follow-up `TBSMState`.
 *  @param action The action associated with this event.
 */
- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target action:(TBSMActionBlock)action;

/**
 *  Registers a `TBSMEvent` object.
 *
 *  @param event  The given TBSMEvent object.
 *  @param target The follow-up `TBSMState`.
 *  @param action The action associated with this event.
 *  @param guard  The guard function associated with this event.
 */
- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

/**
 *  Unregisteres a `TBSMEvent` object.
 *
 *  @param event   The given TBSMEvent object.
 */
- (void)unregisterEvent:(TBSMEvent *)event;

/**
 *  Executes the enter block of the state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)enter:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data;

/**
 *  Executes the exit block of the state.
 *
 *  @param sourceState      The source state.
 *  @param destinationState The destination state.
 *  @param data             The payload data.
 */
- (void)exit:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState data:(NSDictionary *)data;

@end
