//
//  TBSMState+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 02.04.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <objc/runtime.h>

#import "TBSMState+DebugSupport.h"

@implementation TBSMState (DebugSupport)

+ (void)activateDebugSupport
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [TBSMState class];
        SEL originalSelector = @selector(enter:targetState:data:);
        SEL swizzledSelector = @selector(tb_enter:targetState:data:);
        
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
        
        originalSelector = @selector(exit:targetState:data:);
        swizzledSelector = @selector(tb_exit:targetState:data:);
        
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        didAddMethod =
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

- (void)tb_enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    NSLog(@"\tEnter '%@' source: '%@' target: '%@' data: %@", self.name, sourceState.name, targetState.name, data.description);
    [self tb_enter:sourceState targetState:targetState data:data];
}

- (void)tb_exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data
{
    NSLog(@"\tExit '%@' source: '%@' target: '%@' data: %@", self.name, sourceState.name, targetState.name, data.description);
    [self tb_exit:sourceState targetState:targetState data:data];
}

@end
