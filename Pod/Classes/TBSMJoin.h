//
//  TBSMJoin.h
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMPseudoState.h"


@class TBSMState;
@class TBSMParallelState;

/**
 *  This class represents a 'join' pseudo state in a state machine.
 */
@interface TBSMJoin : TBSMPseudoState

/**
 *  Creates a `TBSMJoin` instance from a given name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The specified join name.
 *
 *  @return The join instance.
 */
+ (TBSMJoin *)joinWithName:(NSString *)name;

- (void)addSourceStates:(NSArray *)sourceStates inRegion:(TBSMParallelState *)region target:(TBSMState *)target;
- (BOOL)joinSourceState:(TBSMState *)sourceState;
@end
