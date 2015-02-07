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
NSString * const EVENT_NAME_D = @"DummyEventD";
NSString * const EVENT_NAME_E = @"DummyEventE";
NSString * const EVENT_NAME_F = @"DummyEventF";
NSString * const EVENT_NAME_INTERNAL = @"DummyEventInternal";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;
__block TBSMState *stateA;
__block TBSMState *stateB;
__block TBSMState *stateC;
__block TBSMState *stateD;
__block TBSMState *stateE;
__block TBSMState *stateF;

__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMStateMachine *subStateMachineC;
__block TBSMStateMachine *subStateMachineD;
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
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"SubA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"SubB"];
        subStateMachineC = [TBSMStateMachine stateMachineWithName:@"SubC"];
        subStateMachineD = [TBSMStateMachine stateMachineWithName:@"SubD"];
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
        stateF = nil;
        
        eventDataA = nil;
        eventDataB = nil;
 
        [subStateMachineA tearDown:nil];
        [subStateMachineB tearDown:nil];
        subStateMachineA = nil;
        subStateMachineB = nil;
        subStateMachineC = nil;
        subStateMachineD = nil;
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
        stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_enter"];
        };
        
        stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_exit"];
        };
        
        stateD.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_enter"];
        };
        
        stateD.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_exit"];
        };
        
        [stateC registerEvent:EVENT_NAME_A target:stateD];
        [stateD registerEvent:EVENT_NAME_A target:stateA];
        
        subStateMachineA.states = @[stateC, stateD];
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        // setup main state machine
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        [stateA registerEvent:EVENT_NAME_A target:stateB];
        [stateB registerEvent:EVENT_NAME_A target:subStateA];
        
        stateMachine.states = @[stateA, stateB, subStateA];
        [stateMachine setUp:nil];
        
        // moves to state B
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // moves to sub machine A which enters C
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // moves to state D
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // will go back to start
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // handled by state A
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"can deeply switch into and out of sub-state machines using least common ancestor algorithm.", ^{
        
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
        
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        [stateA registerEvent:EVENT_NAME_A target:stateB];
        [stateB registerEvent:EVENT_NAME_A target:stateD];
        
        subStateMachineA.states = @[stateA, stateB];
        
        stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_enter"];
        };
        
        stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_exit"];
        };
        
        stateD.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_enter"];
        };
        
        stateD.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_exit"];
        };
        
        [stateC registerEvent:EVENT_NAME_A target:stateD];
        [stateD registerEvent:EVENT_NAME_A target:stateA];
        
        subStateMachineB.states = @[stateC, stateD];
        
        // setup parallel wrapper
        parallelStates.stateMachines = @[subStateMachineB];
        
        // setup sub state machine wrapper
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        // setup main state machine
        stateMachine.states = @[subStateA, parallelStates];
        [stateMachine setUp:nil];
        
        // moves to state B
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // moves to state D
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // will go back to start
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // handled by state A
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"throws an exception if the destination state was not found using least common ancestor algorithm.", ^{
        
        [stateA registerEvent:EVENT_NAME_A target:stateF];
        
        // setup sub state machine wrapper
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"SubStateB"];

        subStateMachineA.states = @[stateA];
        subStateMachineB.states = @[stateB];
        
        subStateA.stateMachine = subStateMachineA;
        subStateB.stateMachine = subStateMachineB;
        
        stateMachine.states = @[subStateA, subStateB];
        [stateMachine setUp:nil];
        
        expect(^{
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        }).to.raise(TBSMException);
    });
    
    it(@"can switch into and out of parallel state machines.", ^{
        
        subStateMachineA.states = @[stateC, stateD];
        subStateMachineB.states = @[stateE, stateF];
        
        // setup parallel wrapper
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
        parallelStates.stateMachines = parallelSubStateMachines;
        
        // setup main state machine
        [stateA registerEvent:EVENT_NAME_A target:stateB];
        [stateB registerEvent:EVENT_NAME_A target:stateC];
        [stateC registerEvent:EVENT_NAME_A target:stateD];
        [stateD registerEvent:EVENT_NAME_A target:nil kind:TBSMTransitionInternal];
        [stateE registerEvent:EVENT_NAME_A target:stateF];
        [stateF registerEvent:EVENT_NAME_A target:stateA];
        
        stateMachine.states = @[stateA, stateB, parallelStates];
        [stateMachine setUp:nil];
        
        // moves to state B
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        expect(stateMachine.currentState).to.equal(stateB);
        
        // moves to stateC inside parallel state wrapper
        // enters state C in subStateMachine A
        // enters state E in subStateMachine B
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        expect(stateMachine.currentState).to.equal(parallelStates);
        expect(subStateMachineA.currentState).to.equal(stateC);
        expect(subStateMachineB.currentState).to.equal(stateE);
        
        // moves subStateMachine A from C to state D
        // moves subStateMachine B from E to state F
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        expect(stateMachine.currentState).to.equal(parallelStates);
        expect(subStateMachineA.currentState).to.equal(stateD);
        expect(subStateMachineB.currentState).to.equal(stateF);
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // moves back to state A
        expect(stateMachine.currentState).to.equal(stateA);
    });
    
    it(@"can deeply switch into and out of sub-state and parallel machines using least common ancestor algorithm while performing internal transitions.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter",
                                               @"stateB_exit",
                                               @"subStateA_exit",
                                               @"stateD_enter",
                                               @"stateD_guard_internal",
                                               @"stateD_action_internal",
                                               @"stateD_guard_internal",
                                               @"stateD_exit",
                                               @"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        [stateA registerEvent:EVENT_NAME_A target:stateB];
        [stateB registerEvent:EVENT_NAME_A target:stateD];
        
        subStateMachineA.states = @[stateA, stateB];
        
        // setup sub-state machine B
        __block NSUInteger guardCount = 0;
        
        stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_enter"];
        };
        
        stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateC_exit"];
        };
        
        stateD.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_enter"];
        };
        
        stateD.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_exit"];
        };
        
        [stateC registerEvent:EVENT_NAME_A target:stateD];
        [stateD registerEvent:EVENT_NAME_A target:stateA];
        
        [stateD registerEvent:EVENT_NAME_INTERNAL
                       target:nil
                         kind:TBSMTransitionInternal
                       action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           [executionSequence addObject:@"stateD_action_internal"];
                       } guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           [executionSequence addObject:@"stateD_guard_internal"];
                           guardCount++;
                           return (guardCount == 1);
                       }];
        
        subStateMachineB.states = @[stateC, stateD];
        
        // setup parallel wrapper
        parallelStates.stateMachines = @[subStateMachineB];
        
        // setup sub state machine wrapper
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        // setup main state machine
        stateMachine.states = @[subStateA, parallelStates];
        [stateMachine setUp:nil];
        
        // moves to state B
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // moves to state D
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // perform internal transition on state D
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_INTERNAL data:nil]];
        
        // attempt to perform internal transition on state D blocked by guard
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_INTERNAL data:nil]];
        
        // will go back to start
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // handled by state A
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"performs internal transitions on all registered states", ^{
        
        __block BOOL actionStateA = NO;
        __block BOOL actionStateB = NO;
        __block BOOL actionStateC = NO;
        __block BOOL actionStateD = NO;
        
        subStateMachineA.states = @[stateA];
        
        subStateMachineB.states = @[stateB];
        
        subStateMachineC.states = @[stateC];
        
        subStateMachineD.states = @[stateD];
        
        [stateA registerEvent:EVENT_NAME_INTERNAL
                       target:nil
                         kind:TBSMTransitionInternal
                       action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           actionStateA = YES;
                       }];
        
        [stateB registerEvent:EVENT_NAME_INTERNAL
                       target:nil
                         kind:TBSMTransitionInternal
                       action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           actionStateB = YES;
                       }];
        
        [stateC registerEvent:EVENT_NAME_INTERNAL
                       target:nil
                         kind:TBSMTransitionInternal
                       action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           actionStateC = YES;
                       }];
        
        [stateD registerEvent:EVENT_NAME_INTERNAL
                       target:nil
                         kind:TBSMTransitionInternal
                       action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           actionStateD = YES;
                       }];
        
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB, subStateMachineC, subStateMachineD];
        parallelStates.stateMachines = parallelSubStateMachines;
        
        stateMachine.states = @[parallelStates];
        [stateMachine setUp:nil];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_INTERNAL data:nil]];
        
        expect(actionStateA).to.equal(YES);
        expect(actionStateB).to.equal(YES);
        expect(actionStateC).to.equal(YES);
        expect(actionStateD).to.equal(YES);
    });
    
    it(@"defers events until a sub state has been reached which can consume the event.", ^{
        
        // setup sub state machine wrapper A
        subStateMachineA.states = @[stateA, stateB, stateC];
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        [subStateA deferEvent:EVENT_NAME_B];
        [stateA registerEvent:EVENT_NAME_A target:stateB];
        [stateA deferEvent:EVENT_NAME_B];
        [stateB registerEvent:EVENT_NAME_B target:stateC];
        [stateC deferEvent:EVENT_NAME_C];
        [stateC registerEvent:EVENT_NAME_D target:stateD];
        
        // setup sub state machine wrapper B
        subStateMachineB.states = @[stateD, stateE, stateF];
        
        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"SubStateB"];
        subStateB.stateMachine = subStateMachineB;
        
        [subStateB deferEvent:EVENT_NAME_C];
        [subStateB deferEvent:EVENT_NAME_E];
        [stateD registerEvent:EVENT_NAME_C target:stateE];
        [stateE deferEvent:EVENT_NAME_E];
        
        // setup main state machine
        stateMachine.states = @[subStateA, subStateB];
        [stateMachine setUp:nil];
        
        // event should be deferred by stateA
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_B data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateA);
        expect(subStateA.stateMachine.currentState).to.equal(stateA);
        
        // should switch from stateA to stateB --> handle eventB --> switch to stateC
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateA);
        expect(subStateA.stateMachine.currentState).to.equal(stateC);
        
        // should be deferred by stateC
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_C data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateA);
        expect(subStateA.stateMachine.currentState).to.equal(stateC);
        
        // should switch from stateC to stateD --> handle eventC --> switch to stateE
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_D data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateB);
        expect(subStateB.stateMachine.currentState).to.equal(stateE);
        
        // should be deferred by stateE
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_E data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateB);
        expect(subStateB.stateMachine.currentState).to.equal(stateE);
        
        // should be deferred by subStateB
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_C data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateB);
        expect(subStateB.stateMachine.currentState).to.equal(stateE);
    });
    
    it(@"defers events until a parallel state has been reached which can consume the event.", ^{
        
        // setup sub state machine wrapper A
        subStateMachineA.states = @[stateA, stateB];
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        [subStateA deferEvent:EVENT_NAME_B];
        [stateA registerEvent:EVENT_NAME_A target:stateB];
        [stateA deferEvent:EVENT_NAME_B];
        [stateB registerEvent:EVENT_NAME_B target:stateC];
        
        // setup sub state machine wrapper B
        subStateMachineB.states = @[stateC, stateD];
        
        // setup sub state machine wrapper C
        subStateMachineC.states = @[stateE, stateF];
        
        parallelStates.stateMachines = @[subStateMachineB, subStateMachineC];
        [parallelStates deferEvent:EVENT_NAME_C];
        [parallelStates deferEvent:EVENT_NAME_F];
        [stateC deferEvent:EVENT_NAME_C];
        [stateC registerEvent:EVENT_NAME_D target:stateD];
        [stateD registerEvent:EVENT_NAME_C target:stateC];
        [stateE deferEvent:EVENT_NAME_C];
        [stateE deferEvent:EVENT_NAME_D];
        [stateE registerEvent:EVENT_NAME_E target:stateA];
        [stateF registerEvent:EVENT_NAME_C target:stateE];
        
        // setup main state machine
        stateMachine.states = @[subStateA, parallelStates];
        [stateMachine setUp:nil];
        
        // event should be deferred by stateA
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_B data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateA);
        expect(subStateA.stateMachine.currentState).to.equal(stateA);
        
        // should switch from stateA to stateB --> handle eventB --> switch to stateC (and enter stateE)
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        expect(stateMachine.currentState).to.equal(parallelStates);
        expect([parallelStates.stateMachines[0] currentState]).to.equal(stateC);
        expect([parallelStates.stateMachines[1] currentState]).to.equal(stateE);
        
        // should be deferred by parallelStates, stateC and stateE
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_C data:nil]];
        
        expect(stateMachine.currentState).to.equal(parallelStates);
        expect([parallelStates.stateMachines[0] currentState]).to.equal(stateC);
        expect([parallelStates.stateMachines[1] currentState]).to.equal(stateE);
        
        // should switch from stateC to stateD --> handle eventC --> switch from stateD to stateC
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_D data:nil]];
        
        expect(stateMachine.currentState).to.equal(parallelStates);
        expect([parallelStates.stateMachines[0] currentState]).to.equal(stateC);
        expect([parallelStates.stateMachines[1] currentState]).to.equal(stateE);
        
        // should be deferred by parallelStates
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_F data:nil]];
        
        expect(stateMachine.currentState).to.equal(parallelStates);
        expect([parallelStates.stateMachines[0] currentState]).to.equal(stateC);
        expect([parallelStates.stateMachines[1] currentState]).to.equal(stateE);
        
        // should switch to subStateA - stateA
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_E data:nil]];
        
        expect(stateMachine.currentState).to.equal(subStateA);
        expect(subStateA.stateMachine.currentState).to.equal(stateA);
    });
    
    it(@"performs an external transition from superstate to substate.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"subStateA_exit",
                                               @"subStateA_enter",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        subStateMachineA.states = @[stateA, stateB];
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        [subStateA registerEvent:EVENT_NAME_A target:stateB];
        
        
        // setup main state machine
        stateMachine.states = @[subStateA];
        [stateMachine setUp:nil];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"performs an external transition from substate to superstate.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"subStateA_exit",
                                               @"subStateA_enter",
                                               @"stateA_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        subStateMachineA.states = @[stateA, stateB];
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        [stateA registerEvent:EVENT_NAME_A target:subStateA];
        
        // setup main state machine
        stateMachine.states = @[subStateA];
        [stateMachine setUp:nil];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"performs a local transition from superstate to substate.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        subStateMachineA.states = @[stateA, stateB];
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        [subStateA registerEvent:EVENT_NAME_A target:stateB kind:TBSMTransitionLocal];
        
        
        // setup main state machine
        stateMachine.states = @[subStateA];
        [stateMachine setUp:nil];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"performs a deep local transition from superstate to substate.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"subStateB_enter",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"SubStateB"];
        subStateB.stateMachine = subStateMachineB;
        
        
        subStateMachineA.states = @[stateA, subStateB];
        subStateMachineB.states = @[stateB];
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        subStateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateB_enter"];
        };
        
        subStateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateB_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        [subStateA registerEvent:EVENT_NAME_A target:stateB kind:TBSMTransitionLocal];
        
        
        // setup main state machine
        stateMachine.states = @[subStateA];
        [stateMachine setUp:nil];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
    
    it(@"performs a deep local transition from substate to spuerstate.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"subStateB_enter",
                                               @"stateB_enter",
                                               @"stateB_exit",
                                               @"subStateB_exit",
                                               @"subStateB_enter",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        // setup sub-state machine A
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_enter"];
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateA_exit"];
        };
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"SubStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"SubStateB"];
        subStateB.stateMachine = subStateMachineB;
        
        
        subStateMachineA.states = @[subStateB, stateA];
        subStateMachineB.states = @[stateB];
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_enter"];
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateA_exit"];
        };
        
        subStateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateB_enter"];
        };
        
        subStateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"subStateB_exit"];
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_enter"];
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            [executionSequence addObject:@"stateB_exit"];
        };
        
        [stateB registerEvent:EVENT_NAME_A target:subStateA kind:TBSMTransitionLocal];
        
        
        // setup main state machine
        stateMachine.states = @[subStateA];
        [stateMachine setUp:nil];
        
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
});

SpecEnd
