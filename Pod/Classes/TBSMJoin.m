//
//  TBSMJoin.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMJoin.h"

#import "TBSMParallelState.h"

@interface TBSMJoin ()
@property (nonatomic, strong) NSArray *priv_sourceStates;
@property (nonatomic, strong) NSMutableArray *joinedSourceStates;
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
    self = [super initWithName:name];
    if (self) {
        _joinedSourceStates = [NSMutableArray new];
    }
    return self;
}

- (TBSMState *)targetState
{
    return self.target;
}

- (void)addSourceStates:(NSArray *)sourceStates inRegion:(TBSMParallelState *)region target:(TBSMState *)target
{
    // TODO: throw exception when region or target is nil
    _priv_sourceStates = sourceStates;
    _region = region;
    _target = target;
}

- (BOOL)joinSourceState:(TBSMState *)sourceState
{
    // TODO: throw exception if source state has not been added
    [self.joinedSourceStates addObject:sourceState];
    return ([self.joinedSourceStates isEqualToArray:self.priv_sourceStates]);
}

@end
