//
//  TBSMJoin.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMJoin.h"
#import "NSException+TBStateMachine.h"
#import "TBSMParallelState.h"

@interface TBSMJoin ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *priv_sourceStates;
@property (nonatomic, strong) TBSMParallelState *region;
@property (nonatomic, strong) TBSMState *target;
@end

@implementation TBSMJoin

+ (TBSMJoin *)joinWithName:(NSString *)name
{
    return [[TBSMJoin alloc] initWithName:name];
}

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

- (void)addSourceStates:(NSArray *)sourceStates inRegion:(TBSMParallelState *)region target:(TBSMState *)target
{
    _priv_sourceStates = sourceStates;
    _region = region;
    _target = target;
}

@end
