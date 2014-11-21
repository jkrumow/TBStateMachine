//
//  TBSMEvent.h
//  TBStateMachine
//
//  Created by Julian Krumow on 16.06.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  This class represents an event in a state machine.
 */
@interface TBSMEvent : NSObject

/**
 *  The event's name.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Creates a `TBSMEvent` instance from a given name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The specified event name.
 *
 *  @return The event instance.
 */
+ (TBSMEvent *)eventWithName:(NSString *)name;

/**
 *  Initializes a `TBSMEvent` with a specified name.
 *
 *  Throws a `TBSMException` when name is nil or an empty string.
 *
 *  @param name The name of this event. Must be unique.
 *
 *  @return An initialized `TBSMEvent` instance.
 */
- (instancetype)initWithName:(NSString *)name;

@end
