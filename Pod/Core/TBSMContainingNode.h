//
//  TBSMContainingNode.h
//  TBStateMachine
//
//  Created by Julian Krumow on 23.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMNode.h"

@class TBSMParallelState;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This protocol describes a subtype of `TBSMNode` in the state machine hierarchy which can contain other `TBSMNode`s.
 */
@protocol TBSMContainingNode <TBSMNode>

/**
 *  Enters a group of specified states inside a region.
 *
 *  @param sourceState The source state.
 *  @param targetStates The target states inside the specified region.
 *  @param region      The target region.
 *  @param data        The payload data.
 */
- (void)enter:(nullable TBSMState *)sourceState targetStates:(NSArray<__kindof TBSMState *> *)targetStates region:(TBSMParallelState *)region data:(nullable id)data;

/**
 *  Receives a specified `TBSMEvent` instance.
 *
 *  @param event The given `TBSMEvent` instance.
 *
 *  @return `YES` if the event has been handled.
 */
- (BOOL)handleEvent:(TBSMEvent *)event;

@end
NS_ASSUME_NONNULL_END
