//
//  TBSMTransitionVertex.h
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This protocol represents a vertex inside a compound transition.
 *
 *  Classes which implement this protocol can be used to construct compound transitions.
 */
@protocol TBSMTransitionVertex <NSObject>

/**
 *  Returns the vertex' name.
 *
 *  Classes which implement this method must return a unique name.
 *
 *  @return The name as a string.
 */
- (NSString *)name;

@end
NS_ASSUME_NONNULL_END
