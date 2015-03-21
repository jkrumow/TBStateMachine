//
//  TBSMFork.h
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransitionVertex.h"


@class TBSMState;
@class TBSMParallelState;

/**
 *  This class represents a 'fork' pseudo state in a state machine.
 */
@interface TBSMFork : NSObject <TBSMTransitionVertex>

@property (nonatomic, copy, readonly) NSString *name;

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
 *  Initializes a `TBSMFork` with a specified name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The name of the fork. Must be unique.
 *
 *  @return An initialized `TBSMFork` instance.
 */
- (instancetype)initWithName:(NSString *)name;

- (void)addTargetStates:(NSArray *)targetStates inRegion:(TBSMParallelState *)region;

@end
