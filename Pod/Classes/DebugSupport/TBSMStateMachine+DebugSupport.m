//
//  TBSMStateMachine+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <objc/runtime.h>

#import "TBSMStateMachine+DebugSupport.h"


@implementation TBSMStateMachine (DebugSupport)
@dynamic enableLogging;
@dynamic timeInterval;

- (void)logDebugOutput:(BOOL)logDebugOutput
{
	objc_setAssociatedObject(self, @selector(enableLogging), @(logDebugOutput), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)_logEvent:(TBSMEvent *)event
{
    objc_setAssociatedObject(self, @selector(timeInterval), @(CACurrentMediaTime()), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSNumber *log = objc_getAssociatedObject(self, @selector(enableLogging));
    if (log.boolValue) {
        NSLog(@"Will handle event '%@' with data: %@", event.name, event.data.description);
    }
}

- (void)_logCompletion
{
    NSNumber *startTime = objc_getAssociatedObject(self, @selector(timeInterval));
    NSNumber *log = objc_getAssociatedObject(self, @selector(enableLogging));
    if (log.boolValue) {
        NSLog(@"Run to completion took %f milliseconds.", (CACurrentMediaTime() - startTime.doubleValue) * 1000);
    }
}


- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(void (^)(void))completion
{
    if (self.parentNode) {
        TBSMStateMachine *topStateMachine = (TBSMStateMachine *)[self.parentNode parentNode];
        [topStateMachine scheduleEvent:event];
        return;
    }
    
    [self.scheduledEventsQueue addOperationWithBlock:^{
        
        [self _logEvent:event];
        
        [self handleEvent:event];

        [self _logCompletion];
        
        if (completion) {
            completion();
        }
    }];
}

@end
