//
//  TBSMStateMachine+DebugSupport.m
//  TBStateMachine
//
//  Created by Julian Krumow on 19.02.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBSMStateMachine+DebugSupport.h"
#import "TBSMDebugSwizzler.h"
#import "TBSMDebugLogger.h"

NSString * const TBSMDebugSupportException = @"TBSMDebugSupportException";

@implementation TBSMStateMachine (DebugSupport)
@dynamic debugSupportEnabled;
@dynamic millisecondsPerMachTime;
@dynamic eventDebugQueue;

- (NSNumber *)debugSupportEnabled
{
    return objc_getAssociatedObject(self, @selector(debugSupportEnabled));
}

- (void)setDebugSupportEnabled:(NSNumber *)debugSupportEnabled
{
    objc_setAssociatedObject(self, @selector(debugSupportEnabled), debugSupportEnabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)millisecondsPerMachTime
{
    return objc_getAssociatedObject(self, @selector(millisecondsPerMachTime));
}

- (void)setMillisecondsPerMachTime:(NSNumber *)millisecondsPerMachTime
{
    objc_setAssociatedObject(self, @selector(millisecondsPerMachTime), millisecondsPerMachTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)eventDebugQueue
{
    NSMutableArray *queue = objc_getAssociatedObject(self, @selector(eventDebugQueue));
    if (queue == nil) {
        queue = [NSMutableArray new];
        self.eventDebugQueue = queue;
    }
    return queue;
}

- (void)setEventDebugQueue:(NSMutableArray *)eventDebugQueue
{
    objc_setAssociatedObject(self, @selector(eventDebugQueue), eventDebugQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)activateDebugSupport
{
    if (self.parentNode) {
        @throw [NSException exceptionWithName:TBSMDebugSupportException reason:@"Debug support not available on sub-statemachines." userInfo:nil];
    }
    self.debugSupportEnabled = @YES;
    
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    self.millisecondsPerMachTime = @(timebase.numer / timebase.denom / 1e6);
    
    [TBSMState activateDebugSupport];
    [TBSMCompoundTransition activateDebugSupport];
    [TBSMTransition activateDebugSupport];
    
    object_setClass(self, TBSMDebugStateMachine.class);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // We use a dedicated subclass to swizzle certain methods only on the top state machine.
        [TBSMDebugSwizzler swizzleMethod:@selector(handleEvent:) withMethod:@selector(tb_handleEvent:) onClass:[TBSMDebugStateMachine class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(setUp:) withMethod:@selector(tb_setUp:) onClass:[TBSMStateMachine class]];
        [TBSMDebugSwizzler swizzleMethod:@selector(tearDown:) withMethod:@selector(tb_tearDown:) onClass:[TBSMStateMachine class]];
    });
}

- (NSString *)activeStateConfiguration
{
    NSMutableString *string = [NSMutableString new];
    [self activeStatemachineConfiguration:self string:string];
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

- (void)scheduleEvent:(TBSMEvent *)event withCompletion:(TBSMDebugCompletionBlock)completion
{
    if (!self.debugSupportEnabled.boolValue) {
        @throw [NSException exceptionWithName:TBSMDebugSupportException reason:@"Method only available with activated debug support." userInfo:nil];
    }
    event.completionBlock = completion;
    [self.eventDebugQueue addObject:event];
    [self scheduleEvent:event];
}

- (BOOL)tb_handleEvent:(TBSMEvent *)event
{
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: will handle event '%@' data: %@", self.name, event.name, event.data];
    
    uint64_t startTime = mach_absolute_time();
    BOOL hasHandledEvent = [self tb_handleEvent:event];
    
    uint64_t endTime = mach_absolute_time() - startTime;
    NSTimeInterval timeInterval = endTime * self.millisecondsPerMachTime.doubleValue;
    
    [self.eventDebugQueue removeObject:event];
    
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: run-to-completion step took %f milliseconds", self.name, timeInterval];
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: remaining events in queue: %lu\n\n", self.name, (unsigned long)self.scheduledEventsQueue.operationCount - 1];
    [[TBSMDebugLogger sharedInstance] log:@"[%@]: %@", self.name, [self.eventDebugQueue valueForKeyPath:@"name"]];
    
    TBSMDebugCompletionBlock completionBlock = event.completionBlock;
    if (completionBlock) {
        completionBlock();
    }
    return hasHandledEvent;
}

- (void)tb_setUp:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"[%@] setup data: %@", self.name, data];
    [self tb_setUp:data];
}

- (void)tb_tearDown:(id)data
{
    [[TBSMDebugLogger sharedInstance] log:@"[%@] teardown data: %@", self.name, data];
    [self tb_tearDown:data];
}

@end
