//
//  TBSMFork.h
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMPseudoState.h"

NS_ASSUME_NONNULL_BEGIN

@class TBSMState;
@class TBSMParallelState;

/**
 *  This class represents a 'fork' pseudo state in a state machine.
 */
@interface TBSMFork : TBSMPseudoState

@property (nonatomic, strong, readonly) TBSMParallelState *region;

/**
 *  Creates a `TBSMFork` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified fork name.
 *
 *  @return The fork instance.
 */
+ (instancetype)forkWithName:(NSString *)name;

/**
 *  The fork's target states inside the region.
 *
 *  @return An array containing the target states.
 */
- (NSArray<__kindof TBSMState *> *)targetStates;

/**
 *  Sets the target states for the fork transition.
 *
 *  Throws a `TBSMException` when parameters are invalid.
 *
 *  @param targetStates The states to enter.
 *  @param region       The containing region.
 */
- (void)setTargetStates:(NSArray<__kindof TBSMState *> *)targetStates inRegion:(TBSMParallelState *)region;

@end
NS_ASSUME_NONNULL_END
