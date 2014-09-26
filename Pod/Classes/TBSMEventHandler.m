//
//  TBSMEventHandler.m
//  Pods
//
//  Created by Julian Krumow on 07.09.14.
//
//

#import "TBSMEventHandler.h"
#import "NSException+TBStateMachine.h"


@implementation TBSMEventHandler

+ (instancetype)eventHandlerWithName:(NSString *)name target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    return [[TBSMEventHandler alloc] initWithName:name target:target action:action guard:guard];
}

- (instancetype)initWithName:(NSString *)name target:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForEventException];
    }
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
