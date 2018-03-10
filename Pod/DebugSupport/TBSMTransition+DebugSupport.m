//
//  TBSMTransition+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 02.04.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMTransition+DebugSupport.h"
#import "TBSMDebugSwizzler.h"
#import "TBSMStateMachine.h"
#import "TBSMDebugLogger.h"

@implementation TBSMTransition (DebugSupport)

+ (void)activateDebugSupport
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [TBSMDebugSwizzler swizzleMethod:@selector(canPerformTransitionWithData:) withMethod:@selector(tbsm_canPerformTransitionWithData:) onClass:[TBSMTransition class]];
    });
}

- (BOOL)tbsm_canPerformTransitionWithData:(id)data
{
    TBSMStateMachine *lca = nil;
    
    @try {
        lca = [self findLeastCommonAncestor];
    }
    @catch (NSException *exception) {
        // swallow exception in case lca could not be found since we do not want to interfere with the running application.
    }
    
    BOOL canPerform = [self tbsm_canPerformTransitionWithData:data];
    
    if (canPerform) {
        [[TBSMDebugLogger sharedInstance] log:@"[%@] performing transition: %@ data: %@", lca.name, self.name, data];
    }
    return canPerform;
}

@end
