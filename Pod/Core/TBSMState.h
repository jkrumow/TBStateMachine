//
//  TBSMState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMHierarchyVertex.h"
#import "TBSMTransitionKind.h"
#import "TBSMTransitionVertex.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const TBSMStateDidEnterNotification;
FOUNDATION_EXPORT NSString * const TBSMStateDidExitNotification;
FOUNDATION_EXPORT NSString * const TBSMDataUserInfo;

/**
 *  This type represents a block that is executed on entry and exit of a `TBSMState`.
 *
 *  @param data The payload data.
 */
typedef void (^TBSMStateBlock)(id _Nullable data);

@class TBSMEventHandler;

/**
 *  This class represents a state in a state machine.
 */
@interface TBSMState : NSObject<TBSMHierarchyVertex, TBSMTransitionVertex>

/**
 *  The state's parent vertex inside the state machine hierarchy.
 */
@property (nonatomic, weak) id<TBSMHierarchyVertex> parentVertex;

/**
 *  Block that is executed when the state is entered.
 */
@property (nonatomic, copy, nullable) TBSMStateBlock enterBlock;

/**
 *  Block that is executed when the state is exited.
 */
@property (nonatomic, copy, nullable) TBSMStateBlock exitBlock;

/**
 *  All `TBSMEventHandler` instances registered to this state instance.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSMutableArray<TBSMEventHandler *> *> *eventHandlers;

/**
 *  Creates a `TBSMState` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified state name.
 *
 *  @return The state instance.
 */
+ (instancetype)stateWithName:(NSString *)name;

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
 * Removes all event handlers to break up all cyclic references between states.
 */
- (void)removeAllEventHandlers;

/**
 *  Registers an event of a given name for transition to a specified target state.
 *  Defaults to external transition.
 *
 *  @param event  The given event name.
 *  @param target The target vertex. Can be `nil` for internal transitions.
 */
- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target;

/**
 *  Registers an event of a given name for transition to a specified target state.
 *
 *  Throws a `TBSMException` if the parameters are ambiguous.
 *
 *  @param event  The given event name.
 *  @param target The target vertex.
 *  @param kind   The kind of transition.
 */
- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind;

/**
 *  Registers an event of a given name for transition to a specified target state.
 *
 *  Throws a `TBSMException` if the parameters are ambiguous.
 *
 *  @param event  The given event name.
 *  @param target The target vertex.
 *  @param kind   The kind of transition.
 *  @param action The action block associated with this event.
 */
- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind action:(nullable TBSMActionBlock)action;

/**
 *  Registers an event of a given name for transition to a specified target state.
 *
 *  Throws a `TBSMException` if the parameters are ambiguous.
 *
 *  @param event  The given event name.
 *  @param target The target vertex.
 *  @param kind   The kind of transition.
 *  @param action The action block associated with this event.
 *  @param guard  The guard block associated with this event.
 */
- (void)addHandlerForEvent:(NSString *)event target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind action:(nullable TBSMActionBlock)action guard:(nullable TBSMGuardBlock)guard;

/**
 *  Returns `YES` if a given event can be consumed by the state.
 *
 *  @param event The event to check.
 *
 *  @return `YES` if the event can be consumed.
 */
- (BOOL)hasHandlerForEvent:(TBSMEvent *)event;

/**
 *  Returns an array of `TBSMEventHandler` instances for a given event.
 *
 *  @param event The event to handle
 *
 *  @return The array containing the corresponding event handlers.
 */
- (nullable NSArray<TBSMEventHandler *> *)eventHandlersForEvent:(TBSMEvent *)event;

- (void)removeAllEventHandlers;

@end
NS_ASSUME_NONNULL_END

