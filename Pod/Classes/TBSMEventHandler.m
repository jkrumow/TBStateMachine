//
//  TBSMEventHandler.m
//  TBStateMachine
//
//  Created by Julian Krumow on 07.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMEventHandler.h"
#import "NSException+TBStateMachine.h"


@implementation TBSMEventHandler

+ (instancetype)eventHandlerWithName:(NSString *)name target:(TBSMState *)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    return [[TBSMEventHandler alloc] initWithName:name target:target kind:kind action:action guard:guard];
}

- (instancetype)initWithName:(NSString *)name target:(TBSMState *)target kind:(TBSMTransitionKind)kind action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForEventException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
        _target = target;
        _kind = kind;
        _action = action;
        _guard = guard;
    }
    return self;
}

@end
