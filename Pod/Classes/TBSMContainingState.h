//
//  TBSMContainingState.h
//  Pods
//
//  Created by Julian Krumow on 23.03.15.
//
//

#import "TBSMState.h"

@interface TBSMContainingState : TBSMState

- (void)enter:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMContainingState *)region data:(NSDictionary *)data;
@end
