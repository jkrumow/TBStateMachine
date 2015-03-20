//
//  TBSMJoin.h
//  Pods
//
//  Created by Julian Krumow on 20.03.15.
//
//

#import <Foundation/Foundation.h>

/**
 *  This class represents a 'join' pseudo state in a state machine.
 */
@interface TBSMJoin : NSObject

@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Creates a `TBSMJoin` instance from a given name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The specified join name.
 *
 *  @return The join instance.
 */
+ (TBSMJoin *)joinWithName:(NSString *)name;

/**
 *  Initializes a `TBSMJoin` with a specified name.
 *
 *  Throws an exception when name is nil or an empty string.
 *
 *  @param name The name of the join. Must be unique.
 *
 *  @return An initialized `TBSMJoin` instance.
 */
- (instancetype)initWithName:(NSString *)name;
@end
