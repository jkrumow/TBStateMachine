//
//  TBSMEvent.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMEvent.h"
#import "NSException+TBStateMachine.h"

@implementation TBSMEvent

+ (TBSMEvent *)eventWithName:(NSString *)name
{
    return [[TBSMEvent alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForEventException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
    }
    return self;
}

@end
