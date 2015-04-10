//
//  TBSMJunction.m
//  TBStateMachine
//
//  Created by Julian Krumow on 23.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMJunction.h"

@interface TBSMJunctionPath : NSObject
@property (nonatomic, strong) TBSMState *targetState;
@property (nonatomic, copy) TBSMActionBlock action;
@property (nonatomic, copy) TBSMGuardBlock guard;
@end
@implementation TBSMJunctionPath
@end

@interface TBSMJunction ()
@property (nonatomic, strong) NSMutableArray *outgoingPaths;
@end

@implementation TBSMJunction

+ (TBSMJunction *)junctionWithName:(NSString *)name
{
    return [[TBSMJunction alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _outgoingPaths = [NSMutableArray new];
    }
    return self;
}

- (void)addOutgoingPathWithTarget:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    TBSMJunctionPath *outgoingPath = [TBSMJunctionPath new];
    outgoingPath.targetState = target;
    outgoingPath.action = action;
    outgoingPath.guard = guard;
    [self.outgoingPaths addObject:outgoingPath];
}

- (id<TBSMTransitionVertex>)targetVertex
{
    return nil;
}

- (TBSMState *)targetVertexForTransition:(TBSMState *)source data:(NSDictionary *)data
{
    for (TBSMJunctionPath *outgoingPath in self.outgoingPaths) {
        if (outgoingPath.guard(source, nil, data)) {
            return outgoingPath.targetState;
        }
    }
    return nil;
}

@end
