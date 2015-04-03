//
//  TBSMStateMachine+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <objc/runtime.h>

#import "TBSMStateMachine+DebugSupport.h"

NSString * const TBSMDebugSupportException = @"TBSMDebugSupportException";

@implementation TBSMStateMachine (DebugSupport)
@dynamic debugSupportEnabled;
@dynamic startTime;

- (NSNumber *)debugSupportEnabled
{
    return objc_getAssociatedObject(self, @selector(debugSupportEnabled));
}

- (void)setDebugSupportEnabled:(NSNumber *)debugSupportEnabled
{
    objc_setAssociatedObject(self, @selector(debugSupportEnabled), debugSupportEnabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)startTime
{
    return objc_getAssociatedObject(self, @selector(startTime));
}

- (void)setStartTime:(NSNumber *)startTime
{
    objc_setAssociatedObject(self, @selector(startTime), startTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)activateDebugSupport
{
    self.debugSupportEnabled = @YES;
    
    if (self.parentNode) {
        @throw [NSException exceptionWithName:TBSMDebugSupportException reason:@"Debug support not available on sub-statemachines." userInfo:nil];
    }
    
    object_setClass(self, objc_getClass("TBSMDebugStateMachine"));
    
    [TBSMCompoundTransition activateDebugSupport];
    [TBSMState activateDebugSupport];
    [TBSMTransition activateDebugSupport];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // We use a dedicated subclass to swizzle certain methods only on the top state machine.
        Class class = [TBSMDebugStateMachine class];
        
        // handleEvent:
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
        
        // -setUp:
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
        
        // -tearDown:
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
    if (self.debugSupportEnabled.boolValue == NO) {
        @throw [NSException exceptionWithName:TBSMDebugSupportException reason:@"Method only available with activated DebugSupport." userInfo:nil];
    }
    event.completionBlock = completion;
    [self scheduleEvent:event];
}

- (BOOL)tb_handleEvent:(TBSMEvent *)event
{
    NSLog(@"[%@]: will handle event '%@' data: %@", self.name, event.name, event.data.description);
    
    self.startTime = @(CACurrentMediaTime());
    BOOL hasHandledEvent = [self tb_handleEvent:event];
    NSTimeInterval timeInterval = ((CACurrentMediaTime() - self.startTime.doubleValue) * 1000);
    
    NSLog(@"[%@]: run-to-completion step took %f milliseconds", self.name, timeInterval);
    NSLog(@"[%@]: remaining events in queue: %lu\n\n", self.name, (unsigned long)self.scheduledEventsQueue.operationCount - 1);
    
    TBSMDebugCompletionBlock completionBlock = event.completionBlock;
    if (completionBlock) {
        completionBlock();
    }
    return hasHandledEvent;
}

- (void)tb_setUp:(NSDictionary *)data
{
    NSLog(@"[%@] setup data: %@", self.name, data.description);
    [self tb_setUp:data];
}

- (void)tb_tearDown:(NSDictionary *)data
{
    NSLog(@"[%@] teardown data: %@", self.name, data.description);
    [self tb_tearDown:data];
}

@end
