//
//  TBSMStateMachineNestedTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 18.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMStateMachineNested)

NSString * const TRANSITION_1 = @"transition_1";
NSString * const TRANSITION_2 = @"transition_2";
NSString * const TRANSITION_3 = @"transition_3";
NSString * const TRANSITION_4 = @"transition_4";
NSString * const TRANSITION_5 = @"transition_5";
NSString * const TRANSITION_6 = @"transition_6";
NSString * const TRANSITION_7 = @"transition_7";
NSString * const TRANSITION_8 = @"transition_8";
NSString * const TRANSITION_9 = @"transition_9";
NSString * const TRANSITION_10 = @"transition_10";
NSString * const TRANSITION_11 = @"transition_11";
NSString * const TRANSITION_BROKEN = @"transition_broken";

NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;

__block TBSMSubState *a;
__block TBSMState *a1;
__block TBSMState *a2;
__block TBSMState *a3;

__block TBSMSubState *b;
__block TBSMState *b1;

__block TBSMSubState *b2;
__block TBSMState *b21;
__block TBSMState *b22;

__block TBSMParallelState *b3;
__block TBSMState *b31;
__block TBSMState *b32;

__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMStateMachine *subStateMachineB2;
__block TBSMStateMachine *subStateMachineB31;
__block TBSMStateMachine *subStateMachineB32;

__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;

__block NSMutableArray *executionSequence;


