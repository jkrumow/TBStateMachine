//
//  TBSMJunction.m
//  TBStateMachine
//
//  Created by Julian Krumow on 23.03.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import "TBSMJunction.h"

@interface TBSMJunction ()
@property (nonatomic, strong) NSMutableArray *outgoingPaths;
@end

@implementation TBSMJunction

+ (instancetype)junctionWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _outgoingPaths = [NSMutableArray new];
    }
    return self;
}

- (NSArray *)targetStates
{
    return [self.outgoingPaths valueForKeyPath:@"targetState"];
}

- (void)addOutgoingPathWithTarget:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    if (target == nil || guard == nil) {
        @throw [NSException tb_ambiguousCompoundTransitionAttributes:self.name];
    }
    TBSMJunctionPath *outgoingPath = [TBSMJunctionPath new];
    outgoingPath.targetState = target;
    outgoingPath.action = action;
    outgoingPath.guard = guard;
    [self.outgoingPaths addObject:outgoingPath];
}

- (TBSMJunctionPath *)outgoingPathForTransition:(TBSMState *)source data:(id)data
{
    for (TBSMJunctionPath *outgoingPath in self.outgoingPaths) {
        if (outgoingPath.guard(data)) {
            return outgoingPath;
        }
    }
    @throw [NSException tb_noOutgoingJunctionPathException:self.name];
}

@end
