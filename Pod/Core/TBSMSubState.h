//
//  TBSMSubState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.09.14.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMState.h"
#import "TBSMContainingVertex.h"

NS_ASSUME_NONNULL_BEGIN

@class TBSMStateMachine;

/**
 *  This class allows the create nested states.
 */
@interface TBSMSubState : TBSMState <TBSMContainingVertex>

/**
 *  The `TBSMStateMachine` instance contained in this sub state.
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
+ (instancetype)subStateWithName:(NSString *)name;

/**
 *  Sets all states the sub state will manage. First state in array wil be set as initialState.
 *  Creates a state machine implicitly.
 *
 *  Throws `TBSMException` if states are not of type `TBSMState`.
 *
 *  @param states An `NSArray` containing all state objects.
 */
- (void)setStates:(NSArray<__kindof TBSMState *> *)states;

@end
NS_ASSUME_NONNULL_END
