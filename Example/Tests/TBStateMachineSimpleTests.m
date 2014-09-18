//
//  TBStateMachineSimpleTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(TBStateMachineSimple)

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
            __block TBStateMachineState *sourceStateA;
            __block TBStateMachineState *destinationStateA;
            __block NSDictionary *dataExitA;
            __block BOOL wasExitExecuted = NO;
            
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                wasEnterExecuted = YES;
            };
            
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
            __block TBStateMachineState *destinationStateA;
            __block TBStateMachineState *sourceStateB;
            
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
            };
            
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
            __block TBStateMachineState *destinationStateA;
            __block TBStateMachineState *sourceStateB;
            __block BOOL didExecuteAction = NO;
            
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
                [executionOrder appendString:@"-exit"];
            };
            
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateB = sourceState;
                [executionOrder appendString:@"-enter"];
            };
            
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
            __block BOOL didExecuteExitA = NO;
            __block BOOL didExecuteEnterB = NO;
            __block BOOL didExecuteAction = NO;
            
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                didExecuteEnterA = YES;
            };
            
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                didExecuteExitA = YES;
            };
            
            stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                didExecuteEnterB = YES;
            };
            
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
        
        it(@"passes source and destination state and event data into the guard function and transition action of the involved state.", ^{
            
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
        
        it(@"passes source and destination state and event data into the enter, exit, action and guard blocks of the involved states.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block id<TBStateMachineNode> destinationStateA;
            __block NSDictionary *destinationStateAData;
            __block NSDictionary *actionData;
            __block NSDictionary *guardData;
            __block TBStateMachineState *sourceStateB;
            __block NSDictionary *sourceStateBData;
            
            stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                destinationStateA = destinationState;
                destinationStateAData = data;
            };
            
            [stateA registerEvent:eventA target:stateB action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                actionData = data;
            }
                            guard:^BOOL(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                                guardData = data;
                                return YES;
                            }];
            
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
            
            NSArray *states = @[stateA, stateB];
            
            __block TBStateMachineState *sourceStateA;
            __block TBStateMachineState *destinationStateA;
            
            stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                sourceStateA = sourceState;
            };
            
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
        
    });
    
});
SpecEnd
