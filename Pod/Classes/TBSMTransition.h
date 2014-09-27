//
//  TBSMTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransition.h"

@class TBSMState;

/**
 *  This type represents an action of a given `TBSMTransition`.
 *
 *  @param sourceState      The source `TBSMState`.
 *  @param destinationState The destination `TBSMState`.
 *  @param data             The payload data.
 */
typedef void(^TBSMActionBlock)(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data);

/**
 *  This type represents a guard function of a given `TBSMTransition`.
 *
 *  @param sourceState      The source `TBSMNode`.
 *  @param destinationState The destination `TBSMNode`.
 *  @param data      The payload data.
 */
typedef BOOL(^TBSMGuardBlock)(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data);


/**
 *  This class represents a transition in a state machine.
 */
@interface TBSMTransition : NSObject

/**
 *  The source state.
 */
@property (nonatomic, weak, readonly) TBSMState *sourceState;

/**
 *  The destination state.
 */
@property (nonatomic, weak, readonly) TBSMState *destinationState;

/**
 *  The action associated with the transition.
 */
@property (nonatomic, strong, readonly) TBSMActionBlock action;

/**
 *  The guard function associated with the transition.
 */
@property (nonatomic, strong, readonly) TBSMGuardBlock guard;

/**
 *  Creates a `TBSMTransition` instance from a given source and destination state, action and guard.
 * 
 *  @param sourceState      The specified source state.
 *  @param destinationState The specified destination state.
 *  @param action           The action associated with this transition.
 *  @param guard            The guard function associated with the transition.
 *
 *  @return The transition object.
 */
+ (TBSMTransition *)transitionWithSourceState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

/**
 *  Initializes a `TBSMTransition` instance from a given source and destination state, action and guard.
 *
 *  @param sourceState      The specified source state.
 *  @param destinationState The specified destination state.
 *  @param action           The action associated with this transition.
 *  @param guard            The guard function associated with the transition.
 *
 *  @return The transition object.
 */
- (instancetype)initWithSourceState:(TBSMState *)sourceState destinationState:(TBSMState *)destinationState action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

/**
 *  The transition's name.
 *
 *  @return The name.
 */
- (NSString *)name;

@end
