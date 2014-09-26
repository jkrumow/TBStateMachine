//
//  TBSMNode.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBSMState;
@class TBSMEvent;
@class TBSMTransition;

/**
 *  This protocol defines a node in a state machine.
 *
 *  Classes which implement this protocol can be managed by state machine.
 */
@protocol TBSMNode <NSObject>

/**
 *  Returns the node's name.
 *
 *  Classes which implement this method must return a unique name.
 *
 *  @return The name as a string.
 */
- (NSString *)name;

/**
 *  Returns the path of the node inside the state machine hierarchy.
 *
 *  @return An array containing all parent TBSMStateMachine instances - top state machine at index 0.
 */
- (NSMutableArray *)getPath;

/**
 *  Returns the parent state machine.
 *
 *  @return THe parent TBSMStateMachine instance.
 */
- (id<TBSMNode>)parentState;

/**
 *  Sets the parent state machine.
 *
 *  @param parentStateMachine The parent state machine.
 */
- (void)setParentState:(id<TBSMNode>)parentState;

/**
 *  Receives a specified `TBSMEvent` instance.
 *
 *  If the node recognizes the given `TBSMEvent` the corresponding `TBSMEventBlock` is executed.
 *
 *  @param event The given `TBSMEvent` instance.
 *
 *  @return The next state or `nil`.
 */
- (TBSMTransition *)handleEvent:(TBSMEvent *)event;

/**
 *  Receives a specified `TBSMEvent` instance and payload dictionary.
 *
 *  If the node recognizes the given `TBSMEvent` the corresponding `TBSMEventBlock` is executed
 *  and the paylod data is passed into the block.
 *
 *  @param event The given `TBSMEvent` instance.
 *  @param data  The payload data.
 *
 *  @return A `TBSMTransition` to the next state or `nil`.
 */
- (TBSMTransition *)handleEvent:(TBSMEvent *)event data:(NSDictionary *)data;

@end
