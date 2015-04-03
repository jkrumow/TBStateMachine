//
//  TBSMStateMachine+DebugSupport.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBSMEvent+DebugSupport.h"
#import "TBSMCompoundTransition+DebugSupport.h"
#import "TBSMTransition+DebugSupport.h"
#import "TBSMState+DebugSupport.h"
#import "TBSMDebugStateMachine.h"
#import "TBSMStateMachine.h"

FOUNDATION_EXPORT NSString * const TBSMDebugSupportException;

/**
 *  This category adds debug support to the `TBStateMachine` library.
 *
 *  Features:
 *
 *  - log output for handled event, performed transition and execution of setup, teardown, enter and exit handlers
 *  - time mesurement in milliseconds for each Run-to-Completion step
 *
 *  Just import it and call `-activateDebugSupport` on the top statemachine.
 */
@interface TBSMStateMachine (DebugSupport)

@property (nonatomic, strong) NSNumber *debugSupportEnabled;
@property (nonatomic, strong) NSNumber *startTime;

/**
 *  Activates debug mode for the top statemachine. Call this method on the statemachine instance at the top of the hierarchy.
 *
 *  Throws a `TBSMDebugSupportException` when `-activateDebugSupport` was called on a sub-statemachine instance.
 */
- (void)activateDebugSupport;

/**
 *  Adds an event to the event queue and calls the completion handler afterwards.
 *
 *  Throws a `TBSMDebugSupportException` when `-activateDebugSupport` was not called beforehand.
 *
 *  @param event      The given `TBSMEvent` instance.
 *  @param completion The completion handler to be executed when event has been handled.
 */
- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(TBSMDebugCompletionBlock)completion;
@end
