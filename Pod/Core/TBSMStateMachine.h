//
//  TBSMStateMachine.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBSMState.h"
#import "TBSMTransition.h"
#import "TBSMCompoundTransition.h"
#import "TBSMEvent.h"
#import "TBSMEventHandler.h"
#import "TBSMParallelState.h"
#import "TBSMSubState.h"
#import "TBSMFork.h"
#import "TBSMJoin.h"
#import "TBSMJunction.h"
#import "TBSMMacros.h"
#import "TBSMStateMachineBuilder.h"
#import "NSException+TBStateMachine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a hierarchical state machine.
 */
@interface TBSMStateMachine : NSObject <TBSMContainingVertex>

/**
 *  The operation queue to handle the run to completion steps.
 *  Should be serial.
 *
 *  Throws a `TBSMException` when trying to set a queue which is not serial.
 */
@property (nonatomic, strong) NSOperationQueue *scheduledEventsQueue;

/**
 *  The state the state machine wil enter on setup (by default the first state in the provided array will be set).
 *
 *  Throws a `TBSMException` if the state does not exist in the statemachine.
 */
@property (nonatomic, strong) TBSMState *initialState;

/**
 *  The current state the state machine resides in. Set to be nil before -setUp: and after -tearDown: being called.
 */
@property (nonatomic, strong, readonly, nullable) TBSMState *currentState;

+ (instancetype)buildFromFile:(NSString *)file;

/**
 *  Creates a `TBSMStateMachine` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified state machine name.
 *
 *  @return The state machine instance.
 */
+ (instancetype)stateMachineWithName:(NSString *)name;

/**
 *  Initializes a `TBSMStateMachine` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of the state machine. Must be unique.
 *
 *  @return An initialized `TBSMStateMachine` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Starts up the state machine. Will enter the initial state.
 *
 *  Throws `TBSMException` if initial state has not been set beforehand.
 */
- (void)setUp:(nullable id)data;

/**
 *  Leaves the current state and shuts down the state machine.
 */
- (void)tearDown:(nullable id)data;

/**
 *  Returns all states inside the state machine.
 *
 *  @return An NSArray containing all `TBSMState` instances.
 */
- (NSArray<__kindof TBSMState *> *)states;

/**
 *  Sets all states the state machine will manage. First state in array wil be set as initialState.
 *
 *  Throws `TBSMException` if states are not of type `TBSMState`.
 *
 *  @param states An `NSArray` containing all state objects.
 */
- (void)setStates:(NSArray<__kindof TBSMState *> *)states;

/**
 *  Adds an event to the event queue.
 *
 *  @param event The given `TBSMEvent` instance.
 */
- (void)scheduleEvent:(TBSMEvent *)event;

/**
 *  Adds an event to the event queue. Convenience method which receives the event name and payload.
 *
 *  @param name The specified event name.
 *  @param data Optional payload data.
 */
- (void)scheduleEventNamed:(NSString *)name data:(nullable id)data;

/**
 *  Switches between states defined in a specified transition.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param action      The action to execute.
 *  @param data        The payload data.
 */
- (void)switchState:(nullable TBSMState *)sourceState targetState:(nullable TBSMState *)targetState action:(nullable TBSMActionBlock)action data:(nullable id)data;

/**
 *  Switches between states defined in a specified transition.
 *
 *  @param sourceState  The source state.
 *  @param targetStates The target states inside the specified region.
 *  @param region       The target region.
 *  @param action       The action to execute.
 *  @param data         The payload data.
 */
- (void)switchState:(nullable TBSMState *)sourceState targetStates:(NSArray<__kindof TBSMState *> *)targetStates region:(TBSMParallelState *)region action:(nullable TBSMActionBlock)action data:(nullable id)data;

/**
 * Returns the state at the specified path.
 *
 * Throws `TBSMException` if state could not be found.
 *
 * @param path The specified path
 *
 * @return The specified state.
 */
- (TBSMState *)stateWithPath:(NSString *)path;

/**
 * Subscribe to a `TBSMStateDidEnterNotification` of the state at the specified path.
 *
 * Throws `TBSMException` if state could not be found.
 *
 * @param path     The path of the state to subscribe to.
 * @param observer The observer to notify.
 * @param selector The selector to execute when receiving the notification.
 */
- (void)subscribeToEntryAtPath:(NSString *)path forObserver:(NSObject *)observer selector:(nonnull SEL)selector;

/**
 * Subscribe to a `TBSMStateDidExitNotification` of the state at the specified path.
 *
 * Throws `TBSMException` if state could not be found.
 *
 * @param path     The path of the state to subscribe to.
 * @param observer The observer to notify.
 * @param selector The selector to execute when receiving the notification.
 */
- (void)subscribeToExitAtPath:(NSString *)path forObserver:(NSObject *)observer selector:(nonnull SEL)selector;

/**
 * Subscribe to an action of an internal transition of the state at the specified path.
 *
 * Throws `TBSMException` if state could not be found.
 *
 * @param action   The name of the internal transition.
 * @param path     The path of the state to subscribe to.
 * @param observer The observer to notify.
 * @param selector The selector to execute when receiving the notification.
 */
- (void)subscribeToAction:(NSString *)action atPath:(NSString *)path forObserver:(NSObject *)observer selector:(nonnull SEL)selector;

/**
 * Unsubscribe from a `TBSMStateDidEnterNotification` of the state at the specified path.
 *
 * Throws `TBSMException` if state could not be found.
 *
 * @param path     The path of the state to unsubscribe from.
 * @param observer The observer to notify.
 */
- (void)unsubscribeFromEntryAtPath:(NSString *)path forObserver:(NSObject *)observer;

/**
 * Unsubscribe from a `TBSMStateDidExitNotification` of the state at the specified path.
 *
 * Throws `TBSMException` if state could not be found.
 *
 * @param path     The path of the state to unsubscribe from.
 * @param observer The observer to notify.
 */
- (void)unsubscribeFromExitAtPath:(NSString *)path forObserver:(NSObject *)observer;

/**
 * Unsubscribe from an action of an internal transition of the state at the specified path.
 *
 * Throws `TBSMException` if state could not be found.
 *
 * @param action   The name of the internal transition.
 * @param path     The path of the state to unsubscribe from.
 * @param observer The observer to notify.
 */
- (void)unsubscribeFromAction:(NSString *)action atPath:(NSString *)path forObserver:(NSObject *)observer;

@end
NS_ASSUME_NONNULL_END
