//
//  NSException+TBStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "NSException+TBStateMachine.h"


NSString * const TBSMException = @"TBSMException";

static NSString * const TBSMNotOfTypeStateExceptionReason = @"The specified object '%@' must be of type TBSMState.";
static NSString * const TBSMNonExistingStateExceptionReason = @"The specified state '%@' does not exist.";
static NSString * const TBSMNoInitialStateExceptionReason = @"Initial state needs to be set on state machine '%@'.";
static NSString * const TBSMNoNameForStateExceptionReason = @"State needs to have a valid name.";
static NSString * const TBSMNoNameForPseudoStateExceptionReason = @"PseudoState needs to have a valid name.";
static NSString * const TBSMNoNameForEventExceptionReason = @"Event needs to have a valid name.";
static NSString * const TBSMNotAStateMachineExceptionReason = @"The specified object '%@' is not of type TBSMStateMachine.";
static NSString * const TBSMMissingStateMachineExceptionReason = @"Containing state '%@' needs to be set up with a valid TBSMStateMachine instance.";
static NSString * const TBSMNoLcaForTransitionExceptionReason = @"No transition possible for transition '%@'.";
static NSString * const TBSMAmbiguousTransitionAttributesReason = @"Ambiguous transition attributes for event '%@' source '%@' target '%@'.";
static NSString * const TBSMAmbiguousCompoundTransitionAttributesReason = @"Ambiguous compound transition attributes for pseudo state '%@'.";
static NSString * const TBSMNoOutgoingJunctionPathReason = @"No outgoing path determined for junction '%@'.";
static NSString * const TBSMNoSerialQueueExceptionReason = @"The specified queue is not a serial queue '%@'.";
static NSString * const TBSMInvalidPathExceptionReason = @"Invalid path: '%@'.";

@implementation NSException (TBStateMachine)

+ (NSException *)tbsm_notOfTypeStateException:(id)object
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNotOfTypeStateExceptionReason, object] userInfo:nil];
}

+ (NSException *)tbsm_nonExistingStateException:(NSString *)stateName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNonExistingStateExceptionReason, stateName] userInfo:nil];
}

+ (NSException *)tbsm_noInitialStateException:(NSString *)stateMachineName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNoInitialStateExceptionReason, stateMachineName] userInfo:nil];
}

+ (NSException *)tbsm_noNameForStateException
{
    return [NSException exceptionWithName:TBSMException reason:TBSMNoNameForStateExceptionReason userInfo:nil];
}

+ (NSException *)tbsm_noNameForPseudoStateException
{
    return [NSException exceptionWithName:TBSMException reason:TBSMNoNameForPseudoStateExceptionReason userInfo:nil];
}

+ (NSException *)tbsm_noNameForEventException
{
    return [NSException exceptionWithName:TBSMException reason:TBSMNoNameForEventExceptionReason userInfo:nil];
}

+ (NSException *)tbsm_notAStateMachineException:(id)object
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNotAStateMachineExceptionReason, object] userInfo:nil];
}

+ (NSException *)tbsm_missingStateMachineException:(NSString *)stateName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMMissingStateMachineExceptionReason, stateName] userInfo:nil];
}

+ (NSException *)tbsm_noLcaForTransition:(NSString *)transitionName
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNoLcaForTransitionExceptionReason, transitionName] userInfo:nil];
}

+ (NSException *)tbsm_ambiguousTransitionAttributes:(NSString *)eventName source:(NSString *)sourceState target:(NSString *)targetState
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMAmbiguousTransitionAttributesReason, eventName, sourceState, targetState] userInfo:nil];
}

+ (NSException *)tbsm_ambiguousCompoundTransitionAttributes:(NSString *)pseudoStateName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMAmbiguousCompoundTransitionAttributesReason, pseudoStateName] userInfo:nil];
}

+ (NSException *)tbsm_noOutgoingJunctionPathException:(NSString *)junctionName
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNoOutgoingJunctionPathReason, junctionName] userInfo:nil];
}

+ (NSException *)tbsm_noSerialQueueException:(NSString *)queueName
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNoSerialQueueExceptionReason, queueName] userInfo:nil];
}

+ (NSException *)tbsm_invalidPath:(NSString *)path
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMInvalidPathExceptionReason, path] userInfo:nil];
}

@end
