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

- (NSArray *)targetStates
{
    return [self.outgoingPaths valueForKeyPath:@"targetState"];
}

- (void)addOutgoingPathWithTarget:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard
{
    TBSMJunctionPath *outgoingPath = [TBSMJunctionPath new];
    outgoingPath.targetState = target; // TODO: throw exception when nil
    outgoingPath.action = action;
    outgoingPath.guard = guard; // TODO: throw exception when nil
    [self.outgoingPaths addObject:outgoingPath];
}

- (TBSMState *)targetStateForTransition:(TBSMState *)source data:(NSDictionary *)data
{
    for (TBSMJunctionPath *outgoingPath in self.outgoingPaths) {
        if (outgoingPath.guard(source, outgoingPath.targetState, data)) {
            return outgoingPath.targetState;
        }
    }
    return nil; // TODO: throw exception when nil
}

@end
