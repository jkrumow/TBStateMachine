//
//  TBStateMachineParallelWrapper.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBStateMachineNode.h"

/**
 *  This class wraps multiple `TBStateMachineNode` instances and processes them in parallel.
 */
@interface TBStateMachineParallelWrapper : NSObject <TBStateMachineNode>

/**
 *  Initializes a `TBStateMachineParallelWrapper` with a specified name.
 *
 *  @param name The name of this wrapper. Must be unique.
 *
 *  @return An initialized `TBStateMachineParallelWrapper` instance.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Sets the `TBStateMachineNode` instances to wrap.
 *
 *  Throws `TBStateMachineException` if the instances are not of type `TBStateMachineNode`.
 *
 *  @param states An array of `TBStateMachineNode` instances.
 */
- (void)setStates:(NSArray *)states;

@end
