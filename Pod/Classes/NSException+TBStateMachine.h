//
//  NSException+TBStateMachine.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const TBStateMachineException;

/**
 *  This category adds class methods to create NSException instances thrown by the TBStateMachine library.
 */
@interface NSException (TBStateMachine)

/**
 *  Thrown when an object is not of type `TBStateMachineState`.
 *
 *  The `reason:` string will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_notOfTypeTBStateMachineStateException:(id)object;

/**
 *  Thrown when a specified `TBStateMachineState` instance does not exist in the state machine.
 *
 *  The `reason:` string will contain the name of the state.
 *
 *  @param stateName The name of the specified `TBStateMachineState`.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_nonExistingStateException:(NSString *)stateName;

/**
 *  Thrown when no initial state has been set on the state machine.
 *
 *  The `reason:` string will contain the name of the state machine.
 *
 *  @param stateName The name of the specified `TBStateMachine` instance.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_noInitialStateException:(NSString *)stateName;

/**
 *  Thrown when no name was given to a `TBStateMachineState` instance.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_noNameForStateException;

/**
 *  Thrown when no name was given to a `TBStateMachineEvent` instance.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_noNameForEventException;

/**
 *  Thrown when a given object is not of type `TBStateMachine`.
 *
 *  The `reason:` string will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_notAStateMachineException:(id)object;

@end
