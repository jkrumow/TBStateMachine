//
//  TBSMJoin.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMJoin.h"
#import "TBSMParallelState.h"

@interface TBSMJoin ()
@property (nonatomic, strong) NSArray *priv_sourceStates;
@property (nonatomic, strong) NSMutableSet *joinedSourceStates;
@property (nonatomic, strong) TBSMState *target;
@end

@implementation TBSMJoin

+ (instancetype)joinWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
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
    if ([self.joinedSourceStates containsObject:sourceState] == NO) {
        [self.joinedSourceStates addObject:sourceState];
        if ([self.joinedSourceStates isEqualToSet:[NSSet setWithArray:self.priv_sourceStates]]) {
            [self.joinedSourceStates removeAllObjects];
            return YES;
        }
    }
    return NO;
}

@end
