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

- (void)setSourceStates:(NSArray *)sourceStates target:(TBSMState *)target
{
    if (sourceStates == nil || sourceStates.count == 0 || target == nil) {
        @throw [NSException tb_ambiguousCompoundTransitionAttributes:self.name];
    }
    _priv_sourceStates = sourceStates;
    _target = target;
}

- (BOOL)joinSourceState:(TBSMState *)sourceState
{
    [self.joinedSourceStates addObject:sourceState];
    return ([self.joinedSourceStates isEqualToArray:self.priv_sourceStates]);
}

@end
