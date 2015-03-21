//
//  TBSMFork.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMFork.h"
#import "TBSMParallelState.h"

@interface TBSMFork ()
@property (nonatomic, strong) NSArray *priv_targetStates;
@property (nonatomic, strong) TBSMParallelState *region;
@end

@implementation TBSMFork

+ (TBSMFork *)forkWithName:(NSString *)name
{
    return [[TBSMFork alloc] initWithName:name];
}

- (TBSMState *)targetState
{
    return self.region;
}

- (void)addTargetStates:(NSArray *)targetStates inRegion:(TBSMParallelState *)region
{
    // TODO: throw exception when region is nil
    _priv_targetStates = targetStates;
    _region = region;
}

@end
