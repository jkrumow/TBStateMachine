//
//  TBStateMachineNestedTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 18.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(TBStateMachineNested)

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
__block TBStateMachineParallelState *parallelStates;
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
        parallelStates = [TBStateMachineParallelState parallelStateWithName:@"ParallelWrapper"];
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
    
    it(@"can switch into and out of sub-state machines.", ^{
        
        // setup sub-state machine A
        __block TBStateMachineState *sourceStateC;
        __block id<TBStateMachineNode> destinationStateC;
        __block TBStateMachineState *sourceStateD;
        __block id<TBStateMachineNode> destinationStateD;
        __block NSDictionary *dataExitD;
        
        stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateC = sourceState;
        };
        
        stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateC = destinationState;
        };
        
        stateD.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateD = sourceState;
        };
        
        stateD.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateD = destinationState;
            dataExitD = data;
        };
        
        [stateC registerEvent:eventA target:stateD];
        [stateD registerEvent:eventA target:stateA];
        
        NSArray *subStates = @[stateC, stateD];
        subStateMachineA.states = subStates;
        subStateMachineA.initialState = stateC;
        TBStateMachineSubState *subStateA = [TBStateMachineSubState subStateWithName:@"subStateA" stateMachine:subStateMachineA];
        
        // setup main state machine
        __block id<TBStateMachineNode> sourceStateA;
        __block NSDictionary *dataEnterA;
        __block TBStateMachineState *destinationStateA;
        __block TBStateMachineState *sourceStateB;
        __block id<TBStateMachineNode> destinationStateB;
        
        stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateA = sourceState;
            dataEnterA = data;
        };
        
        stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateA = destinationState;
        };
        
        stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateB = sourceState;
        };
        
        stateB.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateB = destinationState;
        };
        
        [stateA registerEvent:eventA target:stateB];
        [stateB registerEvent:eventA target:subStateA];
        
        
        NSArray *states = @[stateA, stateB, subStateA];
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
        
        expect(destinationStateB).to.equal(subStateA);
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
        __block id<TBStateMachineNode> destinationStateA;
        __block TBStateMachineState *sourceStateB;
        __block id<TBStateMachineNode> destinationStateB;
        __block NSDictionary *dataExitB;
        
        stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateA = sourceState;
        };
        
        stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateA = destinationState;
        };
        
        stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateB = sourceState;
        };
        
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
        __block id<TBStateMachineNode> destinationStateC;
        __block TBStateMachineState *sourceStateD;
        __block id<TBStateMachineNode> destinationStateD;
        __block NSDictionary *dataExitD;
        
        stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateC = sourceState;
        };
        
        stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateC = destinationState;
        };
        
        stateD.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateD = sourceState;
        };
        
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
        
        // setup sub state machine wrapper
        TBStateMachineSubState *subStateA = [TBStateMachineSubState subStateWithName:@"SubStateA" stateMachine:subStateMachineA];
        
        // setup main state machine
        NSArray *states = @[subStateA, parallelStates];
        stateMachine.states = states;
        stateMachine.initialState = subStateA;
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
        __block TBStateMachineState *destinationStateC;
        __block TBStateMachineState *sourceStateD;
        __block TBStateMachineState *destinationStateD;
        
        stateC.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateC = sourceState;
        };
        
        stateC.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateC = destinationState;
        };
        
        stateD.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateD = sourceState;
        };
        
        stateD.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateD = destinationState;
        };
        
        NSArray *subStatesA = @[stateC, stateD];
        subStateMachineA.states = subStatesA;
        subStateMachineA.initialState = stateC;
        
        // setup sub-machine B
        __block TBStateMachineState *sourceStateE;
        __block TBStateMachineState *destinationStateE;
        __block TBStateMachineState *sourceStateF;
        __block TBStateMachineState *destinationStateF;
        
        stateE.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateE = sourceState;
        };
        
        stateE.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateE = destinationState;
        };
        
        stateF.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateF = sourceState;
        };
        
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
        __block TBStateMachineState *destinationStateA;
        __block TBStateMachineState *sourceStateB;
        __block id<TBStateMachineNode> destinationStateB;
        
        stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateA = sourceState;
            sourceStateDataA = data;
        };
        
        stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            destinationStateA = destinationState;
        };
        
        stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            sourceStateB = sourceState;
        };
        
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

SpecEnd
