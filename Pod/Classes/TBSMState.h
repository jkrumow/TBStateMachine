//
//  TBSMState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 *  All `TBSMEvent` instances registered to this state instance.
 */
@property (nonatomic, strong, readonly) NSDictionary *eventHandlers;

/**
 *  All `TBSMEvent` instances deferred by this state instance.
 */
@property (nonatomic, strong, readonly) NSDictionary *deferredEvents;

/**
 *  Creates a `TBSMState` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified state name.
 *
 *  @return The state instance.
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
 *  Registers a `TBSMEvent` instance for transition to a specified target state.
 *
 *  @param event  The given TBSMEvent instance.
 *  @param target The destination `TBSMState` instance.
 */
- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target;

/**
 *  Registers a `TBSMEvent` instance for transition to a specified target state.
 *  If target parameter is `nil` an internal transition will be performed using the action block.
 *
 *  @param event  The given `TBSMEvent` instance.
 *  @param target The destination `TBSMState` instance. Can be `nil` for internal transitions.
 *  @param action The action block associated with this event.
 */
- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target action:(TBSMActionBlock)action;

/**
 *  Registers a `TBSMEvent` instance for transition to a specified target state.
 *  If target parameter is `nil` an internal transition will be performed using guard and action block.
 *
 *  @param event  The given `TBSMEvent` instance.
 *  @param target The destination `TBSMState` instance. Can be `nil` for internal transitions.
 *  @param action The action block associated with this event.
 *  @param guard  The guard block associated with this event.
 */
- (void)registerEvent:(TBSMEvent *)event target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

/**
 *  Registers a `TBSMEvent` instance which should be deferred when received by this state instance.
 *
 *  @param event The given `TBSMEvent` instance.
 */
- (void)deferEvent:(TBSMEvent *)event;

/**
 *  Returns `YES` if a given event can be handled by the state.
 *
 *  @param event The event to check.
 *
 *  @return `YES` if the event can be handled.
 */
- (BOOL)canHandleEvent:(TBSMEvent *)event;

/**
 *  Returns `YES` if a given event can be defered by the state.
 *
 *  @param event The event to check.
 *
 *  @return `YES` if the event can be defered.
 */
- (BOOL)canDeferEvent:(TBSMEvent *)event;

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
