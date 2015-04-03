//
//  ParallelA.h
//  TBStateMachine
//
//  Created by Julian Krumow on 22.01.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import "TBSMParallelState.h"

@interface ParallelA : TBSMParallelState

@property (nonatomic, strong) NSMutableArray *executionSequence;
@end
