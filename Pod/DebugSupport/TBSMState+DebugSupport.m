//
//  TBSMState+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 02.04.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMState+DebugSupport.h"
#import "TBSMDebugSwizzler.h"
#import "TBSMDebugLogger.h"

@implementation TBSMState (DebugSupport)

+ (void)activateDebugSupport
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [TBSMDebugSwizzler swizzleMethod:@selector(enter:targetState:data:) withMethod:@selector(tbsm_enter:targetState:data:) onClass:[TBSMState class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(exit:targetState:data:) withMethod:@selector(tbsm_exit:targetState:data:) onClass:[TBSMState class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(hasHandlerForEvent:) withMethod:@selector(tbsm_hasHandlerForEvent:) onClass:[TBSMState class]];
    });
}

- (void)tbsm_enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"\tEnter '%@' data: %@", self.name, data];
    [self tbsm_enter:sourceState targetState:targetState data:data];
}

- (void)tbsm_exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"\tExit '%@' data: %@", self.name, data];
    [self tbsm_exit:sourceState targetState:targetState data:data];
}

- (BOOL)tbsm_hasHandlerForEvent:(TBSMEvent *)event
{
    BOOL hasHandler = [self tbsm_hasHandlerForEvent:event];
    if (hasHandler) {
        [[TBSMDebugLogger sharedInstance] log:@"[%@] will handle event '%@' data: %@", self.name, event.name, event.data];
    }
    return hasHandler;
}

@end
