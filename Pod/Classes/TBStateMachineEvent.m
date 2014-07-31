//
//  TBStateMachineEvent.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineEvent.h"

@implementation TBStateMachineEvent

- (instancetype)initWithName:(NSString *)name data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _name = name;
        _data = data;
    }
    return self;
}

@end
