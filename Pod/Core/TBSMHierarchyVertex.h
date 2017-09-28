//
//  TBSMHierarchyVertex.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransition.h"
#import "TBSMEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This protocol defines a vertex in a state model hierarchy.
 *
 *  Classes which implement this protocol can be managed inside a state model heriarchy.
 */
@protocol TBSMHierarchyVertex <NSObject>

/**
 *  Returns the vertex's name.
 *
 *  Classes which implement this method must return a unique name.
 *
 *  @return The name as a string.
 */
- (NSString *)name;

/**
 *  Returns its path inside the state machine hierarchy containing all parent vertexes in descending order.
 *
 *  @return An array containing all parent vertexes.
 */
- (NSMutableArray<NSObject<TBSMHierarchyVertex> *> *)path;

/**
 *  Returns the parent vertex in the state machine hierarchy.
 *
 *  @return The parent `TBSMHierarchyVertex`.
 */
- (nullable id<TBSMHierarchyVertex>)parentVertex;

/**
 *  Sets the parent vertex in the state machine hierarchy.
 *
 *  @param parentVertex The parent vertex.
 */
- (void)setParentVertex:(nullable id<TBSMHierarchyVertex>)parentVertex;

/**
 *  Executes the enter block of the state.
 *
 *  If you overwrite this method you will need to call the super implementation.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
- (void)enter:(nullable TBSMState *)sourceState targetState:(nullable TBSMState *)targetState data:(nullable id)data;

/**
 *  Executes the exit block of the state.
 *
 *  If you overwrite this method you will need to call the super implementation.
 *
 *  @param sourceState The source state.
 *  @param targetState The target state.
 *  @param data        The payload data.
 */
- (void)exit:(nullable TBSMState *)sourceState targetState:(nullable TBSMState *)targetState data:(nullable id)data;

@end
NS_ASSUME_NONNULL_END
