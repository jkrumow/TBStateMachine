//
//  TBSMJunction.h
//  TBStateMachine
//
//  Created by Julian Krumow on 23.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMPseudoState.h"

@interface TBSMJunction : TBSMPseudoState

+ (TBSMJunction *)junctionWithName:(NSString *)name;

- (NSArray *)targetStates;

- (void)addOutgoingPathWithTarget:(TBSMState *)target action:(TBSMActionBlock)action guard:(TBSMGuardBlock)guard;
- (TBSMState *)targetStateForTransition:(TBSMState *)source data:(NSDictionary *)data;
@end
