//
//  TBSMStateMachine+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <objc/runtime.h>

#import "TBSMStateMachine+DebugSupport.h"
#import "TBSMDebugStateMachine.h"


@implementation TBSMStateMachine (DebugSupport)
@dynamic timeInterval;

- (NSNumber *)timeInterval
{
    return objc_getAssociatedObject(self, @selector(timeInterval));
}

- (void)setTimeInterval:(NSNumber *)timeInterval
{
    objc_setAssociatedObject(self, @selector(timeInterval), timeInterval, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(TBSMDebugCompletionBlock)completion
{
    // This method will only be swizzled on top-statemachines.
    if (self.parentNode == nil) {
        object_setClass(self, objc_getClass("TBSMDebugStateMachine"));
    }
    event.completionBlock = completion;
    [self tb_scheduleEvent:event];
}

#pragma mark - Method swizzling

+ (void)load
{
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
        
        class = [TBSMStateMachine class];
        originalSelector = @selector(switchState:targetState:action:data:);
        swizzledSelector = @selector(tb_switchState:targetState:action:data:);
        
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
        
        originalSelector = @selector(switchState:targetStates:region:action:data:);
        swizzledSelector = @selector(tb_switchState:targetStates:region:action:data:);
        
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

    [self _logEvent:event];
    
    BOOL hasHandledEvent = [self tb_handleEvent:event];
    TBSMDebugCompletionBlock completionBlock = event.completionBlock;
    
    [self _logCompletion];
    
    if (completionBlock) {
        completionBlock();
    }
    return hasHandledEvent;
}

- (void)tb_switchState:(TBSMState *)sourceState targetState:(TBSMState *)targetState action:(TBSMActionBlock)action data:(NSDictionary *)data
{
    [self _logSwitch:sourceState targetState:targetState action:action data:data];
    [self tb_switchState:sourceState targetState:targetState action:action data:data];
}

- (void)tb_switchState:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region action:(TBSMActionBlock)action data:(NSDictionary *)data
{
    [self _logSwitch:sourceState targetStates:targetStates region:region action:action data:data];
    [self tb_switchState:sourceState targetStates:targetStates region:region action:action data:data];
}

#pragma mark - Logging

- (void)_logEvent:(TBSMEvent *)event
{
    self.timeInterval = @(CACurrentMediaTime());
    NSLog(@"'%@' will handle event '%@' with data: %@", self.name, event.name, event.data.description);
}

- (void)_logCompletion
{
    NSLog(@"'%@': Run to completion took %f milliseconds.", self.name, (CACurrentMediaTime() - self.timeInterval.doubleValue) * 1000);
    NSLog(@"'%@': Number of remaining events in queue: %lu", self.name, (unsigned long)self.scheduledEventsQueue.operationCount - 1);
}

- (void)_logSwitch:(TBSMState *)sourceState targetState:(TBSMState *)targetState action:(TBSMActionBlock)action data:(NSDictionary *)data
{
    NSLog(@"'%@' will perform transition from '%@' to '%@' with action '%@' data '%@'", self.name, sourceState.name, targetState.name, action, data.description);
}

- (void)_logSwitch:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMParallelState *)region action:(TBSMActionBlock)action data:(NSDictionary *)data
{
    NSString *targetNames = [[targetStates valueForKeyPath:@"name"] componentsJoinedByString:@", "];
    NSLog(@"'%@' will perform transition from '%@' to '%@' in region '%@' with action '%@' data '%@'", self.name, sourceState.name, targetNames, region.name, action, data.description);
}

@end
