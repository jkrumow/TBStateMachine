//
//  TBSMJunctionPath.h
//  TBStateMachine
//
//  Created by Julian Krumow on 24.04.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransition.h"

/**
 *  This class represents a wrapper class for an outgoing path of a `TBSMJunction`.
 */
@interface TBSMJunctionPath : NSObject

@property (nonatomic, strong) TBSMState *targetState;
@property (nonatomic, copy) TBSMActionBlock action;
@property (nonatomic, copy) TBSMGuardBlock guard;
@end
