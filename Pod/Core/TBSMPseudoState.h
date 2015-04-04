//
//  TBSMPseudoState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSException+TBStateMachine.h"
#import "TBSMTransitionVertex.h"
#import "TBSMState.h"

/**
 *  This class represents the base class for pseudo states.
 *  This class shound not be used by itself.
 */
@interface TBSMPseudoState : NSObject  <TBSMTransitionVertex>

/**
 *  The name of the pseudo state.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Initializes a `TBSMPseudoState` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of the pseudo state. Must be unique.
 *
 *  @return An initialized `TBSMPseudoState` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  The state this pseudo state leads to inside a compound transition.
 *
 *  @return The target state instance.
 */
- (TBSMState *)targetState;

@end