describe(@"TBSMStateMachine", ^{
    
    beforeEach(^{
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        
        stateMachine = [TBSMStateMachine stateMachineWithName:@"StateMachine"];
        a = [TBSMSubState subStateWithName:@"a"];
        
        a1 = [TBSMState stateWithName:@"a1"];
        a2 = [TBSMState stateWithName:@"a2"];
        a3 = [TBSMState stateWithName:@"a3"];
        
        b = [TBSMSubState subStateWithName:@"b"];
        b1 = [TBSMState stateWithName:@"b1"];
        
        b2 = [TBSMSubState subStateWithName:@"b2"];
        b21 = [TBSMState stateWithName:@"b21"];
        b22 = [TBSMState stateWithName:@"b22"];
        
        
        b3 = [TBSMParallelState parallelStateWithName:@"b3"];
        b31 = [TBSMState stateWithName:@"b31"];
        b32 = [TBSMState stateWithName:@"b31"];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"smA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"smB"];
        subStateMachineB2 = [TBSMStateMachine stateMachineWithName:@"smB2"];
        
        subStateMachineB31 = [TBSMStateMachine stateMachineWithName:@"smB31"];
        subStateMachineB32 = [TBSMStateMachine stateMachineWithName:@"smB32"];
        
        a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a_enter"];
        };
        
        a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a_exit"];
        };
        
        a1.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a1_enter"];
        };
        
        a1.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a1_exit"];
        };
        
        a2.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a2_enter"];
        };
        
        a2.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a2_exit"];
        };
        
        a3.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a3_enter"];
        };
        
        a3.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a3_exit"];
        };
        
        b.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b_enter"];
        };
        
        b.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b_exit"];
        };
        
        b1.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b1_enter"];
        };
        
        b1.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b1_exit"];
        };
        
        b2.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b2_enter"];
        };
        
        b2.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b2_exit"];
        };
        
        b21.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b21_enter"];
        };
        
        b21.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b21_exit"];
        };
        
        b22.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b22_enter"];
        };
        
        b22.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b22_exit"];
        };

        b3.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b3_enter"];
        };
        
        b3.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b3_exit"];
        };

        b31.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b31_enter"];
        };
        
        b31.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b31_exit"];
        };
        
        b32.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b32_enter"];
        };
        
        b32.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"b32_exit"];
        };
        
        // superstates / substates guards
        [a registerEvent:TRANSITION_1 target:b];
        [a1 registerEvent:TRANSITION_1 target:a2 kind:TBSMTransitionExternal action:nil guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            return (data && data[EVENT_DATA_KEY] == EVENT_DATA_VALUE);
        }];
        [a1 registerEvent:TRANSITION_1 target:a3 kind:TBSMTransitionExternal action:nil guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            return (data && data[EVENT_DATA_KEY] != EVENT_DATA_VALUE);
        }];
        
        // run to completion test / queuing
        [a2 registerEvent:TRANSITION_2 target:a3 kind:TBSMTransitionExternal action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"a2_action"];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_3 data:nil]];
        }];
        [a3 registerEvent:TRANSITION_3 target:a1];
        
        // lca
        [a3 registerEvent:TRANSITION_4 target:b2];
        [a3 registerEvent:TRANSITION_5 target:b22];
        
        // external transitions
        [a registerEvent:TRANSITION_6 target:a2];
        [a2 registerEvent:TRANSITION_7 target:a];
        
        // local transitions
        [b registerEvent:TRANSITION_8 target:b22 kind:TBSMTransitionLocal];
        [b22 registerEvent:TRANSITION_9 target:b kind:TBSMTransitionLocal];
        
        [b registerEvent:TRANSITION_BROKEN target:a3 kind:TBSMTransitionLocal];
        
        // parallel state with default setup
        [b registerEvent:TRANSITION_10 target:b3];
        
        // parallel state with deep switching
        [a3 registerEvent:TRANSITION_11 target:b32];
        
        subStateMachineB2.states = @[b21, b22];
        subStateMachineB31.states = @[b31];
        subStateMachineB32.states = @[b32];
        
        a.stateMachine = subStateMachineA;
        b.stateMachine = subStateMachineB;
        b2.stateMachine = subStateMachineB2;
        b3.stateMachines = @[subStateMachineB31, subStateMachineB32];

        subStateMachineA.states = @[a1, a2, a3];
        subStateMachineB.states = @[b1, b2, b3];

        stateMachine.states = @[a, b];
        [stateMachine setUp:nil];
        
        executionSequence = [NSMutableArray new];
    });
    
    afterEach(^{
        
        [stateMachine tearDown:nil];
        stateMachine = nil;
        
        a = nil;
        a1 = nil;
        a2 = nil;
        a3 = nil;
        
        b = nil;
        b1 = nil;
        
        b2 = nil;
        b21 = nil;
        b22 = nil;
        
        subStateMachineA = nil;
        subStateMachineB = nil;
        subStateMachineB2 = nil;
        
        eventDataA = nil;
        eventDataB = nil;
        
        executionSequence = nil;
    });
    
    
    it(@"evalutes the guards and chooses the transition defined on super state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:nil]];
        
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a_exit",
                                               @"b_enter",
                                               @"b1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"evalutes the guards and chooses the first transition defined on sub state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:EVENT_DATA_VALUE}]];
        
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a2_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"evalutes the guards and chooses the second transition defined on sub state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:@(1)}]];
        
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a3_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"handles events which are scheduled in the middle of a transition considering the run to completion model.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:EVENT_DATA_VALUE}]];
        [executionSequence removeAllObjects];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_2 data:nil]];
        
        
        NSArray *expectedExecutionSequence = @[@"a2_exit",
                                               @"a2_action",
                                               @"a3_enter",
                                               @"a3_exit",
                                               @"a1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    
    it(@"switches deep from and into a sub state which enters initial state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:@(1)}]];
        [executionSequence removeAllObjects];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_4 data:nil]];
        
        NSArray *expectedExecutionSequence = @[@"a3_exit",
                                               @"a_exit",
                                               @"b_enter",
                                               @"b2_enter",
                                               @"b21_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"switches even deeper from and into a specified sub state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:@(1)}]];
        [executionSequence removeAllObjects];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_5 data:nil]];
        
        NSArray *expectedExecutionSequence = @[@"a3_exit",
                                               @"a_exit",
                                               @"b_enter",
                                               @"b2_enter",
                                               @"b22_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs an external transition from containing source state to contained target state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_6 data:nil]];
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a_exit",
                                               @"a_enter",
                                               @"a2_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs an external transition from contained source state to containing target state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:EVENT_DATA_VALUE}]];
        [executionSequence removeAllObjects];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_7 data:nil]];
        
        NSArray *expectedExecutionSequence = @[@"a2_exit",
                                               @"a_exit",
                                               @"a_enter",
                                               @"a1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs a local transition from containing source state to contained target state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:nil]];
        [executionSequence removeAllObjects];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_8 data:nil]];
        
        NSArray *expectedExecutionSequence = @[@"b1_exit",
                                               @"b2_enter",
                                               @"b22_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs a local transition from contained source state to containing target state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:@(1)}]];
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_5 data:nil]];
        [executionSequence removeAllObjects];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_9 data:nil]];
        
        NSArray *expectedExecutionSequence = @[@"b22_exit",
                                               @"b2_exit",
                                               @"b1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs a transition into a parrel state and enters default sub states.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:nil]];
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_10 data:nil]];
        
        expect(stateMachine.currentState).to.equal(b);
        expect(subStateMachineB.currentState).to.equal(b3);
        expect(subStateMachineB31.currentState).to.equal(b31);
        expect(subStateMachineB32.currentState).to.equal(b32);
    });
    
    it(@"performs a transition into a parrel state and enters specified sub state while entering all other parallel machines with default state.", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:@(1)}]];
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_11 data:nil]];
        
        expect(stateMachine.currentState).to.equal(b);
        expect(subStateMachineB.currentState).to.equal(b3);
        expect(subStateMachineB31.currentState).to.equal(b31);
        expect(subStateMachineB32.currentState).to.equal(b32);
    });
    
    it(@"throws an exception when no lca could be found", ^{
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_1 data:@{EVENT_DATA_KEY:@(1)}]];
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_5 data:nil]];
        [executionSequence removeAllObjects];
        
        expect(^{
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:TRANSITION_BROKEN data:nil]];
        }).to.raise(TBSMException);
        
    });
});

SpecEnd
