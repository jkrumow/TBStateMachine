//
//  TBSMSubState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMState.h"

@class TBSMStateMachine;

/**
 *  This class wraps a given `TBSMStateMachine` instance in a state.
 */
@interface TBSMSubState : TBSMState

/**
 *  The `TBSMStateMachine` instance wrapped by this sub state.
 */
@property (nonatomic, strong) TBSMStateMachine *stateMachine;

/**
 *  Creates a `TBSMSUBState` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return A new `TBSMSubState` instance.
 */
+ (TBSMSubState *)subStateWithName:(NSString *)name;

/**
 *  Receives a specified `TBSMEvent` instance.
 *
 *  If the node recognizes the given `TBSMEvent` it will return `YES`.
 *
 *  @param event The given `TBSMEvent` instance.
 *
 *  @return `YES` if teh transition has been handled.
 */
- (BOOL)handleEvent:(TBSMEvent *)event;

@end
