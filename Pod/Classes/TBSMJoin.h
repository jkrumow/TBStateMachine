//
//  TBSMJoin.h
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMPseudoState.h"


@class TBSMState;
@class TBSMParallelState;

/**
 *  This class represents a 'join' pseudo state in a state machine.
 */
@interface TBSMJoin : TBSMPseudoState

/**
 *  Creates a `TBSMJoin` instance from a given name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The specified join name.
 *
 *  @return The join instance.
 */
+ (TBSMJoin *)joinWithName:(NSString *)name;

/**
 *  Sets the source states of the join transition.
 *
 *  Throws an exception when parameters are invalid.
 *
 *  @param sourceStates An Array of TBSMState objects.
 *  @param target       The target state.
 */
- (void)setSourceStates:(NSArray *)sourceStates target:(TBSMState *)target;

/**
 *  Performs the TODO: [???] transition towards the join pseudostate for a given source state.
 *  If all source states have been handled the transition switches to the target state.
 *
 *  @param sourceState The source state to join.
 *
 *  @return `YES` if the complete compound transition has been performed.
 */
- (BOOL)joinSourceState:(TBSMState *)sourceState;

@end
