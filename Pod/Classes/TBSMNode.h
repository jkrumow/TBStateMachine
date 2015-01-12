//
//  TBSMNode.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
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
 *  Returns the path of the node inside the state machine hierarchy.
 *
 *  @return An array containing all parent nodes.
 */
- (NSMutableArray *)path;

/**
 *  Returns the parent state machine.
 *
 *  @return The parent `TBSMNode`.
 */
- (id<TBSMNode>)parentState;

/**
 *  Sets the parent state machine.
 *
 *  @param parentState The parent state.
 */
- (void)setParentState:(id<TBSMNode>)parentState;

@end
