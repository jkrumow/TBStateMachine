//
//  TBSMPseudoState.h
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSMTransitionVertex.h"
#import "TBSMState.h"

@interface TBSMPseudoState : NSObject  <TBSMTransitionVertex>

@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;
- (TBSMState *)targetState;
@end
