//
//  TBSMStateMachine+TestHelper.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine+TestHelper.h"

@implementation TBSMStateMachine (TestHelper)

- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(void (^)(void))completion
{
    if (self.parentNode) {
        TBSMStateMachine *topStateMachine = (TBSMStateMachine *)[self.parentNode parentNode];
        [topStateMachine scheduleEvent:event];
        return;
    }
    
    [self.scheduledEventsQueue addOperationWithBlock:^{
        [self handleEvent:event];
        
        if (completion) {
            completion();
        }
    }];
}

@end
