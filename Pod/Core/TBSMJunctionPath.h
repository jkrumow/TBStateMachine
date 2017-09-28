//
//  TBSMJunctionPath.h
//  TBStateMachine
//
//  Created by Julian Krumow on 24.04.15.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransition.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a wrapper class for an outgoing path of a `TBSMJunction`.
 */
@interface TBSMJunctionPath : NSObject

/**
 *  The target state of this path.
 */
@property (nonatomic, strong) TBSMState *targetState;

/**
 *  The action block associated with this path.
 */
@property (nonatomic, copy, nullable) TBSMActionBlock action;

/**
 *  The guard block associated with this path.
 */
@property (nonatomic, copy, nullable) TBSMGuardBlock guard;

@end
NS_ASSUME_NONNULL_END
