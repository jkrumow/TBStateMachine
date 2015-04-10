//
//  TBSMChoice.m
//  TBStateMachine
//
//  Created by Julian Krumow on 23.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMChoice.h"

@implementation TBSMChoice

+ (TBSMChoice *)choiceWithName:(NSString *)name
{
    return [[TBSMChoice alloc] initWithName:name];
}

@end
