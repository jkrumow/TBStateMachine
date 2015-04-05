//
//  TBSMEventHandler.h
//  TBStateMachine
//
//  Created by Julian Krumow on 07.09.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransition.h"
#import "TBSMState.h"


/**
 *  This class represents an event handler object.
 *  It stores information associated with a given event registered on a `TBSMState` instance.
 */
@interface TBSMEventHandler : NSObject

/**
 *  The event's name.
 */
@property (nonatomic, copy) NSString *name;

/**
 *  The target vertex of the transition triggered by the event.
 */
@property (nonatomic, strong) id <TBSMTransitionVertex> target;

/**
 *  The kind of transition to perform.
 */
@property (nonatomic, assign) TBSMTransitionKind kind;

/**
 *  The action of the transition triggered by the event.
 */
@property (nonatomic, copy) TBSMActionBlock action;

/**
 *  The guard function of the transition triggered by the event.
 */
@property (nonatomic, copy) TBSMGuardBlock guard;


/**
 *  Creates a `TBSMEventHandler` instance from a given event name, target, action and guard.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name   The name of this event. Must be unique.
 *  @param target The target vertex.
 *  @param type   The kind of transition.
 *  @param action The action.
 *  @param guard  The guard function.
 *
 *  @return The event handler instance.
 */
+ (instancetype)eventHandlerWithName:(NSString *)name target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

/**
 *  Initializes a `TBSMEventHandler` from a given event name, target, action and guard.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name   The name of this event. Must be unique.
 *  @param target The target vertex.
 *  @param kind   The kind of transition.
 *  @param action The action.
 *  @param guard  The guard function.
 *
 *  @return An initialized `TBSMEventHandler` instance.
 */
- (instancetype)initWithName:(NSString *)name target:(id <TBSMTransitionVertex>)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

@end
