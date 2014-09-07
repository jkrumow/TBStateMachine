//
//  TBStateMachineEventHandler.h
//  Pods
//
//  Created by Julian Krumow on 07.09.14.
//
//

#import <Foundation/Foundation.h>

#import "TBStateMachineTransition.h"

/**
 *  This class represents an event handler object. It stores information associated with a given event registered on a `TBStateMachineState` instance.
 */
@interface TBStateMachineEventHandler : NSObject

/**
 *  The event's name.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  The destination state of the transition triggered by the event.
 */
@property (nonatomic, strong, readonly) id<TBStateMachineNode> target;

/**
 *  The action of the transition triggered by the event.
 */
@property (nonatomic, strong, readonly) TBStateMachineActionBlock action;

/**
 *  The guard function of the transition triggered by the event.
 */
@property (nonatomic, strong, readonly) TBStateMachineGuardBlock guard;

/**
 *  Creates a `TBStateMachineEventHandler` instance from a given event name, target, action and guard.
 *
 *  @param name   The name of this event. Must be unique.
 *  @param target The destination state.
 *  @param action The action.
 *  @param guard  the guard function.
 *
 *  @return The event instance.
 */
+ (instancetype)eventHandlerWithName:(NSString *)name target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard;

/**
 *  Initializes a `TBStateMachineEventHandler` from a given event name, target, action and guard.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name   The name of this event. Must be unique.
 *  @param target The destination state.
 *  @param action The action.
 *  @param guard  the guard function.
 *
 *  @return An initialized `TBStateMachineEventHandler` instance.
 */
- (instancetype)initWithName:(NSString *)name target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard;

@end
