//
//  TBStateMachineTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 09/14/2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(TBStateMachine)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_NAME_B = @"DummyEventB";
NSString * const EVENT_NAME_C = @"DummyEventC";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBStateMachine *stateMachine;
__block TBStateMachineState *stateA;
__block TBStateMachineState *stateB;
__block TBStateMachineState *stateC;
__block TBStateMachineState *stateD;
__block TBStateMachineState *stateE;
__block TBStateMachineState *stateF;

__block TBStateMachineEvent *eventA;
__block TBStateMachineEvent *eventB;
__block TBStateMachineEvent *eventC;
__block TBStateMachine *subStateMachineA;
__block TBStateMachine *subStateMachineB;
__block TBStateMachineParallelWrapper *parallelStates;
__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;


describe(@"TBStateMachine", ^{
    
    beforeEach(^{
        stateMachine = [TBStateMachine stateMachineWithName:@"StateMachine"];
        stateA = [TBStateMachineState stateWithName:@"a"];
        stateB = [TBStateMachineState stateWithName:@"b"];
        stateC = [TBStateMachineState stateWithName:@"c"];
        stateD = [TBStateMachineState stateWithName:@"d"];
        stateE = [TBStateMachineState stateWithName:@"e"];
        stateF = [TBStateMachineState stateWithName:@"f"];
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBStateMachineEvent eventWithName:EVENT_NAME_A];
        eventB = [TBStateMachineEvent eventWithName:EVENT_NAME_B];
        eventC = [TBStateMachineEvent eventWithName:EVENT_NAME_C];
        
        subStateMachineA = [TBStateMachine stateMachineWithName:@"SubA"];
        subStateMachineB = [TBStateMachine stateMachineWithName:@"SubB"];
        parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
    });
    
    afterEach(^{
        [stateMachine tearDown];
        
        stateMachine = nil;
        
        stateA = nil;
        stateB = nil;
        stateC = nil;
        stateD = nil;
        stateE = nil;
        stateF = nil;
        
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
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                stateMachine = [TBStateMachine stateMachineWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                stateMachine = [TBStateMachine stateMachineWithName:@""];
            }).to.raise(TBStateMachineException);
            
        });
        
        it(@"throws TBStateMachineException when state object does not implement the TBStateMachineNode protocol.", ^{
            id object = [[NSObject alloc] init];
            NSArray *states = @[stateA, stateB, object];
            expect(^{
                stateMachine.states = states;
            }).to.raise(TBStateMachineException);
        });
        
        it(@"throws TBStateMachineException initial state does not exist in set of defined states.", ^{
            NSArray *states = @[stateA, stateB];
            stateMachine.states = states;
            expect(^{
                stateMachine.initialState = stateC;
            }).to.raise(TBStateMachineException);
            
        });
        
        it(@"throws TBStateMachineException when initial state has not been set before setup.", ^{
            NSArray *states = @[stateA, stateB];
            stateMachine.states = states;
            
            expect(^{
                [stateMachine setUp];
            }).to.raise(TBStateMachineException);
        });
        
    });
    
    describe(@"State switching.", ^{
        
        it(@"enters initial state on set up.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBStateMachineState *sourceStateA;
            __block TBStateMachineState *destinationStateA;
            __block NSDictionary *dataEnterA;
            __block BOOL wasEnterExecuted = NO;
            __block BOOL wasExitExecuted = NO;
            
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                wasEnterExecuted = YES;
                sourceStateA = sourceState;
                destinationStateA = destinationState;
                dataEnterA = data;
            };
            
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                wasExitExecuted = YES;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            expect(wasEnterExecuted).to.equal(YES);
            expect(sourceStateA).to.beNil;
            expect(dataEnterA).to.beNil;
            expect(wasExitExecuted).to.equal(NO);
        });
        
        it(@"exits current state on tear down.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL wasEnterExecuted = NO;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                wasEnterExecuted = YES;
            };
            
            __block TBStateMachineState *sourceStateA;
            __block TBStateMachineState *destinationStateA;
            __block NSDictionary *dataExitA;
            __block BOOL wasExitExecuted = NO;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                wasExitExecuted = YES;
                sourceStateA = sourceState;
                destinationStateA = destinationState;
                dataExitA = data;
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
            
            expect(sourceStateA).to.equal(stateA);
            expect(destinationStateA).to.beNil;
            expect(dataExitA).to.beNil;
            expect(wasEnterExecuted).to.equal(NO);
            expect(wasExitExecuted).to.equal(YES);
        });
        
        it(@"switches to the specified state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBStateMachineState *sourceStateA;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            __block TBStateMachineState *destinationStateA;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
            __block TBStateMachineState *sourceStateB;
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
            };
            
            [stateA registerEvent:eventA target:stateB];
            
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
            
            NSMutableString *executionOrder = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
            __block TBStateMachineState *sourceStateA;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            __block TBStateMachineState *destinationStateA;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
                [executionOrder appendString:@"-exit"];
            };
            
            __block TBStateMachineState *sourceStateB;
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
                [executionOrder appendString:@"-enter"];
            };
            
            __block BOOL didExecuteAction = NO;
            [stateA registerEvent:eventA
                           target:stateB
                           action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                               didExecuteAction = YES;
                               [executionOrder appendString:@"-action"];
                           }
                            guard:^BOOL(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                                [executionOrder appendString:@"guard"];
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will enter state B
            [stateMachine scheduleEvent:eventA];
            
            expect(didExecuteAction).to.equal(YES);
            expect(sourceStateA).to.beNil;
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
            expect(executionOrder).to.equal(@"guard-exit-action-enter");
        });
        
        it(@"evaluates a guard function, and skips switching to the next state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL didExecuteEnterA = NO;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                didExecuteEnterA = YES;
            };
            
            __block BOOL didExecuteExitA = NO;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                didExecuteExitA = YES;
            };
            
            __block BOOL didExecuteEnterB = NO;
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                didExecuteEnterB = YES;
            };
            
            __block BOOL didExecuteAction = NO;
            [stateA registerEvent:eventA
                           target:stateB
                           action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                               didExecuteAction = YES;
                           }
                            guard:^BOOL(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
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
        
        it(@"passes next state and event data into the guard function and transition action of the involved state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block id<TBStateMachineNode> destinationStateAction;
            __block NSDictionary *receivedDataAction;
            __block id<TBStateMachineNode> destinationStateGuard;
            __block NSDictionary *receivedDataGuard;
            [stateA registerEvent:eventA
                           target:stateB
                           action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                               destinationStateAction = destinationState;
                               receivedDataAction = data;
                           }
                            guard:^BOOL(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                                destinationStateGuard = destinationState;
                                receivedDataGuard = data;
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will enter state B
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            expect(destinationStateAction).to.equal(stateB);
            expect(receivedDataAction).to.equal(eventDataA);
            expect(receivedDataAction[EVENT_DATA_KEY]).toNot.beNil;
            expect(receivedDataAction[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(destinationStateGuard).to.equal(stateB);
            expect(receivedDataGuard).to.equal(eventDataA);
            expect(receivedDataGuard[EVENT_DATA_KEY]).toNot.beNil;
            expect(receivedDataGuard[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"passes next state and event data into the enter, exit, action and guard blocks of the involved states.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block id<TBStateMachineNode> destinationStateA;
            __block NSDictionary *destinationStateAData;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
                destinationStateAData = data;
            };
            
            __block NSDictionary *actionData;
            __block NSDictionary *guardData;
            [stateA registerEvent:eventA target:stateB action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                actionData = data;
            }
                            guard:^BOOL(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                                guardData = data;
                                return YES;
                            }];
            
            __block TBStateMachineState *sourceStateB;
            __block NSDictionary *sourceStateBData;
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
                sourceStateBData = data;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // enters state B
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
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
            
            NSArray *states = @[stateA];
            
            __block TBStateMachineState *sourceStateA;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            __block TBStateMachineState *destinationStateA;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
            [stateA registerEvent:eventA target:stateA];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            
            [stateMachine setUp];
            
            [stateMachine scheduleEvent:eventA];
            
            expect(sourceStateA).to.equal(stateA);
            expect(destinationStateA).to.equal(stateA);
        });
        
        it(@"can switch into and out of sub-state machines.", ^{
            
            // setup sub-state machine A
            __block TBStateMachineState *sourceStateC;
            stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateC = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateC;
            stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateC = destinationState;
            };
            
            __block TBStateMachineState *sourceStateD;
            stateD.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateD = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateD;
            __block NSDictionary *dataExitD;
            stateD.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateD = destinationState;
                dataExitD = data;
            };
            
            [stateC registerEvent:eventA target:stateD];
            [stateD registerEvent:eventA target:stateA];
            
            NSArray *subStates = @[stateC, stateD];
            subStateMachineA.states = subStates;
            subStateMachineA.initialState = stateC;
            
            // setup main state machine
            __block id<TBStateMachineNode> sourceStateA;
            __block NSDictionary *dataEnterA;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
                dataEnterA = data;
            };
            
            __block TBStateMachineState *destinationStateA;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
            __block TBStateMachineState *sourceStateB;
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateB;
            stateB.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateB = destinationState;
            };
            
            [stateA registerEvent:eventA target:stateB];
            [stateB registerEvent:eventA target:subStateMachineA];
            
            NSArray *states = @[stateA, stateB, subStateMachineA];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(sourceStateA).to.beNil;
            
            // moves to state B
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
            
            // moves to sub machine A which enters C
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateB).to.equal(subStateMachineA);
            expect(sourceStateC).to.beNil;
            
            // moves to state D
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateC).to.equal(stateD);
            expect(sourceStateD).to.equal(stateC);
            
            dataEnterA = nil;
            
            // will go back to start
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            expect(dataExitD[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(sourceStateA).to.equal(stateD);
            expect(destinationStateD).to.beNil;
            
            expect(dataEnterA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            // handled by state A
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
        });
        
        it(@"can deeply switch into and out of sub-state machines using lowest common ancestor algorithm.", ^{
            
            // setup sub-state machine A
            __block TBStateMachineState *sourceStateA;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateA;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
            __block TBStateMachineState *sourceStateB;
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateB;
            __block NSDictionary *dataExitB;
            stateB.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateB = destinationState;
                dataExitB = data;
            };
            
            [stateA registerEvent:eventA target:stateB];
            [stateB registerEvent:eventA target:stateD];
            
            NSArray *subStatesA = @[stateA, stateB];
            subStateMachineA.states = subStatesA;
            subStateMachineA.initialState = stateA;
            
            // setup sub-state machine B
            __block TBStateMachineState *sourceStateC;
            stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateC = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateC;
            stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateC = destinationState;
            };
            
            __block TBStateMachineState *sourceStateD;
            stateD.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateD = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateD;
            __block NSDictionary *dataExitD;
            stateD.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateD = destinationState;
                dataExitD = data;
            };
            
            [stateC registerEvent:eventA target:stateD];
            [stateD registerEvent:eventA target:stateA];
            
            NSArray *subStatesB = @[stateC, stateD];
            subStateMachineB.states = subStatesB;
            subStateMachineB.initialState = stateC;
            
            // setup parallel wrapper
            parallelStates.states = @[subStateMachineB];
            
            // setup main state machine
            NSArray *states = @[subStateMachineA, parallelStates];
            stateMachine.states = states;
            stateMachine.initialState = subStateMachineA;
            [stateMachine setUp];
            
            expect(sourceStateA).to.beNil;
            
            // moves to state B
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
            
            // moves to state D
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateB).to.beNil;
            expect(sourceStateD).to.beNil;
            
            sourceStateA = nil;
            
            // will go back to start
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            expect(sourceStateA).to.equal(stateD);
            expect(destinationStateD).to.beNil;
            
            // handled by state A
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
            
        });
        
        it(@"can switch into and out of parallel state machines.", ^{
            
            // setup sub-machine A
            __block TBStateMachineState *sourceStateC;
            stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateC = sourceState;
            };
            
            __block TBStateMachineState *destinationStateC;
            stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateC = destinationState;
            };
            
            __block TBStateMachineState *sourceStateD;
            stateD.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateD = sourceState;
            };
            
            __block TBStateMachineState *destinationStateD;
            stateD.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateD = destinationState;
            };
            
            NSArray *subStatesA = @[stateC, stateD];
            subStateMachineA.states = subStatesA;
            subStateMachineA.initialState = stateC;
            
            // setup sub-machine B
            __block TBStateMachineState *sourceStateE;
            stateE.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateE = sourceState;
            };
            
            __block TBStateMachineState *destinationStateE;
            stateE.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateE = destinationState;
            };
            
            __block TBStateMachineState *sourceStateF;
            stateF.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateF = sourceState;
            };
            
            __block TBStateMachineState *destinationStateF;
            stateF.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateF = destinationState;
            };
            
            NSArray *subStatesB = @[stateE, stateF];
            subStateMachineB.states = subStatesB;
            subStateMachineB.initialState = stateE;
            
            // setup parallel wrapper
            NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
            parallelStates.states = parallelSubStateMachines;
            
            // setup main state machine
            __block id<TBStateMachineNode> sourceStateA;
            __block NSDictionary *sourceStateDataA;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
                sourceStateDataA = data;
            };
            
            __block TBStateMachineState *destinationStateA;
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
            __block TBStateMachineState *sourceStateB;
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
            };
            
            __block id<TBStateMachineNode> destinationStateB;
            stateB.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateB = destinationState;
            };
            
            [stateA registerEvent:eventA target:stateB];
            [stateB registerEvent:eventA target:parallelStates];
            [stateC registerEvent:eventA target:stateD];
            [stateD registerEvent:eventA target:nil];
            [stateE registerEvent:eventA target:stateF];
            [stateF registerEvent:eventA target:stateA];
            
            NSArray *states = @[stateA, stateB, parallelStates];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(sourceStateA).to.beNil;
            
            // moves to state B
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateA).to.equal(stateB);
            expect(sourceStateB).to.equal(stateA);
            
            // moves to parallel state wrapper
            // enters state C in subStateMachine A
            // enters state E in subStateMachine B
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateB).to.equal(parallelStates);
            expect(sourceStateC).to.beNil;
            expect(sourceStateE).to.beNil;
            
            // moves subStateMachine A from C to state D
            // moves subStateMachine B from E to state F
            [stateMachine scheduleEvent:eventA];
            
            expect(destinationStateC).to.equal(stateD);
            expect(sourceStateD).to.equal(stateC);
            
            expect(destinationStateE).to.equal(stateF);
            expect(sourceStateF).to.equal(stateE);
            
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            // moves back to state A
            expect(destinationStateD).to.beNil;
            expect(destinationStateF).to.beNil;
            expect(sourceStateA).to.beNil;
            expect(sourceStateDataA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
    });
    
    describe(@"Concurrency", ^{
        
        it(@"queues up events if an event is currently handled", ^{
            
            NSArray *expectedExecutionSequence = @[@"stateA_enter",
                                                   @"stateA_exit",
                                                   @"stateA_action",
                                                   @"stateB_enter",
                                                   @"stateB_exit",
                                                   @"stateB_action",
                                                   @"stateC_enter",
                                                   @"stateC_exit",
                                                   @"stateC_action",
                                                   @"stateA_enter"];
            
            NSMutableArray *executionSequence = [NSMutableArray new];
            
            __block NSUInteger enteredCount = 0;
            __block NSUInteger guardExecutedCount = 0;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_enter"];
                enteredCount++;
                [stateMachine scheduleEvent:eventA];
            };
            
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_exit"];
            };
            
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_enter"];
                [stateMachine scheduleEvent:eventC];
            };
            
            stateB.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_exit"];
            };
            
            stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_enter"];
            };
            
            stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_exit"];
            };
            
            [stateA registerEvent:eventA target:stateB action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_action"];
                [stateMachine scheduleEvent:eventB];
            } guard:^BOOL(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                guardExecutedCount++;
                return (enteredCount == 1);
            }];
            
            [stateB registerEvent:eventB target:stateC action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_action"];
            }];
            
            [stateC registerEvent:eventC target:stateA action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_action"];
            }];
            
            
            NSArray *states = @[stateA, stateB, stateC];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // enter A --> send eventA
            // switch to B with action --> send eventB (queued)
            // enter B --> send eventC (queued)
            
            // -------------------
            // stateB handles eventB
            // switch to stateC with action
            
            // -------------------
            // stateC handles eventC
            // switch to stateA with action
            
            // -------------------
            // stateA handles eventA
            // guard evaluates as false
            
            expect(enteredCount).to.equal(2);
            expect(guardExecutedCount).to.equal(2);
            
            NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
            NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
            expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
        });
        
        it(@"handles events sent concurrently from multiple threads", ^AsyncBlock {
            
            
            NSArray *expectedExecutionSequence = @[@"stateA_enter",
                                                   @"stateA_exit",
                                                   @"stateA_action",
                                                   @"stateB_enter",
                                                   @"stateB_exit",
                                                   @"stateB_action",
                                                   @"stateC_enter",
                                                   @"stateC_exit",
                                                   @"stateC_action",
                                                   @"stateD_enter",
                                                   @"stateD_exit",
                                                   @"stateD_action",
                                                   @"stateA_enter"];
            
            NSMutableArray *executionSequence = [NSMutableArray new];
            
            __block NSUInteger enteredCount = 0;
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_enter"];
                enteredCount++;
                
                // quit if we have finished the roundtrip and arrived back in stateA.
                if (enteredCount == 2) {
                    done();
                }
            };
            
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_exit"];
            };
            
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_enter"];
            };
            
            stateB.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_exit"];
            };
            
            stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_enter"];
            };
            
            stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_exit"];
            };
            
            stateD.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_enter"];
            };
            
            stateD.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_exit"];
            };
            
            [stateA registerEvent:eventA target:stateB action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_action"];
            }];
            
            [stateB registerEvent:eventA target:stateC action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_action"];
            }];
            
            [stateC registerEvent:eventA target:stateD action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_action"];
            }];
            
            [stateD registerEvent:eventA target:stateA action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_action"];
            }];
            
            
            NSArray *states = @[stateA, stateB, stateC, stateD];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // send all events concurrently.
            dispatch_apply(4, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t idx) {
                [stateMachine scheduleEvent:eventA];
            });
            
            expect(executionSequence).to.equal(expectedExecutionSequence);
            
        });
        
    });
});

SpecEnd
