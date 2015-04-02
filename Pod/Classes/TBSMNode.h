//
//  TBSMNode.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransition.h"
#import "TBSMEvent.h"

/**
 *  This protocol defines a node in a state machine hierarchy.
 *
 *  Classes which implement this protocol can be managed inside a state machine heriarchy.
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
 *  Returns its path inside the state machine hierarchy containing all parent nodes in descending order.
 *
 *  @return An array containing all parent nodes.
 */
- (NSMutableArray *)path;

/**
 *  Returns the parent node in the state machine hierarchy.
 *
 *  @return The parent `TBSMNode`.
 */
- (id<TBSMNode>)parentNode;

/**
 *  Sets the parent node in the state machine hierarchy.
 *
 *  @param parentNode The parent node.
 */
- (void)setParentNode:(id<TBSMNode>)parentNode;

/**
 *  Executes the enter block of the state.
 *
 *  If you overwrite this method you will need to call the super implementation.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
- (void)enter:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data;

/**
 *  Executes the exit block of the state.
 *
 *  If you overwrite this method you will need to call the super implementation.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
- (void)exit:(TBSMState *)sourceState targetState:(TBSMState *)targetState data:(NSDictionary *)data;

@end
