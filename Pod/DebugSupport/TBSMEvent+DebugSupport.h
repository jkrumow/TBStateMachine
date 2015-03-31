//
//  TBSMEvent+DebugSupport.h
//  Pods
//
//  Created by Julian Krumow on 31.03.15.
//
//

#import "TBSMEvent.h"

typedef void (^TBSMDebugCompletionBlock)(void);

@interface TBSMEvent (DebugSupport)

@property (nonatomic, copy) TBSMDebugCompletionBlock completionBlock;
@end
