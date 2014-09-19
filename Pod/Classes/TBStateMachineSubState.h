//
//  TBStateMachineSubState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBStateMachineState.h"

@interface TBStateMachineSubState : TBStateMachineState

/**
 *  Creates a `TBStateMachineSubState` instance from a given name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The specified sub state name.
 *
 *  @return The sub state instance.
 */
+ (TBStateMachineSubState *)subStateWithName:(NSString *)name stateMachine:(TBStateMachine *)stateMachine;

/**
 *  Initializes a `TBStateMachineParallelState` with a specified name.
 *
 *  Throws a `TBStateMachineException` when name is nil or an empty string.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return An initialized `TBStateMachineParallelState` instance.
 */
- (instancetype)initWithName:(NSString *)name stateMachine:(TBStateMachine *)stateMachine;


@end
