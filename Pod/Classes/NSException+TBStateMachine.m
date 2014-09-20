//
//  NSException+TBStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "NSException+TBStateMachine.h"


NSString * const TBStateMachineException = @"TBStateMachineException";

static NSString * const TBNotOfTypeTBStateMachineStateExceptionReason = @"The specified object '%@' must be of type TBStateMachineState.";
static NSString * const TBNonExistingStateExceptionReason = @"The specified state '%@' does not exist.";
static NSString * const TBNoInitialStateExceptionReason = @"Initial state needs to be set on %@.";
static NSString * const TBNoNameForStateExceptionReason = @"State needs to have a valid name.";
static NSString * const TBNoNameForEventExceptionReason = @"Event needs to have a valid name.";
static NSString * const TBNotAStateMachineExceptionReason = @"The specified object '%@' is not of type TBStateMachine.";
static NSString * const TBMissingStateMachineExceptionReason = @"Sub state '%@' needs to be initialized with a valid TBStateMachine instance.";


@implementation NSException (TBStateMachine)

+ (NSException *)tb_notOfTypeTBStateMachineStateException:(id)object
{
    return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBNotOfTypeTBStateMachineStateExceptionReason, object] userInfo:nil];
}

+ (NSException *)tb_nonExistingStateException:(NSString *)stateName
{
    return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBNonExistingStateExceptionReason, stateName] userInfo:nil];
}

+ (NSException *)tb_noInitialStateException:(NSString *)stateMachineName
{
    return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBNonExistingStateExceptionReason, stateMachineName] userInfo:nil];
}

+ (NSException *)tb_noNameForStateException
{
    return [NSException exceptionWithName:TBStateMachineException reason:TBNoNameForStateExceptionReason userInfo:nil];
}

+ (NSException *)tb_noNameForEventException
{
    return [NSException exceptionWithName:TBStateMachineException reason:TBNoNameForEventExceptionReason userInfo:nil];
}

+ (NSException *)tb_notAStateMachineException:(id)object
{
    return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBNotAStateMachineExceptionReason, object] userInfo:nil];
}

+ (NSException *)tb_missingStateMachineException:(NSString *)stateName
{
    return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBMissingStateMachineExceptionReason, stateName] userInfo:nil];
}

@end
