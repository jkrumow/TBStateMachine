//
//  TBSMJunction.h
//  TBStateMachine
//
//  Created by Julian Krumow on 23.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMPseudoState.h"
#import "TBSMJunctionPath.h"

@interface TBSMJunction : TBSMPseudoState

/**
 *  Creates a `TBSMJunction` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified junction name.
 *
 *  @return The junction instance.
 */
+ (TBSMJunction *)junctionWithName:(NSString *)name;

/**
 *  The junction's target states.
 *
 *  @return An array containing the target states.
 */
- (NSArray *)targetStates;

/**
 *  Adds an outgoing path to the junction.
 *
 *  @param target The target state.
 *  @param action The action to perform.
 *  @param guard  The guard to evaluate for this path.
 */
- (void)addOutgoingPathWithTarget:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;

/**
 *  Returns the outgoing path of the junction after evaluating all guards.
 *
 *  Throws a `TBSMException` when no target state could be found.
 *
 *  @param source The source state to transition from.
 *  @param data   The payload data.
 *
 *  @return The outgoing path.
 */
- (TBSMJunctionPath *)outgoingPathForTransition:(TBSMState *)source data:(NSDictionary *)data;

@end
