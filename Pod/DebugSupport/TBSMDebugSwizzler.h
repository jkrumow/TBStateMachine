//
//  TBSMDebugSwizzler.h
//  TBStateMachine
//
//  Created by Julian Krumow on 22.04.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBSMDebugSwizzler : NSObject

+ (void)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector onClass:(Class)class;
@end
NS_ASSUME_NONNULL_END
