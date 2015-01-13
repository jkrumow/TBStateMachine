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
        [stateMachine tearDown];
        
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
        
        [subStateMachineA tearDown];
        [subStateMachineB tearDown];
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
                [stateMachine setUp];
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
            
            expect(path.count).to.equal(4);
            expect(path[0]).to.equal(stateMachine);
            expect(path[1]).to.equal(parallelStates);
            expect(path[2]).to.equal(subStateMachineA);
            expect(path[3]).to.equal(subStateB);
        });
        
        it(@"returns its name.", ^{
            TBSMStateMachine *stateMachineXYZ = [TBSMStateMachine stateMachineWithName:@"StateMachineXYZ"];
            expect(stateMachineXYZ.name).to.equal(@"StateMachineXYZ");
        });
        
    });
    
    describe(@"State switching.", ^{
        
        it(@"enters initial state on set up.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL wasEnterExecuted = NO;
            __block BOOL wasExitExecuted = NO;
            
            __block TBSMState *weakStateA = stateA;
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                wasEnterExecuted = YES;
                expect(sourceState).to.beNil;
                expect(destinationState).to.equal(weakStateA);
                expect(data).to.beNil;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                wasExitExecuted = YES;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            
            expect(stateMachine.initialState).to.equal(stateA);
            
            [stateMachine setUp];
            
            expect(stateMachine.currentState).to.equal(stateA);
            expect(wasEnterExecuted).to.equal(YES);
            expect(wasExitExecuted).to.equal(NO);
        });
        
        it(@"exits current state on tear down.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL wasEnterExecuted = NO;
            __block BOOL wasExitExecuted = NO;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                wasEnterExecuted = YES;
            };
            
            __block TBSMState *weakStateA = stateA;
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                wasExitExecuted = YES;
                expect(sourceState).to.equal(weakStateA);
                expect(destinationState).to.beNil;
                expect(data).to.beNil;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(stateMachine.currentState).to.equal(stateA);
            expect(wasEnterExecuted).to.equal(YES);
            expect(wasExitExecuted).to.equal(NO);
            
            wasEnterExecuted = NO;
            [stateMachine tearDown];
            
            expect(stateMachine.currentState).to.beNil;
            expect(wasEnterExecuted).to.equal(NO);
            expect(wasExitExecuted).to.equal(YES);
        });
        
        it(@"switches to the specified state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBSMState *sourceStateA;
            __block TBSMState *destinationStateA;
            __block TBSMState *sourceStateB;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
            };
            
            [stateA registerEvent:eventA.name target:stateB];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            // enters state B
            [stateMachine scheduleEvent:eventA];
            
            expect(stateMachine.currentState).to.equal(stateB);
            
            expect(sourceStateA).to.beNil;
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
        });
        
        it(@"evaluates a guard function, exits the current state, executes transition action and enters the next state.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
            __block TBSMState *sourceStateA;
            __block TBSMState *destinationStateA;
            __block TBSMState *sourceStateB;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
                [executionSequence appendString:@"-exit"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
                [executionSequence appendString:@"-enter"];
            };
            
            [stateA registerEvent:eventA.name
                           target:stateB
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               [executionSequence appendString:@"-action"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                [executionSequence appendString:@"guard"];
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will enter state B
            [stateMachine scheduleEvent:eventA];
            
            expect(sourceStateA).to.beNil;
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
            expect(executionSequence).to.equal(@"guard-exit-action-enter");
        });
        
        it(@"evaluates a guard function, and skips switching to the next state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL didExecuteEnterA = NO;
            __block BOOL didExecuteExitA = NO;
            __block BOOL didExecuteEnterB = NO;
            __block BOOL didExecuteAction = NO;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                didExecuteEnterA = YES;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                didExecuteExitA = YES;
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                didExecuteEnterB = YES;
            };
            
            [stateA registerEvent:eventA.name
                           target:stateB
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               didExecuteAction = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                return NO;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(didExecuteEnterA).to.equal(YES);
            
            // will not enter state B
            [stateMachine scheduleEvent:eventA];
            
            expect(didExecuteAction).to.equal(NO);
            expect(didExecuteExitA).to.equal(NO);
            expect(didExecuteEnterB).to.equal(NO);
        });
        
        it(@"passes source and destination state and event data into the guard function and transition action of the involved state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBSMState *destinationStateAction;
            __block NSDictionary *receivedDataAction;
            __block TBSMState *destinationStateGuard;
            __block NSDictionary *receivedDataGuard;
            [stateA registerEvent:eventA.name
                           target:stateB
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               destinationStateAction = destinationState;
                               receivedDataAction = data;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                destinationStateGuard = destinationState;
                                receivedDataGuard = data;
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will enter state B
            eventA.data = eventDataA;
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateAction).to.equal(stateB);
            expect(receivedDataAction).to.equal(eventDataA);
            expect(receivedDataAction[EVENT_DATA_KEY]).toNot.beNil;
            expect(receivedDataAction[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(destinationStateGuard).to.equal(stateB);
            expect(receivedDataGuard).to.equal(eventDataA);
            expect(receivedDataGuard[EVENT_DATA_KEY]).toNot.beNil;
            expect(receivedDataGuard[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"passes source and destination state and event data into the enter, exit, action and guard blocks of the involved states.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBSMState *destinationStateA;
            __block NSDictionary *destinationStateAData;
            __block NSDictionary *actionData;
            __block NSDictionary *guardData;
            __block TBSMState *sourceStateB;
            __block NSDictionary *sourceStateBData;
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
                destinationStateAData = data;
            };
            
            [stateA registerEvent:eventA.name target:stateB action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                actionData = data;
            }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                guardData = data;
                                return YES;
                            }];
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
                sourceStateBData = data;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // enters state B
            eventA.data = eventDataA;
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateA).to.equal(stateB);
            expect(destinationStateAData).to.equal(eventDataA);
            expect(destinationStateAData.allKeys).haveCountOf(1);
            expect(destinationStateAData[EVENT_DATA_KEY]).toNot.beNil;
            expect(destinationStateAData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(actionData).to.equal(eventDataA);
            expect(actionData.allKeys).haveCountOf(1);
            expect(actionData[EVENT_DATA_KEY]).toNot.beNil;
            expect(actionData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(guardData).to.equal(eventDataA);
            expect(guardData.allKeys).haveCountOf(1);
            expect(guardData[EVENT_DATA_KEY]).toNot.beNil;
            expect(guardData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            
            expect(sourceStateB).to.equal(stateA);
            expect(sourceStateBData).to.equal(eventDataA);
            expect(sourceStateBData.allKeys).haveCountOf(1);
            expect(sourceStateBData[EVENT_DATA_KEY]).toNot.beNil;
            expect(sourceStateBData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"can re-enter a state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBSMState *sourceStateA;
            __block TBSMState *destinationStateA;
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
            [stateA registerEvent:eventA.name target:stateA];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            
            [stateMachine setUp];
            [stateMachine scheduleEvent:eventA];
            
            expect(sourceStateA).to.equal(stateA);
            expect(destinationStateA).to.equal(stateA);
        });
        
        it(@"performs an internal transition if target state is nil and guard evaluates to YES.", ^{
            
            __block TBSMState *sourceStateGuard = nil;
            __block TBSMState *destinationStateGuard = nil;
            __block TBSMState *sourceStateAction = nil;
            __block TBSMState *destinationStateAction = nil;
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            [stateA registerEvent:eventA.name
                           target:nil
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               sourceStateAction = sourceState;
                               destinationStateAction = destinationState;
                               [executionSequence appendString:@"-action"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                sourceStateGuard = sourceState;
                                destinationStateGuard = destinationState;
                                [executionSequence appendString:@"-guard"];
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will perform two internal transitions
            [stateMachine scheduleEvent:eventA];
            [stateMachine scheduleEvent:eventA];
            
            expect(executionSequence).to.equal(@"-enterA-guard-action-guard-action");
            expect(sourceStateGuard).to.equal(stateA);
            expect(destinationStateGuard).to.beNil;
            expect(sourceStateAction).to.equal(stateA);
            expect(destinationStateAction).to.beNil;
        });
        
        it(@"performs an internal transition if target state is nil and guard is nil.", ^{
            
            __block TBSMState *sourceStateAction = nil;
            __block TBSMState *destinationStateAction = nil;
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            [stateA registerEvent:eventA.name
                           target:nil
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               sourceStateAction = sourceState;
                               destinationStateAction = destinationState;
                               [executionSequence appendString:@"-action"];
                           }
                            guard:nil];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will perform two internal transitions
            [stateMachine scheduleEvent:eventA];
            [stateMachine scheduleEvent:eventA];
            
            expect(executionSequence).to.equal(@"-enterA-action-action");
            expect(sourceStateAction).to.equal(stateA);
            expect(destinationStateAction).to.beNil;
        });
        
        it(@"performs no internal transition if target state is nil and guard evaluates to NO.", ^{
            
            __block TBSMState *sourceStateGuard = nil;
            __block TBSMState *destinationStateGuard = nil;
            __block TBSMState *sourceStateAction = nil;
            __block TBSMState *destinationStateAction = nil;
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            [stateA registerEvent:eventA.name
                           target:nil
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               sourceStateAction = sourceState;
                               destinationStateAction = destinationState;
                               [executionSequence appendString:@"-action"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                sourceStateGuard = sourceState;
                                destinationStateGuard = destinationState;
                                [executionSequence appendString:@"-guard"];
                                return NO;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will perform no internal transitions
            [stateMachine scheduleEvent:eventA];
            [stateMachine scheduleEvent:eventA];
            
            expect(executionSequence).to.equal(@"-enterA-guard-guard");
            expect(sourceStateGuard).to.equal(stateA);
            expect(destinationStateGuard).to.beNil;
            expect(sourceStateAction).to.beNil;
            expect(destinationStateAction).to.beNil;
        });
        
        it(@"defers events until a state has been reached which can consume the event.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB, stateC];
            
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterA"];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitB"];
            };
            
            stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-enterC"];
            };
            
            stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence appendString:@"-exitC"];
            };
            
            [stateA registerEvent:eventA.name target:stateB];
            [stateA deferEvent:eventB.name];
            [stateB registerEvent:eventB.name target:stateC];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // event should be deferred
            [stateMachine scheduleEvent:eventB];
            
            // should switch to state B --> handle eventB --> switch to stateC
            [stateMachine scheduleEvent:eventA];
            
            expect(stateMachine.currentState).to.equal(stateC);
        });
    });
});

SpecEnd
