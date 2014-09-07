//
//  TBStateMachineTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBStateMachineTransition.h"

@protocol TBStateMachineNode;


/**
 *  This type represents a block that is executed when a given `TBStateMachineEvent` can be successfully handled by a `TBStateMachineNode` instance.
 *
 *  @param event The corresponding `TBStateMachineEvent` that is handled.
 *  @param data The payload data.
 *
 *  @return The next state switch to.
 */
typedef void(^TBStateMachineActionBlock)(id<TBStateMachineNode> nextState, NSDictionary *data);

typedef BOOL(^TBStateMachineGuardBlock)(id<TBStateMachineNode> nextState, NSDictionary *data);


/**
 *  This class represents a transition in a state machine.
 */
@interface TBStateMachineTransition : NSObject

/**
 *  The source state.
 */
@property (nonatomic, weak, readonly) id<TBStateMachineNode> sourceState;

/**
 *  The destination state.
 */
@property (nonatomic, weak, readonly) id<TBStateMachineNode> destinationState;

@property (nonatomic, strong, readonly) TBStateMachineActionBlock action;

@property (nonatomic, strong, readonly) TBStateMachineGuardBlock guard;

/**
 *  Creates a `TBStateMachineTransition` instance from a given source and destination state.
 *
 *  @param sourceState The specified source state.
 *  @param destinationState  The specified destination state.
 *
 *  @return The transition object.
 */
+ (TBStateMachineTransition *)transitionWithSourceState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState action:(TBStateMachineActionBlock)action guard:(TBStateMachineGuardBlock)guard;

/**
 *  The transition's name.
 *
 *  @return the name.
 */
- (NSString *)name;

@end
