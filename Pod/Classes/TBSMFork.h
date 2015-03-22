//
//  TBSMFork.h
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
 *  This class represents a 'fork' pseudo state in a state machine.
 */
@interface TBSMFork : TBSMPseudoState

/**
 *  Creates a `TBSMFork` instance from a given name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The specified fork name.
 *
 *  @return The fork instance.
 */
+ (TBSMFork *)forkWithName:(NSString *)name;

/**
 *  Sets the target states for the fork transition.
 *
 *  Throws an exception when parameters are invalid.
 *
 *  @param targetStates The states to enter.
 *  @param region       The containing region.
 */
- (void)setTargetStates:(NSArray *)targetStates inRegion:(TBSMParallelState *)region;

@end
