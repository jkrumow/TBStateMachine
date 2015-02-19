//
//  TBSMStateMachine+TestHelper.h
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine.h"

@interface TBSMStateMachine (TestHelper)

- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(void (^)(void))completion;
@end
