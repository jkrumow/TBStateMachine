//
//  TBSMEventHandler.h
//  Pods
//
//  Created by Julian Krumow on 07.09.14.
//
//

#import <Foundation/Foundation.h>

#import "TBSMTransition.h"

@class TBSMState;

/**
 *  This class represents an event handler object. It stores information associated with a given event registered on a `TBSMState` instance.
 */
@interface TBSMEventHandler : NSObject

/**
 *  The event's name.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  The destination state of the transition triggered by the event.
 */
@property (nonatomic, strong, readonly) TBSMState *target;

/**
 *  The action of the transition triggered by the event.
 */
@property (nonatomic, strong, readonly) TBSMActionBlock action;

/**
 *  The guard function of the transition triggered by the event.
 */
@property (nonatomic, strong, readonly) TBSMGuardBlock guard;

/**
 *  Creates a `TBSMEventHandler` instance from a given event name, target, action and guard.
 *
 *  @param name   The name of this event. Must be unique.
 *  @param target The destination state.
 *  @param action The action.
 *  @param guard  the guard function.
 *
 *  @return The event instance.
 */
+ (instancetype)eventHandlerWithName:(NSString *)name target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

/**
 *  Initializes a `TBSMEventHandler` from a given event name, target, action and guard.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name   The name of this event. Must be unique.
 *  @param target The destination state.
 *  @param action The action.
 *  @param guard  the guard function.
 *
 *  @return An initialized `TBSMEventHandler` instance.
 */
- (instancetype)initWithName:(NSString *)name target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

@end
