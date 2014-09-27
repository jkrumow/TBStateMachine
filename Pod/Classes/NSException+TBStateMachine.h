//
//  NSException+TBSM.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const TBSMException;

/**
 *  This category adds class methods to create NSException instances thrown by the TBStateMachine library.
 */
@interface NSException (TBStateMachine)

/**
 *  Thrown when an object is not of type `TBSMState`.
 *
 *  The `reason:` string will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_notOfTypeStateException:(id)object;

/**
 *  Thrown when a specified `TBSMState` instance does not exist in the state machine.
 *
 *  The `reason:` string will contain the name of the state.
 *
 *  @param stateName The name of the specified `TBSMState`.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_nonExistingStateException:(NSString *)stateName;

/**
 *  Thrown when no initial state has been set on the state machine.
 *
 *  The `reason:` string will contain the name of the state machine.
 *
 *  @param stateName The name of the specified `TBSMStateMachine` instance.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_noInitialStateException:(NSString *)stateName;

/**
 *  Thrown when no name was given to a `TBSMState` instance.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_noNameForStateException;

/**
 *  Thrown when no name was given to a `TBSMEvent` instance.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_noNameForEventException;

/**
 *  Thrown when a given object is not of type `TBSMStateMachine`.
 *
 *  The `reason:` string will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_notAStateMachineException:(id)object;

/**
 *  Thrown when a TBSMSubState was instanciated without a `TBSMStateMachine` instance.
 *
 *  @param stateMachineName The name of the specified `TBSMStateMachine` instance.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_missingStateMachineException:(NSString *)stateMachineName;

@end
