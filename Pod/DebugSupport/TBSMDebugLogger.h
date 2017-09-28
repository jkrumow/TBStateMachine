//
//  TBSMDebugLogger.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.10.16.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface TBSMDebugLogger : NSObject

+ (instancetype)sharedInstance;
- (void)log:(NSString *)format, ...;
@end
NS_ASSUME_NONNULL_END
