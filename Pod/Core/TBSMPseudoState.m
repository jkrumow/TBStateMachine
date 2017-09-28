//
//  TBSMPseudoState.m
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMPseudoState.h"


@implementation TBSMPseudoState

- (instancetype)initWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForPseudoStateException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
    }
    return self;
}

- (TBSMState *)targetState
{
    return nil;
}
@end
