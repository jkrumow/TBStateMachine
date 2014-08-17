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
 *  This class represents a transition in a state machine.
 */
@interface TBStateMachineTransition : NSObject

/**
 *  The source state.
 */
@property (nonatomic, weak) id<TBStateMachineNode> sourceState;

/**
 *  The destination state.
 */
@property (nonatomic, weak) id<TBStateMachineNode> destinationState;

/**
 *  Creates a `TBStateMachineTransition` instance from a given source and destination state.
 *
 *  @param sourceState The specified source state.
 *  @param destinationState  The specified destination state.
 *
 *  @return The transition object.
 */
+ (TBStateMachineTransition *)transitionWithSourceState:(id<TBStateMachineNode>)sourceState destinationState:(id<TBStateMachineNode>)destinationState;

/**
 *  The transition's name.
 *
 *  @return the name.
 */
- (NSString *)name;

@end
