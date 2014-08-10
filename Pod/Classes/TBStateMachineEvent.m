//
//  TBStateMachineEvent.m
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBStateMachineEvent.h"

@implementation TBStateMachineEvent

+ (TBStateMachineEvent *)eventWithName:(NSString *)name
{
	return [[TBStateMachineEvent alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name.copy;
    }
    return self;
}

@end
