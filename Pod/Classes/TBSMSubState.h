//
//  TBSMSubState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMState.h"

@class TBSMStateMachine;
@interface TBSMSubState : TBSMState

/**
 *  The `TBSMStateMachine` instance wrapped by this sub state.
 */
@property (nonatomic, strong, readonly) TBSMStateMachine *stateMachine;

/**
 *  Creates a `TBSMSubState` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified sub state name.
 *
 *  @return The sub state instance.
 */
+ (TBSMSubState *)subStateWithName:(NSString *)name stateMachine:(TBSMStateMachine *)stateMachine;

/**
 *  Initializes a `TBSMParallelState` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return An initialized `TBSMParallelState` instance.
 */
- (instancetype)initWithName:(NSString *)name stateMachine:(TBSMStateMachine *)stateMachine;


@end
