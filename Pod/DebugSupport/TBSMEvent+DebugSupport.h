//
//  TBSMEvent+DebugSupport.h
//  TBStateMachine
//
//  Created by Julian Krumow on 31.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import "TBSMEvent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TBSMDebugCompletionBlock)(void);

@interface TBSMEvent (DebugSupport)

@property (nonatomic, copy) TBSMDebugCompletionBlock completionBlock;
@end
NS_ASSUME_NONNULL_END
