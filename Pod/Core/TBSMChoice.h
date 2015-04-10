//
//  TBSMChoice.h
//  TBStateMachine
//
//  Created by Julian Krumow on 23.03.15.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import "TBSMJunction.h"

@interface TBSMChoice : TBSMJunction

+ (TBSMChoice *)choiceWithName:(NSString *)name;

@end
