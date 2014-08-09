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
 *
 *  @return The next state switch to.
 */
typedef id<TBStateMachineNode> (^TBStateMachineEventBlock)(TBStateMachineEvent *);

/**
 *  This class represents an event in a state machine.
 */
@interface TBStateMachineEvent : NSObject

/**
 *  The event's name.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Optional user data that can be transmitted by the event.
 */
@property (nonatomic, strong, readonly) NSDictionary *data;

/**
 *  Creates a `TBStateMachineEvent` instance from a given name.
 *
 *  @param name The specified event name.
 *
 *  @return The event instance.
 */
+ (TBStateMachineEvent *)eventWithName:(NSString *)name;

/**
 *  Creates a `TBStateMachineEvent` instance from a given name and data.
 *
 *  @param name The specified event name.
 *  @param ∂ata The specified event data.
 *
 *  @return The event instance.
 */
+ (TBStateMachineEvent *)eventWithName:(NSString *)name data:(NSDictionary *)data;

/**
 *  Initializes a `TBStateMachineEvent` with a specified name.
 *
 *  @param name The name of this event. Must be unique.
 *  @param data The optional user data to transmit - will be available in the `TBStateMachineEventBlock`.
 *
 *  @return An initialized `TBStateMachineEvent` instance.
 */
- (instancetype)initWithName:(NSString *)name data:(NSDictionary *)data;

@end
