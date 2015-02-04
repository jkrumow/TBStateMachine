//
//  TBSMStateMachineSimpleTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMStateMachineSimple)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_NAME_B = @"DummyEventB";
NSString * const EVENT_NAME_C = @"DummyEventC";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;
__block TBSMState *stateA;
__block TBSMState *stateB;
__block TBSMState *stateC;
__block TBSMState *stateD;
__block TBSMState *stateE;

__block TBSMEvent *eventA;
__block TBSMEvent *eventB;
__block TBSMEvent *eventC;
__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMParallelState *parallelStates;
__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;


describe(@"TBSMStateMachine", ^{
    
    beforeEach(^{
        stateMachine = [TBSMStateMachine stateMachineWithName:@"StateMachine"];
        stateA = [TBSMState stateWithName:@"a"];
        stateB = [TBSMState stateWithName:@"b"];
        stateC = [TBSMState stateWithName:@"c"];
        stateD = [TBSMState stateWithName:@"d"];
        stateE = [TBSMState stateWithName:@"e"];
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBSMEvent eventWithName:EVENT_NAME_A data:nil];
        eventB = [TBSMEvent eventWithName:EVENT_NAME_B data:nil];
        eventC = [TBSMEvent eventWithName:EVENT_NAME_C data:nil];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"SubA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"SubB"];
        parallelStates = [TBSMParallelState parallelStateWithName:@"ParallelWrapper"];
    });
    
    afterEach(^{
        [stateMachine tearDown:nil];
        
        stateMachine = nil;
        
        stateA = nil;
        stateB = nil;
        stateC = nil;
        stateD = nil;
        stateE = nil;
        
        eventDataA = nil;
        eventDataB = nil;
        eventA = nil;
        eventB = nil;
        eventC = nil;
        
        [subStateMachineA tearDown:nil];
        [subStateMachineB tearDown:nil];
        subStateMachineA = nil;
        subStateMachineB = nil;
        parallelStates = nil;
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
            id object = [[NSObject alloc] init];
            NSArray *states = @[stateA, stateB, object];
            expect(^{
                stateMachine.states = states;
            }).to.raise(TBSMException);
        });
        
        it(@"throws TBSMException when initial state does not exist in set of defined states.", ^{
            NSArray *states = @[stateA, stateB];
            stateMachine.states = states;
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
            
            subStateMachineB.states = @[stateA];
            TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"subStateB" stateMachine:subStateMachineB];
            subStateMachineA.states = @[subStateB];
            
            parallelStates.stateMachines = @[subStateMachineA];
            stateMachine.states = @[parallelStates];
            stateMachine.initialState = parallelStates;
            
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
            
            NSArray *states = @[stateA, stateB];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateA);
        });
        
        it(@"exits current state on tear down.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            [stateMachine tearDown:nil];
            
            expect(stateMachine.currentState).to.beNil;
        });
        
        it(@"switches to the specified state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            [stateA registerEvent:eventA.name target:stateB type:TBSMTransitionExternal];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            // enters state B
            [stateMachine scheduleEvent:eventA];
            
            expect(stateMachine.currentState).to.equal(stateB);
        });
        
        it(@"evaluates a guard function, exits the current state, executes transition action and enters the next state.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            [stateA registerEvent:eventA.name
                           target:stateB
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-actionA"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                [executionSequence appendString:@"-guardA"];
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // will enter state B
            [stateMachine scheduleEvent:eventA];
            
            expect(executionSequence).to.equal(@"enterA-guardA-exitA-actionA-enterB");
        });
        
        it(@"evaluates a guard function, and skips switching to the next state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL didExecuteAction = NO;
            
            [stateA registerEvent:eventA.name
                           target:stateB
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteAction = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return NO;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // will not enter state B
            [stateMachine scheduleEvent:eventA];
            
            expect(didExecuteAction).to.equal(NO);
            expect(stateMachine.currentState).to.equal(stateA);
        });
        
        it(@"evaluates multiple guard functions, and switches to the next state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL didExecuteActionA = NO;
            __block BOOL didExecuteActionB = NO;
            
            [stateA registerEvent:eventA.name
                           target:stateB
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteActionA = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return NO;
                            }];
            
            [stateA registerEvent:eventA.name
                           target:stateB
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteActionB = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // will enter state B through second transition
            [stateMachine scheduleEvent:eventA];
            
            expect(didExecuteActionA).to.equal(NO);
            expect(didExecuteActionB).to.equal(YES);
            expect(stateMachine.currentState).to.equal(stateB);
        });
        
        it(@"passes source and destination state and event data into the enter, exit, action and guard blocks of the involved states.", ^{
            
            NSArray *states = @[stateA, stateB];
            
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
            
            [stateA registerEvent:eventA.name
                           target:stateB
                             type:TBSMTransitionExternal
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
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            expect(sourceStateEnter).to.beNil;
            expect(targetStateEnter).to.equal(stateA);
            expect(stateDataEnter).to.beNil;
            
            // enters state B
            eventA.data = eventDataA;
            [stateMachine scheduleEvent:eventA];
            
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
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL didEnterStateA = NO;
            __block BOOL didExitStateA = NO;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                didEnterStateA = YES;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                didExitStateA = YES;
            };
            
            [stateA registerEvent:eventA.name target:stateA type:TBSMTransitionExternal];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            
            [stateMachine setUp:nil];
            
            didEnterStateA = NO;
            [stateMachine scheduleEvent:eventA];
            
            expect(stateMachine.currentState).to.equal(stateA);
            expect(didExitStateA).to.equal(YES);
            expect(didEnterStateA).to.equal(YES);
        });
        
        it(@"performs an internal transition if target state is nil and guard evaluates to YES.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
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
            
            [stateA registerEvent:eventA.name
                           target:nil
                             type:TBSMTransitionInternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-action"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                [executionSequence appendString:@"-guard"];
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // will perform two internal transitions
            [stateMachine scheduleEvent:eventA];
            [stateMachine scheduleEvent:eventA];
            
            expect(executionSequence).to.equal(@"-enterA-guard-action-guard-action");
        });
        
        it(@"performs an internal transition if target state is nil and guard is nil.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
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
            
            [stateA registerEvent:eventA.name
                           target:nil
                             type:TBSMTransitionInternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-action"];
                           }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // will perform two internal transitions
            [stateMachine scheduleEvent:eventA];
            [stateMachine scheduleEvent:eventA];
            
            expect(executionSequence).to.equal(@"enterA-action-action");
        });
        
        it(@"performs no internal transition if target state is nil and guard evaluates to NO.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
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
            
            [stateA registerEvent:eventA.name
                           target:nil
                             type:TBSMTransitionInternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-action"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                [executionSequence appendString:@"-guard"];
                                return NO;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // will perform no internal transitions
            [stateMachine scheduleEvent:eventA];
            [stateMachine scheduleEvent:eventA];
            
            expect(executionSequence).to.equal(@"enterA-guard-guard");
        });
        
        it(@"defers events until a state has been reached which can consume the event.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB, stateC];
            
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
            
            [stateA registerEvent:eventA.name target:stateB type:TBSMTransitionExternal];
            [stateA deferEvent:eventB.name];
            [stateB registerEvent:eventB.name target:stateC type:TBSMTransitionExternal];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // event should be deferred
            [stateMachine scheduleEvent:eventB];
            
            // should switch to state B --> handle eventB --> switch to stateC
            [stateMachine scheduleEvent:eventA];
            
            expect(stateMachine.currentState).to.equal(stateC);
            expect(executionSequence).to.equal(@"enterA-exitA-enterB-exitB-enterC");
        });
    });
});

SpecEnd
