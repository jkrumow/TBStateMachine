//
//  TBStateMachineEventHandler.h
//  Pods
//
//  Created by Julian Krumow on 07.09.14.
//
//

#import <Foundation/Foundation.h>

#import "TBStateMachineTransition.h"

@interface TBStateMachineEventHandler : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) id<TBStateMachineNode> target;
@property (nonatomic, strong, readonly) TBStateMachineActionBlock action;
@property (nonatomic, strong, readonly) TBStateMachineGuardBlock guard;

+ (instancetype)eventHandlerWithName:(NSString *)name target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard;

- (instancetype)initWithName:(NSString *)name target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard;

@end
