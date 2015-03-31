//
//  TBSMStateMachine+DebugSupport.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine.h"

/**
 *  This category adds debug support to the TBStateMachine library.
 */
@interface TBSMStateMachine (DebugSupport)

@property (nonatomic, strong) NSNumber *enableLogging;
@property (nonatomic, strong) NSNumber *timeInterval;

- (void)logDebugOutput:(BOOL)logDebugOutput;

/**
 *  Adds an event to the event queue and calls the completion handler afterwards.
 *
 *  @param event      The given `TBSMEvent` instance.
 *  @param completion The completion handler to be executed when event has been handled.
 */
- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(void (^)(void))completion;
@end
