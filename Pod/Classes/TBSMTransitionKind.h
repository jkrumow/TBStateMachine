//
//  TBSMTransitionKind.h
//  TBStateMachine
//
//  Created by Julian Krumow on 03.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#ifndef Pods_TBSMTransitionKind_h
#define Pods_TBSMTransitionKind_h

/**
 *  This enum defines the transition types that can be defined.
 */
typedef NS_ENUM(NSUInteger, TBSMTransitionKind) {
    TBSMTransitionExternal,
    TBSMTransitionLocal,
    TBSMTransitionInternal
};

#endif
