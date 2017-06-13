//
//  TBSMDebugger.m
//  Pods
//
//  Created by Julian Krumow on 14.05.17.
//
//

#import "TBSMDebugger.h"

NSString * const TBSMDebugSupportException = @"TBSMDebugSupportException";

@implementation TBSMDebugger

+ (instancetype)sharedInstance
{
    static TBSMDebugger *_debugger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _debugger = [TBSMDebugger new];
    });
    return _debugger;
}

- (void)debugStateMachine:(TBSMStateMachine *)stateMachine
{
    if (stateMachine.parentNode) {
        @throw [NSException exceptionWithName:TBSMDebugSupportException reason:@"Debug support not available on sub-statemachines." userInfo:nil];
    }
    _stateMachine = stateMachine;
    
    object_setClass(self.stateMachine, TBSMDebugStateMachine.class);
    
    [TBSMState activateDebugSupport];
    [TBSMTransition activateDebugSupport];
    [TBSMStateMachine activateDebugSupport];
}

- (NSString *)activeStateConfiguration
{
    NSMutableString *string = [NSMutableString new];
    [self activeStatemachineConfiguration:self.stateMachine string:string];
    return string;
}

- (void)activeStatemachineConfiguration:(TBSMStateMachine *)stateMachine string:(NSMutableString *)string
{
    TBSMState *state = stateMachine.currentState;
    [string appendFormat:@"%@%@\n", [self indentationForLevel:state.path.count-1], stateMachine.name];
    [string appendFormat:@"%@%@\n", [self indentationForLevel:state.path.count], state.name];
    
    if ([state isKindOfClass:[TBSMSubState class]]) {
        TBSMSubState *subState = (TBSMSubState *)state;
        [self activeStatemachineConfiguration:subState.stateMachine string:string];
    } else if ([state isKindOfClass:[TBSMParallelState class]]) {
        TBSMParallelState *parallelState = (TBSMParallelState *)state;
        for (TBSMStateMachine *subMachine in parallelState.stateMachines) {
            [self activeStatemachineConfiguration:subMachine string:string];
        }
    }
}

- (NSString *)indentationForLevel:(NSUInteger)level
{
    NSMutableString *indentation = [NSMutableString new];
    for (NSUInteger i=0; i < level-1; i++) {
        [indentation appendString:@"\t"];
    }
    return indentation;
}

@end
