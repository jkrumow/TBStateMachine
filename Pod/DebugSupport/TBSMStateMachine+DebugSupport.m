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
@dynamic startTime;

- (NSNumber *)startTime
{
    return objc_getAssociatedObject(self, @selector(startTime));
}

- (void)setStartTime:(NSNumber *)startTime
{
    objc_setAssociatedObject(self, @selector(startTime), startTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)activateDebugSupport
{
    [TBSMCompoundTransition activateDebugSupport];
    [TBSMState activateDebugSupport];
    [TBSMTransition activateDebugSupport];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [TBSMDebugStateMachine class];
        SEL originalSelector = @selector(handleEvent:);
        SEL swizzledSelector = @selector(tb_handleEvent:);
        
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
        
        class = [TBSMStateMachine class];
        originalSelector = @selector(scheduleEvent:);
        swizzledSelector = @selector(tb_scheduleEvent:);
        
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
        
        originalSelector = @selector(setUp:);
        swizzledSelector = @selector(tb_setUp:);
        
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
        
        originalSelector = @selector(tearDown:);
        swizzledSelector = @selector(tb_tearDown:);
        
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

- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(TBSMDebugCompletionBlock)completion
{
    // This method will only be swizzled on top-statemachines.
    if (self.parentNode == nil) {
        object_setClass(self, objc_getClass("TBSMDebugStateMachine"));
        event.completionBlock = completion;
    }
    [self tb_scheduleEvent:event];
}

- (void)tb_scheduleEvent:(TBSMEvent *)event
{
    // This method will only be swizzled on top-statemachines.
    if (self.parentNode == nil) {
        object_setClass(self, objc_getClass("TBSMDebugStateMachine"));
    }
    [self tb_scheduleEvent:event];
}

- (BOOL)tb_handleEvent:(TBSMEvent *)event
{
    NSLog(@"'%@' will handle event '%@' with data: %@", self.name, event.name, event.data.description);
    
    self.startTime = @(CACurrentMediaTime());
    BOOL hasHandledEvent = [self tb_handleEvent:event];
    NSTimeInterval timeInterval = ((CACurrentMediaTime() - self.startTime.doubleValue) * 1000);
    
    NSLog(@"'%@': Run to completion took %f milliseconds.", self.name, timeInterval);
    NSLog(@"'%@': Number of remaining events in queue: %lu", self.name, (unsigned long)self.scheduledEventsQueue.operationCount - 1);
    
    TBSMDebugCompletionBlock completionBlock = event.completionBlock;
    if (completionBlock) {
        completionBlock();
    }
    return hasHandledEvent;
}

- (void)tb_setUp:(NSDictionary *)data
{
    NSLog(@"Setup '%@' data: %@", self.name, data.description);
    [self tb_setUp:data];
}

- (void)tb_tearDown:(NSDictionary *)data
{
    NSLog(@"Teardown '%@' data: %@", self.name, data.description);
    [self tb_tearDown:data];
}

@end
