//
//  TBSMStateMachineNestedTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 18.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMStateMachineNested)

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
__block TBSMState *stateF;

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
        stateF = [TBSMState stateWithName:@"f"];
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBSMEvent eventWithName:EVENT_NAME_A];
        eventB = [TBSMEvent eventWithName:EVENT_NAME_B];
        eventC = [TBSMEvent eventWithName:EVENT_NAME_C];
        
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
        
        NSArray *expectedExecutionSequence = @[@"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter",
                                               @"stateB_exit",
                                               @"subStateA_enter",
                                               @"stateC_enter",
                                               @"stateC_exit",
                                               @"stateD_enter",
                                               @"stateD_exit",
                                               @"subStateA_exit",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        __block TBSMState *sourceStateC;
        __block id<TBSMNode> destinationStateC;
        __block TBSMState *sourceStateD;
        __block id<TBSMNode> destinationStateD;
        __block NSDictionary *dataExitD;
        
        stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_enter"];
            sourceStateC = sourceState;
        };
        
        stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_exit"];
            destinationStateC = destinationState;
        };
        
        stateD.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_enter"];
            sourceStateD = sourceState;
        };
        
        stateD.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_exit"];
            destinationStateD = destinationState;
            dataExitD = data;
        };
        
        [stateC registerEvent:eventA target:stateD];
        [stateD registerEvent:eventA target:stateA];
        
        NSArray *subStates = @[stateC, stateD];
        subStateMachineA.states = subStates;
        subStateMachineA.initialState = stateC;
        
        __block TBSMState *sourceStateEnterSubA;
        __block TBSMState *destinationStateEnterSubA;
        __block TBSMState *sourceStateExitSubA;
        __block TBSMState *destinationStateExitSubA;
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA" stateMachine:subStateMachineA];
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
            sourceStateEnterSubA = sourceState;
            destinationStateEnterSubA = destinationState;
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
            sourceStateExitSubA = sourceState;
            destinationStateExitSubA = destinationState;
        };
        
        // setup main state machine
        __block id<TBSMNode> sourceStateA;
        __block NSDictionary *dataEnterA;
        __block TBSMState *destinationStateA;
        __block TBSMState *sourceStateB;
        __block id<TBSMNode> destinationStateB;
        
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
            sourceStateA = sourceState;
            dataEnterA = data;
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
            destinationStateA = destinationState;
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
            sourceStateB = sourceState;
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
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
        
        expect(sourceStateEnterSubA).to.equal(stateB);
        expect(destinationStateEnterSubA).to.equal(subStateA);
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
        
        expect(sourceStateExitSubA).to.equal(stateD);
        expect(destinationStateExitSubA).to.equal(stateA);
        expect(destinationStateD).to.equal(stateA);
        expect(sourceStateA).to.equal(stateD);
        
        
        expect(dataEnterA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        
        // handled by state A
        [stateMachine scheduleEvent:eventA];
        
        expect(destinationStateA).to.equal(stateB);
        expect(sourceStateB).to.equal(stateA);
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"can deeply switch into and out of sub-state machines using lowest common ancestor algorithm.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter",
                                               @"stateB_exit",
                                               @"subStateA_exit",
                                               @"stateD_enter",
                                               @"stateD_exit",
                                               @"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        __block TBSMState *sourceStateA;
        __block id<TBSMNode> destinationStateA;
        __block TBSMState *sourceStateB;
        __block id<TBSMNode> destinationStateB;
        __block NSDictionary *dataExitB;
        
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
            sourceStateA = sourceState;
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
            destinationStateA = destinationState;
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
            sourceStateB = sourceState;
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
            destinationStateB = destinationState;
            dataExitB = data;
        };
        
        [stateA registerEvent:eventA target:stateB];
        [stateB registerEvent:eventA target:stateD];
        
        NSArray *subStatesA = @[stateA, stateB];
        subStateMachineA.states = subStatesA;
        subStateMachineA.initialState = stateA;
        
        // setup sub-state machine B
        __block TBSMState *sourceStateC;
        __block TBSMState *destinationStateC;
        __block TBSMState *sourceStateD;
        __block TBSMState *destinationStateD;
        __block TBSMState *sourceStateEnterSubA;
        __block TBSMState *destinationStateEnterSubA;
        __block TBSMState *sourceStateExitSubA;
        __block TBSMState *destinationStateExitSubA;
        __block NSDictionary *dataExitD;
        
        stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_enter"];
            sourceStateC = sourceState;
        };
        
        stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_exit"];
            destinationStateC = destinationState;
        };
        
        stateD.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_enter"];
            sourceStateD = sourceState;
        };
        
        stateD.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_exit"];
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
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA" stateMachine:subStateMachineA];
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
            sourceStateEnterSubA = sourceState;
            destinationStateEnterSubA = destinationState;
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
            sourceStateExitSubA = sourceState;
            destinationStateExitSubA = destinationState;
        };
        
        // setup main state machine
        NSArray *states = @[subStateA, parallelStates];
        stateMachine.states = states;
        stateMachine.initialState = subStateA;
        [stateMachine setUp];
        
        expect(sourceStateEnterSubA).to.beNil;
        expect(destinationStateEnterSubA).to.beNil;
        expect(sourceStateA).to.beNil;
        
        // moves to state B
        [stateMachine scheduleEvent:eventA];
        
        expect(destinationStateA).to.equal(stateB);
        expect(sourceStateB).to.equal(stateA);
        
        // moves to state D
        [stateMachine scheduleEvent:eventA];
        
        expect(destinationStateB).to.equal(stateD);
        expect(destinationStateExitSubA).to.equal(stateD);
        expect(sourceStateD).to.equal(stateB);
        
        sourceStateA = nil;
        
        // will go back to start
        [stateMachine scheduleEvent:eventA data:eventDataA];
        
        expect(destinationStateD).to.equal(stateA);
        expect(sourceStateEnterSubA).to.equal(stateD);
        expect(destinationStateEnterSubA).to.equal(stateA);
        expect(sourceStateA).to.equal(stateD);
        
        // handled by state A
        [stateMachine scheduleEvent:eventA];
        
        expect(destinationStateA).to.equal(stateB);
        expect(sourceStateB).to.equal(stateA);
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"switches nowhere if the destination state was not found using lowest common ancestor algorithm.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        [stateA registerEvent:eventA target:stateF];
        
        NSArray *subStatesA = @[stateA];
        subStateMachineA.states = subStatesA;
        subStateMachineA.initialState = stateA;
        
        // setup sub-state machine B
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        NSArray *subStatesB = @[stateB];
        subStateMachineB.states = subStatesB;
        subStateMachineB.initialState = stateB;
        
        // setup sub state machine wrapper
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA" stateMachine:subStateMachineA];
        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"SubStateB" stateMachine:subStateMachineB];
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        subStateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"subStateB_enter"];
        };
        
        // setup main state machine
        NSArray *states = @[subStateA, subStateB];
        stateMachine.states = states;
        stateMachine.initialState = subStateA;
        [stateMachine setUp];
        
        // moves to state F
        [stateMachine scheduleEvent:eventA];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"can switch into and out of parallel state machines.", ^{
        
        // setup sub-machine A
        __block TBSMState *sourceStateC;
        __block TBSMState *destinationStateC;
        __block TBSMState *sourceStateD;
        __block TBSMState *destinationStateD;
        
        stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            sourceStateC = sourceState;
        };
        
        stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            destinationStateC = destinationState;
        };
        
        stateD.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            sourceStateD = sourceState;
        };
        
        stateD.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            destinationStateD = destinationState;
        };
        
        NSArray *subStatesA = @[stateC, stateD];
        subStateMachineA.states = subStatesA;
        subStateMachineA.initialState = stateC;
        
        // setup sub-machine B
        __block TBSMState *sourceStateE;
        __block TBSMState *destinationStateE;
        __block TBSMState *sourceStateF;
        __block TBSMState *destinationStateF;
        
        stateE.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            sourceStateE = sourceState;
        };
        
        stateE.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            destinationStateE = destinationState;
        };
        
        stateF.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            sourceStateF = sourceState;
        };
        
        stateF.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            destinationStateF = destinationState;
        };
        
        NSArray *subStatesB = @[stateE, stateF];
        subStateMachineB.states = subStatesB;
        subStateMachineB.initialState = stateE;
        
        // setup parallel wrapper
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
        parallelStates.states = parallelSubStateMachines;
        
        // setup main state machine
        __block id<TBSMNode> sourceStateA;
        __block NSDictionary *sourceStateDataA;
        __block TBSMState *destinationStateA;
        __block TBSMState *sourceStateB;
        __block id<TBSMNode> destinationStateB;
        
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            sourceStateA = sourceState;
            sourceStateDataA = data;
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            destinationStateA = destinationState;
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            sourceStateB = sourceState;
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
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
        expect(destinationStateD).to.equal(stateA);
        expect(destinationStateF).to.equal(stateA);
        expect(sourceStateA).to.equal(stateF);
        expect(sourceStateDataA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
    });
    
});

SpecEnd
