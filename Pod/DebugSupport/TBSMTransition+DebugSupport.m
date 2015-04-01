//
//  TBSMTransition+DebugSupport.m
//  Pods
//
//  Created by Julian Krumow on 02.04.15.
//
//

#import <objc/runtime.h>

#import "TBSMTransition+DebugSupport.h"
#import "TBSMStateMachine.h"

@implementation TBSMTransition (DebugSupport)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [TBSMTransition class];
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
    NSLog(@"'%@' will perform transition: %@ data: %@", [[self findLeastCommonAncestor] name], self.name, data.description);
}

@end
