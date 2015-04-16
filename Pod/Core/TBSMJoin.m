//
//  TBSMJoin.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMJoin.h"

#import "TBSMParallelState.h"

@interface TBSMJoin ()
@property (nonatomic, strong) NSArray *priv_sourceStates;
@property (nonatomic, strong) NSMutableSet *joinedSourceStates;
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
        _joinedSourceStates = [NSMutableSet new];
    }
    return self;
}

- (TBSMState *)targetState
{
    return self.target;
}

- (NSArray *)sourceStates
{
    return self.priv_sourceStates.copy;
}

- (void)setSourceStates:(NSArray *)sourceStates inRegion:(TBSMParallelState *)region target:(TBSMState *)target
{
    if (sourceStates == nil || sourceStates.count == 0 || region == nil || target == nil) {
        @throw [NSException tb_ambiguousCompoundTransitionAttributes:self.name];
    }
    _priv_sourceStates = sourceStates;
    _region = region;
    _target = target;
}

- (BOOL)joinSourceState:(TBSMState *)sourceState
{
    [self.joinedSourceStates addObject:sourceState];
    BOOL isJoinComplete = [self.joinedSourceStates isEqualToSet:[NSSet setWithArray:self.priv_sourceStates]];
    if (isJoinComplete) {
        [self.joinedSourceStates removeAllObjects];
    }
    return isJoinComplete;
}

@end
