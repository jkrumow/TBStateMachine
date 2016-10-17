//
//  TBSMEvent+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 31.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <objc/runtime.h>

#import "TBSMEvent+DebugSupport.h"

@implementation TBSMEvent (DebugSupport)
@dynamic completionBlock;

- (TBSMDebugCompletionBlock)completionBlock
{
    return objc_getAssociatedObject(self, @selector(completionBlock));
}

- (void)setCompletionBlock:(TBSMDebugCompletionBlock)completionBlock
{
    objc_setAssociatedObject(self, @selector(completionBlock), completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
