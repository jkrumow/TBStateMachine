//
//  TBStateMachineEvent.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBStateMachineEvent;
@protocol TBStateMachineNode;

/**
 *  This type represents a block that is executed when a given `TBStateMachineEvent` can be successfully handled by a `TBStateMachineNode` instance.
 *
 *  @param id<TBStateMachineNode> The corresponding `TBStateMachineEvent` that is handled.
 *  @param NSDictionary The payload data.
 *
 *  @return The next state switch to.
 */
typedef id<TBStateMachineNode> (^TBStateMachineEventBlock)(TBStateMachineEvent *, NSDictionary *);

/**
 *  This class represents an event in a state machine.
 */
@interface TBStateMachineEvent : NSObject

/**
 *  The event's name.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Creates a `TBStateMachineEvent` instance from a given name.
 *
 *  @param name The specified event name.
 *
 *  @return The event instance.
 */
+ (TBStateMachineEvent *)eventWithName:(NSString *)name;

/**
 *  Initializes a `TBStateMachineEvent` with a specified name.
 *
 *  @param name The name of this event. Must be unique.
 *
 *  @return An initialized `TBStateMachineEvent` instance.
 */
- (instancetype)initWithName:(NSString *)name;

@end
