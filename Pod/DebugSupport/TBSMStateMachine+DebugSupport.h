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

/**
 *  This category adds debug support to the TBStateMachine library.
 *  Just import it and it will automatically perform logging.
 */
@interface TBSMStateMachine (DebugSupport)

@property (nonatomic, strong) NSNumber *startTime;

+ (void)activateDebugSupport;

/**
 *  Adds an event to the event queue and calls the completion handler afterwards.
 *
 *  @param event      The given `TBSMEvent` instance.
 *  @param completion The completion handler to be executed when event has been handled.
 */
- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(TBSMDebugCompletionBlock)completion;
@end
