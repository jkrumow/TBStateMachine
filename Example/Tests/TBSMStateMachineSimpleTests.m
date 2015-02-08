//
//  TBSMStateMachineSimpleTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMStateMachineSimple)

NSString * const EVENT_A = @"DummyEventA";
NSString * const EVENT_B = @"DummyEventB";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;
__block TBSMState *stateA;
__block TBSMState *stateB;
__block TBSMState *stateC;
__block NSDictionary *eventDataA;

describe(@"TBSMStateMachine", ^{
    
    beforeEach(^{
        stateMachine = [TBSMStateMachine stateMachineWithName:@"StateMachine"];
        stateA = [TBSMState stateWithName:@"a"];
        stateB = [TBSMState stateWithName:@"b"];
        stateC = [TBSMState stateWithName:@"c"];
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
    });
    
    afterEach(^{
        [stateMachine tearDown:nil];
        stateMachine = nil;
        stateA = nil;
        stateB = nil;
        stateC = nil;
        eventDataA = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                stateMachine = [TBSMStateMachine stateMachineWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                stateMachine = [TBSMStateMachine stateMachineWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws TBSMException when state object is not of type TBSMState.", ^{
            id object = [NSObject new];
            expect(^{
                stateMachine.states = @[stateA, stateB, object];
            }).to.raise(TBSMException);
        });
        
        it(@"throws TBSMException when initial state does not exist in set of defined states.", ^{
            stateMachine.states = @[stateA, stateB];
            expect(^{
                stateMachine.initialState = stateC;
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws an TBSMException when initial state has not been set on setup.", ^{
            expect(^{
                [stateMachine setUp:nil];
            }).to.raise(TBSMException);
        });
        
    });
    
    describe(@"Location inside hierarchy.", ^{
        
        it(@"returns its path inside the state machine hierarchy containing all parent nodes in descending order", ^{
            
            TBSMStateMachine *subStateMachineA = [TBSMStateMachine stateMachineWithName:@"SubA"];
            TBSMStateMachine *subStateMachineB = [TBSMStateMachine stateMachineWithName:@"SubB"];
            TBSMParallelState *parallelStates = [TBSMParallelState parallelStateWithName:@"ParallelWrapper"];
            subStateMachineB.states = @[stateA];
            TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"subStateB"];
            subStateB.stateMachine = subStateMachineB;
            subStateMachineA.states = @[subStateB];
            
            parallelStates.stateMachines = @[subStateMachineA];
            stateMachine.states = @[parallelStates];
            
            NSArray *path = [subStateMachineB path];
            
            expect(path.count).to.equal(3);
            expect(path[0]).to.equal(stateMachine);
            expect(path[1]).to.equal(subStateMachineA);
            expect(path[2]).to.equal(subStateMachineB);
        });
        
        it(@"returns its name.", ^{
            TBSMStateMachine *stateMachineXYZ = [TBSMStateMachine stateMachineWithName:@"StateMachineXYZ"];
            expect(stateMachineXYZ.name).to.equal(@"StateMachineXYZ");
        });
        
    });
    
    describe(@"State switching.", ^{
        
        it(@"enters initial state on set up.", ^{
            
            stateMachine.states = @[stateA, stateB];
            
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateMachine.initialState);
            expect(stateMachine.currentState).to.equal(stateA);
        });
        
        it(@"exits current state on tear down.", ^{
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            [stateMachine tearDown:nil];
            
            expect(stateMachine.currentState).to.beNil;
        });
        
        it(@"switches to the specified state.", ^{
            
            [stateA addHandlerForEvent:EVENT_A target:stateB kind:TBSMTransitionExternal];
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            // enters state B
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(stateMachine.currentState).to.equal(stateB);
        });
        
        it(@"evaluates a guard function, exits the current state, executes transition action and enters the next state.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            [stateA addHandlerForEvent:EVENT_A
                           target:stateB
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-actionA"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                [executionSequence appendString:@"-guardA"];
                                return YES;
                            }];
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            // will enter state B
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(executionSequence).to.equal(@"enterA-guardA-exitA-actionA-enterB");
        });
        
        it(@"evaluates a guard function, and skips switching to the next state.", ^{
            
            __block BOOL didExecuteAction = NO;
            
            [stateA addHandlerForEvent:EVENT_A
                           target:stateB
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteAction = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return NO;
                            }];
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            // will not enter state B
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(didExecuteAction).to.equal(NO);
            expect(stateMachine.currentState).to.equal(stateA);
        });
        
        it(@"evaluates multiple guard functions, and switches to the next state.", ^{
            
            __block BOOL didExecuteActionA = NO;
            __block BOOL didExecuteActionB = NO;
            
            [stateA addHandlerForEvent:EVENT_A
                           target:stateB
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteActionA = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return NO;
                            }];
            
            [stateA addHandlerForEvent:EVENT_A
                           target:stateB
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteActionB = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return YES;
                            }];
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            // will enter state B through second transition
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(didExecuteActionA).to.equal(NO);
            expect(didExecuteActionB).to.equal(YES);
            expect(stateMachine.currentState).to.equal(stateB);
        });
        
        it(@"passes source and destination state and event data into the enter, exit, action and guard blocks of the involved states.", ^{
            
            __block TBSMState *sourceStateEnter;
            __block TBSMState *targetStateEnter;
            __block NSDictionary *stateDataEnter;
            __block TBSMState *sourceStateExit;
            __block TBSMState *targetStateExit;
            __block NSDictionary *stateDataExit;
            
            __block TBSMState *sourceStateGuard;
            __block TBSMState *targetStateGuard;
            __block TBSMState *sourceStateAction;
            __block TBSMState *targetStateAction;
            __block NSDictionary *actionData;
            __block NSDictionary *guardData;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateExit = sourceState;
                targetStateExit = targetState;
                stateDataExit = data;
            };
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateExit = sourceState;
                targetStateExit = targetState;
                stateDataExit = data;
            };
            
            [stateA addHandlerForEvent:EVENT_A
                           target:stateB
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               sourceStateAction = sourceState;
                               targetStateAction = targetState;
                               actionData = data;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                sourceStateGuard = sourceState;
                                targetStateGuard = targetState;
                                guardData = data;
                                return YES;
                            }];
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            expect(sourceStateEnter).to.beNil;
            expect(targetStateEnter).to.equal(stateA);
            expect(stateDataEnter).to.beNil;
            
            // enters state B
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:eventDataA]];
            
            expect(sourceStateExit).to.equal(stateA);
            expect(targetStateExit).to.equal(stateB);
            
            expect(stateDataExit).to.equal(eventDataA);
            expect(stateDataExit.allKeys).haveCountOf(1);
            expect(stateDataExit[EVENT_DATA_KEY]).toNot.beNil;
            expect(stateDataExit[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(guardData).to.equal(eventDataA);
            expect(guardData.allKeys).haveCountOf(1);
            expect(guardData[EVENT_DATA_KEY]).toNot.beNil;
            expect(guardData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(actionData).to.equal(eventDataA);
            expect(actionData.allKeys).haveCountOf(1);
            expect(actionData[EVENT_DATA_KEY]).toNot.beNil;
            expect(actionData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(sourceStateEnter).to.equal(stateA);
            expect(targetStateEnter).to.equal(stateB);
            
            expect(stateDataEnter).to.equal(eventDataA);
            expect(stateDataEnter.allKeys).haveCountOf(1);
            expect(stateDataEnter[EVENT_DATA_KEY]).toNot.beNil;
            expect(stateDataEnter[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"can re-enter a state.", ^{
            
            __block BOOL didEnterStateA = NO;
            __block BOOL didExitStateA = NO;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                didEnterStateA = YES;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                didExitStateA = YES;
            };
            
            [stateA addHandlerForEvent:EVENT_A target:stateA kind:TBSMTransitionExternal];
            
            stateMachine.states = @[stateA, stateB];
            
            [stateMachine setUp:nil];
            
            didEnterStateA = NO;
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(stateMachine.currentState).to.equal(stateA);
            expect(didExitStateA).to.equal(YES);
            expect(didEnterStateA).to.equal(YES);
        });
        
        it(@"performs an internal transition if target state is nil and guard evaluates to YES.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            [stateA addHandlerForEvent:EVENT_A
                           target:nil
                             kind:TBSMTransitionInternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-action"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                [executionSequence appendString:@"-guard"];
                                return YES;
                            }];
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            // will perform two internal transitions
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(executionSequence).to.equal(@"-enterA-guard-action-guard-action");
        });
        
        it(@"performs an internal transition if target state is nil and guard is nil.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            [stateA addHandlerForEvent:EVENT_A
                           target:nil
                             kind:TBSMTransitionInternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-action"];
                           }];
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            // will perform two internal transitions
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(executionSequence).to.equal(@"enterA-action-action");
        });
        
        it(@"performs no internal transition if target state is nil and guard evaluates to NO.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            [stateA addHandlerForEvent:EVENT_A
                           target:nil
                             kind:TBSMTransitionInternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-action"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                [executionSequence appendString:@"-guard"];
                                return NO;
                            }];
            
            stateMachine.states = @[stateA, stateB];
            [stateMachine setUp:nil];
            
            // will perform no internal transitions
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(executionSequence).to.equal(@"enterA-guard-guard");
        });
        
        it(@"defers events until a state has been reached which can consume the event.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterC"];
            };
            
            stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitC"];
            };
            
            [stateA addHandlerForEvent:EVENT_A target:stateB kind:TBSMTransitionExternal];
            [stateA deferEvent:EVENT_B];
            [stateB addHandlerForEvent:EVENT_B target:stateC kind:TBSMTransitionExternal];
            
            stateMachine.states = @[stateA, stateB, stateC];
            [stateMachine setUp:nil];
            
            // event should be deferred
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_B data:nil]];
            
            // should switch to state B --> handle eventB --> switch to stateC
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil]];
            
            expect(stateMachine.currentState).to.equal(stateC);
            expect(executionSequence).to.equal(@"enterA-exitA-enterB-exitB-enterC");
        });
    });
});

SpecEnd
