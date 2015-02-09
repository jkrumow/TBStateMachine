//
//  NSException+TBStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "NSException+TBStateMachine.h"


NSString * const TBSMException = @"TBSMException";

static NSString * const TBSMNotOfTypeStateExceptionReason = @"The specified object '%@' must be of type TBSMState.";
static NSString * const TBSMNonExistingStateExceptionReason = @"The specified state '%@' does not exist.";
static NSString * const TBSMNoInitialStateExceptionReason = @"Initial state needs to be set on %@.";
static NSString * const TBSMNoNameForStateExceptionReason = @"State needs to have a valid name.";
static NSString * const TBSMNoNameForEventExceptionReason = @"Event needs to have a valid name.";
static NSString * const TBSMCannotDeferRegisteredEventExceptionReason = @"Can not defer event %@ which is already registered.";
static NSString * const TBSMCannotRegisterDeferredEventExceptionReason = @"Can not register event %@ which is already defered.";
static NSString * const TBSMNotAStateMachineExceptionReason = @"The specified object '%@' is not of type TBSMStateMachine.";
static NSString * const TBSMMissingStateMachineExceptionReason = @"Sub state '%@' needs to be initialized with a valid TBSMStateMachine instance.";
static NSString * const TBSMNoLcaForTransitionExceptionReason = @"No transition possible for transition %@.";
static NSString * const TBSMAmbiguousTransitionAttributesReason = @"Ambiguous transition attributes for event %@";

@implementation NSException (TBStateMachine)

+ (NSException *)tb_notOfTypeStateException:(id)object
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNotOfTypeStateExceptionReason, object] userInfo:nil];
}

+ (NSException *)tb_nonExistingStateException:(NSString *)stateName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNonExistingStateExceptionReason, stateName] userInfo:nil];
}

+ (NSException *)tb_noInitialStateException:(NSString *)stateMachineName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNonExistingStateExceptionReason, stateMachineName] userInfo:nil];
}

+ (NSException *)tb_noNameForStateException
{
    return [NSException exceptionWithName:TBSMException reason:TBSMNoNameForStateExceptionReason userInfo:nil];
}

+ (NSException *)tb_noNameForEventException
{
    return [NSException exceptionWithName:TBSMException reason:TBSMNoNameForEventExceptionReason userInfo:nil];
}

+ (NSException *)tb_cannotDeferRegisteredEvent:(NSString *)eventName
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMCannotDeferRegisteredEventExceptionReason, eventName] userInfo:nil];
}

+ (NSException *)tb_cannotRegisterDeferredEvent:(NSString *)eventName
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMCannotRegisterDeferredEventExceptionReason, eventName] userInfo:nil];
}

+ (NSException *)tb_notAStateMachineException:(id)object
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNotAStateMachineExceptionReason, object] userInfo:nil];
}

+ (NSException *)tb_missingStateMachineException:(NSString *)stateName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMMissingStateMachineExceptionReason, stateName] userInfo:nil];
}

+ (NSException *)tb_noLcaForTransition:(NSString *)transitionName
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNoLcaForTransitionExceptionReason, transitionName] userInfo:nil];
}

+ (NSException *)tb_ambiguousTransitionAttributes:(NSString *)eventName
{
	return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMAmbiguousTransitionAttributesReason, eventName] userInfo:nil];
}

@end
