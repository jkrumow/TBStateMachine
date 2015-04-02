//
//  NSException+TBSM.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
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
 *  The `reason:` will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_notOfTypeStateException:(id)object;

/**
 *  Thrown when a specified `TBSMState` instance does not exist in the state machine.
 *
 *  The `reason:` will contain the name of the state.
 *
 *  @param stateName The name of the specified `TBSMState`.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_nonExistingStateException:(NSString *)stateName;

/**
 *  Thrown when no initial state has been set on the state machine.
 *
 *  The `reason:` will contain the name of the state machine.
 *
 *  @param stateMachineName The name of the specified `TBSMState`.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_noInitialStateException:(NSString *)stateMachineName;

/**
 *  Thrown when no name was given to a `TBSMState` instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_noNameForStateException;

/**
 *  Thrown when no name was given to a pseudo state instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_noNameForPseudoStateException;

/**
 *  Thrown when no name was given to a `TBSMEvent` instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_noNameForEventException;

/**
 *  Thrown when a given object is not of type `TBSMStateMachine`.
 *
 *  The `reason:` will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_notAStateMachineException:(id)object;

/**
 *  Thrown when a `TBSMSubState` or `TBSMParallelState` was instanciated without a sub-machine instance.
 *
 *  @param stateMachineName The name of the specified `TBSMStateMachine` instance.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_missingStateMachineException:(NSString *)stateMachineName;

/**
 *  Thrown when no least common ancestor could be found for a given transition.
 *
 *  @param transitionName The name of the transition.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_noLcaForTransition:(NSString *)transitionName;

/**
 *  Thrown when an event handler has been added with contradicting or missing transition attributes.
 *
 *  @param eventName   The name of the specified event.
 *  @param sourceState The name of the source state.
 *  @param targetState The name of the target state.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_ambiguousTransitionAttributes:(NSString *)eventName source:(NSString *)sourceState target:(NSString *)targetState;

/**
 *  Thrown when a compound transition is not well contructed.
 *
 *  @param pseudoStateName The name of the pseudo state.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_ambiguousCompoundTransitionAttributes:(NSString *)pseudoStateName;

/**
 *  Thrown when an NSOperaionQueue has been set which is not serial.
 *
 *  @param queueName The name of the queue.
 *
 *  @return The `NSException` instance.
 */
+ (NSException *)tb_noSerialQueueException:(NSString *)queueName;

@end
