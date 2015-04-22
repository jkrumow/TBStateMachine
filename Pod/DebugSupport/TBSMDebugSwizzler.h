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

+ (void)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector onClass:(Class)class;
@end
