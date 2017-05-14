//
//  TBSMStateMachine+DebugSupport.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#include <mach/mach_time.h>

#import "TBSMEvent+DebugSupport.h"
#import "TBSMStateMachine.h"

NS_ASSUME_NONNULL_BEGIN
@interface TBSMStateMachine (DebugSupport)
@property (nonatomic, strong) NSNumber *millisecondsPerMachTime;
@property (nonatomic, strong) NSMutableArray *eventDebugQueue;

+ (void)activateDebugSupport;

- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(nullable TBSMDebugCompletionBlock)completion;
@end
NS_ASSUME_NONNULL_END
