//
//  TBSMFork.h
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMPseudoState.h"


@class TBSMState;
@class TBSMParallelState;

/**
 *  This class represents a 'fork' pseudo state in a state machine.
 */
@interface TBSMFork : TBSMPseudoState

@property (nonatomic, strong, readonly, nonnull) TBSMParallelState *region;

/**
 *  Creates a `TBSMFork` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified fork name.
 *
 *  @return The fork instance.
 */
+ (nullable TBSMFork *)forkWithName:(nonnull NSString *)name;

/**
 *  The fork's target states inside the region.
 *
 *  @return An array containing the target states.
 */
- (nonnull NSArray<__kindof TBSMState *> *)targetStates;

/**
 *  Sets the target states for the fork transition.
 *
 *  Throws a `TBSMException` when parameters are invalid.
 *
 *  @param targetStates The states to enter.
 *  @param region       The containing region.
 */
- (void)setTargetStates:(nonnull NSArray<__kindof TBSMState *> *)targetStates inRegion:(nonnull TBSMParallelState *)region;

@end
