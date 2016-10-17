//
//  TBSMDebugSwizzler.m
//  TBStateMachine
//
//  Created by Julian Krumow on 22.04.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import "TBSMDebugSwizzler.h"

@implementation TBSMDebugSwizzler

+ (void)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector onClass:(Class)class
{
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
}

@end
