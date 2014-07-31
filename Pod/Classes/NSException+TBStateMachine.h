//
//  NSException+TBStateMachine.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Defines the name of NSExceptions thrown by `TBStateMachine`.
 */
FOUNDATION_EXPORT NSString * const TBStateMachineException;

/**
 *  This category defines methods to create NSException instances with name defined by the constant `TBStateMachineException`.
 */
@interface NSException (TBStateMachine)

/**
 *  Thrown when an object does not conform to the `TBStateMachineNode` protocol.
 *
 *  The `reason:` string will contain a description of the object.
 *
 *  @param object The object in question.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_doesNotConformToNodeProtocolException:(id)object;

/**
 *  Thrown when a specified `TBStateMachineNode` instance does not exist in the state machine.
 *
 *  The `reason:` string will contain the name of the state.
 *
 *  @param stateName The name of the specified `TBStateMachineNode`.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_nonExistingStateException:(NSString *)stateName;

/**
 *  Thrown when a specified `TBStateMachineNode` can not be re-entered.
 *
 *  The `reason:` string will contain the name of the state.
 *
 *  @param stateName The name of the specified `TBStateMachineNode`.
 *
 *  @return The NSException instance.
 */
+ (NSException *)tb_reEntryStateDisallowedException:(NSString *)stateName;

@end
