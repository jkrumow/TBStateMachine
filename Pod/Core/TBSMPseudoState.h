//
//  TBSMPseudoState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSException+TBStateMachine.h"
#import "TBSMTransitionVertex.h"
#import "TBSMState.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents the base class for pseudo states.
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
- (nonnull TBSMState *)targetState;

@end
NS_ASSUME_NONNULL_END
