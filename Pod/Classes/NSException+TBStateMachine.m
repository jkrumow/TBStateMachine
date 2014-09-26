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
static NSString * const TBSMNotAStateMachineExceptionReason = @"The specified object '%@' is not of type TBSMStateMachine.";
static NSString * const TBSMMissingStateMachineExceptionReason = @"Sub state '%@' needs to be initialized with a valid TBSMStateMachine instance.";


@implementation NSException (TBStateMachine)

+ (NSException *)tb_notOfTypeStateMachineStateException:(id)object
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNotAStateMachineExceptionReason, object] userInfo:nil];
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

+ (NSException *)tb_notAStateMachineException:(id)object
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMNotAStateMachineExceptionReason, object] userInfo:nil];
}

+ (NSException *)tb_missingStateMachineException:(NSString *)stateName
{
    return [NSException exceptionWithName:TBSMException reason:[NSString stringWithFormat:TBSMMissingStateMachineExceptionReason, stateName] userInfo:nil];
}

@end
