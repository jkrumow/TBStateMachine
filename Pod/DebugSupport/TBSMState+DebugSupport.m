//
//  TBSMState+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 02.04.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMState+DebugSupport.h"
#import "TBSMDebugSwizzler.h"
#import "TBSMDebugLogger.h"

@implementation TBSMState (DebugSupport)

+ (void)activateDebugSupport
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [TBSMDebugSwizzler swizzleMethod:@selector(enter:targetState:data:) withMethod:@selector(tb_enter:targetState:data:) onClass:[TBSMState class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(exit:targetState:data:) withMethod:@selector(tb_exit:targetState:data:) onClass:[TBSMState class]];
    });
}

- (void)tb_enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"\tEnter '%@' data: %@", self.name, data];
    [self tb_enter:sourceState targetState:targetState data:data];
}

- (void)tb_exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"\tExit '%@' data: %@", self.name, data];
    [self tb_exit:sourceState targetState:targetState data:data];
}

@end
