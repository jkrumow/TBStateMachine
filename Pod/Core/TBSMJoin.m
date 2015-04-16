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
@property (nonatomic, strong) NSOrderedSet *priv_sourceStates;
@property (nonatomic, strong) NSMutableOrderedSet *joinedSourceStates;
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
        _joinedSourceStates = [NSMutableOrderedSet new];
    }
    return self;
}

- (TBSMState *)targetState
{
    return self.target;
}

- (NSArray *)sourceStates
{
    return self.priv_sourceStates.array;
}

- (void)setSourceStates:(NSArray *)sourceStates inRegion:(TBSMParallelState *)region target:(TBSMState *)target
{
    if (sourceStates == nil || sourceStates.count == 0 || region == nil || target == nil) {
        @throw [NSException tb_ambiguousCompoundTransitionAttributes:self.name];
    }
    _priv_sourceStates = [NSOrderedSet orderedSetWithArray:sourceStates];
    _region = region;
    _target = target;
}

- (BOOL)joinSourceState:(TBSMState *)sourceState
{
    [self.joinedSourceStates addObject:sourceState];
    return ([self.joinedSourceStates isEqualToOrderedSet:self.priv_sourceStates]);
}

@end
