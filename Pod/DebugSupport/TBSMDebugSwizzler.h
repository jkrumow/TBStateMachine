//
//  TBSMDebugSwizzler.h
//  TBStateMachine
//
//  Created by Julian Krumow on 22.04.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface TBSMDebugSwizzler : NSObject

+ (void)swizzleMethod:(nonnull SEL)originalSelector withMethod:(nonnull SEL)swizzledSelector onClass:(nonnull Class)class;
@end
