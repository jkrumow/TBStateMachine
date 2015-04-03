//
//  TBSMCompoundTransition+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 02.04.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <objc/runtime.h>

#import "TBSMCompoundTransition+DebugSupport.h"
#import "TBSMStateMachine.h"

@implementation TBSMCompoundTransition (DebugSupport)

+ (void)activateDebugSupport
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [TBSMCompoundTransition class];
        SEL originalSelector = @selector(performTransitionWithData:);
        SEL swizzledSelector = @selector(tb_performTransitionWithData:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (BOOL)tb_performTransitionWithData:(NSDictionary *)data
{
    [self _logTransitionWithData:data];
    return [self tb_performTransitionWithData:data];
}

- (void)_logTransitionWithData:(NSDictionary *)data
{
    TBSMStateMachine *lca = nil;
    
    @try {
        lca = [self findLeastCommonAncestor];
    }
    @catch (NSException *exception) {
        // swallow exception in case lca could not be found since we do not want to interfere with the running application.
    }
    
    NSLog(@"[%@] will perform compound transition: %@ data: %@", lca.name, self.name, data.description);
}

@end
