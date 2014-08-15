//
//  NSException+TBStateMachine.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "NSException+TBStateMachine.h"


NSString * const TBStateMachineException = @"TBStateMachineException";

static NSString * const TBNotImplementedNodeProtocolExceptionReason = @"The specified object '%@' must implement protocol TBStateMachineProtocol.";
static NSString * const TBNonExistingStateExceptionReason = @"The specified state '%@' does not exist.";
static NSString * const TBNoInitialStateExceptionReason = @"Initial state needs to be set on %@.";


@implementation NSException (TBStateMachine)

+ (NSException *)tb_doesNotConformToNodeProtocolException:(id)object
{
    return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBNotImplementedNodeProtocolExceptionReason, object] userInfo:nil];
}

+ (NSException *)tb_nonExistingStateException:(NSString *)stateName
{
	return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBNonExistingStateExceptionReason, stateName] userInfo:nil];
}

+ (NSException *)tb_noInitialStateException:(NSString *)stateMachineName;
{
	return [NSException exceptionWithName:TBStateMachineException reason:[NSString stringWithFormat:TBNonExistingStateExceptionReason, stateMachineName] userInfo:nil];
}

@end
