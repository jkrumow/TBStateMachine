//
//  TBSMFork.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMFork.h"
#import "NSException+TBStateMachine.h"
#import "TBSMParallelState.h"

@interface TBSMFork ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *priv_targetStates;
@property (nonatomic, strong) TBSMParallelState *region;
@end

@implementation TBSMFork

+ (TBSMFork *)forkWithName:(NSString *)name
{
    return [[TBSMFork alloc] initWithName:name];
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

- (void)addTargetStates:(NSArray *)targetStates inRegion:(TBSMParallelState *)region
{
    _priv_targetStates = targetStates;
    _region = region;
}

@end
