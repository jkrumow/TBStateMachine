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

/**
 *  This class wraps a given `TBSMStateMachine` instance in a state.
 */
@interface TBSMSubState : TBSMState

/**
 *  The `TBSMStateMachine` instance wrapped by this sub state.
 */
@property (nonatomic, strong, readonly) TBSMStateMachine *stateMachine;

/**
 *  Creates a `TBSMSUBState` with a specified name and a `TBSMStateMachine` instance.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name         The name of this wrapper. Must be unique.
 *  @param stateMachine The sub state machine to wrap.
 *
 *  @return A new `TBSMSubState` instance.
 */
+ (TBSMSubState *)subStateWithName:(NSString *)name stateMachine:(TBSMStateMachine *)stateMachine;

/**
 *  Initializes a `TBSMSUBState` with a specified name and a `TBSMStateMachine` instance.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name         The name of this wrapper. Must be unique.
 *  @param stateMachine The sub state machine to wrap.
 *
 *  @return An initialized `TBSMSubState` instance.
 */
- (instancetype)initWithName:(NSString *)name stateMachine:(TBSMStateMachine *)stateMachine;


@end
