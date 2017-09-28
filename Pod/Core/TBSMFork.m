//
//  TBSMFork.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMFork.h"
#import "TBSMParallelState.h"

@interface TBSMFork ()
@property (nonatomic, strong) NSArray *priv_targetStates;
@end

@implementation TBSMFork

+ (instancetype)forkWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

- (TBSMState *)targetState
{
    return self.region;
}

- (NSArray *)targetStates
{
    return self.priv_targetStates;
}

- (void)setTargetStates:(NSArray *)targetStates inRegion:(TBSMParallelState *)region
{
    if (targetStates == nil || targetStates.count == 0 || region == nil) {
        @throw [NSException tb_ambiguousCompoundTransitionAttributes:self.name];
    }
    _priv_targetStates = targetStates;
    _region = region;
}

@end
