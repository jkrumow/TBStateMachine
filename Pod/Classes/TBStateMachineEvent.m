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
	return [[TBStateMachineEvent alloc] initWithName:name data:nil];
}

+ (TBStateMachineEvent *)eventWithName:(NSString *)name data:(NSDictionary *)data
{
	return [[TBStateMachineEvent alloc] initWithName:name data:data];
}


- (instancetype)initWithName:(NSString *)name data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _name = name.copy;
        _data = data;
    }
    return self;
}

@end
