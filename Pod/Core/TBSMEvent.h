//
//  TBSMEvent.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents an event in a state machine.
 */
@interface TBSMEvent : NSObject

/**
 *  The event's name.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  The event's payload.
 */
@property (nonatomic, strong, nullable) id data;

/**
 *  Creates a `TBSMEvent` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified event name.
 *  @param data Optional payload data.
 *
 *  @return The event instance.
 */
+ (TBSMEvent *)eventWithName:(NSString *)name data:(nullable id)data;

/**
 *  Initializes a `TBSMEvent` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of this event. Must be unique.
 *  @param data Optional payload data.
 *
 *  @return An initialized `TBSMEvent` instance.
 */
- (instancetype)initWithName:(NSString *)name data:(nullable id)data;

@end
NS_ASSUME_NONNULL_END
