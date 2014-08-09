//
//  TBStateMachineTransition.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBStateMachineEvent.h"

@protocol TBStateMachineNode;

/**
 *  This type represents a block that is executed when travelling or cancelling a `TBStateMachineTransition`.
 *
 *  @param id<TBStateMachineNode> The previous state
 *  @param id<TBStateMachineNode> The next state
 */
typedef void (^TBStateMachineTransitionBlock)(id<TBStateMachineNode>, id<TBStateMachineNode>);

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

/**
 *  All `TBStateMachineEvent` instances added to this transition instance.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *eventHandlers;

/**
 *  Creates a `TBStateMachineTransition` instance from a given source and destination state.
 *
 *  @param sourceState The specified source state
 *  @param destinationState  The specified destination state
 *
 *  @return The transition object
 */
+ (TBStateMachineTransition *)transitionWithSourceState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState;

/**
 *  Adds two TBStateMachineState objects as source and destination states.
 *
 *  @param sourceState      The given source state.
 *  @param destinationState The given destination state.
 */
- (void)setSourceState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState;

- (NSString *)name;

@end
