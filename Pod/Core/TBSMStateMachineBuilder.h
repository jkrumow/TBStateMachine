//
//  TBSMStateMachineBuilder.h
//  TBStateMachine
//
//  Created by Julian Krumow on 12.04.18.
//

#import <Foundation/Foundation.h>

@class TBSMStateMachine;
@interface TBSMStateMachineBuilder : NSObject

+ (TBSMStateMachine *)buildFromFile:(NSString *)file;

@end
