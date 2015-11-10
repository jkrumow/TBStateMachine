//
//  TBSMEvent+DebugSupport.h
//  TBStateMachine
//
//  Created by Julian Krumow on 31.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMEvent.h"

typedef void (^TBSMDebugCompletionBlock)(void);

@interface TBSMEvent (DebugSupport)

@property (nonatomic, copy, nonnull) TBSMDebugCompletionBlock completionBlock;
@end
