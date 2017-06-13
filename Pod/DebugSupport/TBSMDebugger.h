//
//  TBSMDebugger.h
//  Pods
//
//  Created by Julian Krumow on 14.05.17.
//
//

#import "TBSMEvent+DebugSupport.h"
#import "TBSMState+DebugSupport.h"
#import "TBSMStateMachine+DebugSupport.h"
#import "TBSMTransition+DebugSupport.h"
#import "TBSMDebugStateMachine.h"
#import "TBSMDebugSwizzler.h"
#import "TBSMDebugLogger.h"


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const TBSMDebugSupportException;

@interface TBSMDebugger : NSObject
@property (nonatomic, strong) TBSMStateMachine *stateMachine;

+ (instancetype)sharedInstance;

- (void)debugStateMachine:(TBSMStateMachine *)stateMachine;
- (NSString *)activeStateConfiguration;
- (void)activeStatemachineConfiguration:(TBSMStateMachine *)stateMachine string:(NSMutableString *)string;
@end
NS_ASSUME_NONNULL_END
