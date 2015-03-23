//
//  TBSMContainingState.h
//  Pods
//
//  Created by Julian Krumow on 23.03.15.
//
//

#import "TBSMState.h"

/**
 *  This class represents the base class for containing states.
 *  This class shound not be used by itself.
 */
@interface TBSMContainingState : TBSMState

/**
 *  Enters a group of specified states inside a region.
 *
 *  @param sourceState The source state.
 *  @param targetState The target states inside the specified region.
 *  @param region      The target region.
 *  @param data        The payload data.
 */
- (void)enter:(TBSMState *)sourceState targetStates:(NSArray *)targetStates region:(TBSMContainingState *)region data:(NSDictionary *)data;
@end
