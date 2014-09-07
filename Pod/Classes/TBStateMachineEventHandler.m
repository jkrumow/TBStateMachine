//
//  TBStateMachineEventHandler.m
//  Pods
//
//  Created by Julian Krumow on 07.09.14.
//
//

#import "TBStateMachineEventHandler.h"


@implementation TBStateMachineEventHandler

+ (instancetype)eventHandlerWithName:(NSString *)name target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard
{
    return [[TBStateMachineEventHandler alloc] initWithName:name target:target action:action guard:guard];
}

- (instancetype)initWithName:(NSString *)name target:(id<TBStateMachineNode>)target action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard
{
    self = [super init];
    if (self) {
        _name = name.copy;
        _target = target;
        _action = action;
        _guard = guard;
    }
    return self;
}

@end
