//
//  StateA.h
//  TBStateMachine
//
//  Created by Julian Krumow on 22.01.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBSMState.h"

@interface StateA : TBSMState

@property (nonatomic, strong) NSMutableArray *executionSequence;
@end
