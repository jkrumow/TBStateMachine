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

+ (TBSMEvent *)eventWithName:(NSString *)name data:(NSDictionary *)data
{
    return [[TBSMEvent alloc] initWithName:name data:data];
}

- (instancetype)initWithName:(NSString *)name data:(NSDictionary *)data
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForEventException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
        _data = data;
    }
    return self;
}

@end
