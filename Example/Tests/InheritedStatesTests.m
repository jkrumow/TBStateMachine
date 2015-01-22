//
//  InheritedStatesTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 22.01.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

#import "StateA.h"
#import "StateB.h"
#import "SubA.h"
#import "ParallelA.h"

SpecBegin(InheritedStates)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_NAME_B = @"DummyEventB";
NSString * const EVENT_NAME_C = @"DummyEventC";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;
__block StateA *stateA;
__block StateB *stateB;
__block StateA *stateC;
__block StateB *stateD;

__block ParallelA *parallelStates;

__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;

__block TBSMEvent *eventA;
__block TBSMEvent *eventB;
__block TBSMEvent *eventC;
__block TBSMEvent *eventInternal;

__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;


describe(@"InheritedStates", ^{
    
    beforeEach(^{
        stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        stateA = [[StateA alloc] initWithName:@"stateA"];
        stateB = [[StateB alloc] initWithName:@"stateB"];
        stateC = [[StateA alloc] initWithName:@"stateC"];
        stateD = [[StateB alloc] initWithName:@"stateD"];
        parallelStates = [[ParallelA alloc] initWithName:@"parallelStates"];
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBSMEvent eventWithName:EVENT_NAME_A data:nil];
        eventB = [TBSMEvent eventWithName:EVENT_NAME_B data:nil];
        eventC = [TBSMEvent eventWithName:EVENT_NAME_C data:nil];
        eventInternal = [TBSMEvent eventWithName:@"eventInternal" data:nil];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"subMachineA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"subMachineB"];
    });
    
    afterEach(^{
        
        [stateMachine tearDown];
        stateMachine = nil;
        
        stateA = nil;
        stateB = nil;
        stateC = nil;
        stateD = nil;
        parallelStates = nil;
        
        eventDataA = nil;
        eventDataB = nil;
        eventA = nil;
        eventB = nil;
        eventC = nil;
        
        [subStateMachineA tearDown];
        [subStateMachineB tearDown];
        subStateMachineA = nil;
        subStateMachineB = nil;
    });
    
    it(@"can deeply switch into and out of sub-state and parallel machines using lowest common ancestor algorithm while performing internal transitions.", ^{
        
        __block NSUInteger guardCount = 0;
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter",
                                               @"stateB_exit",
                                               @"subStateA_exit",
                                               @"parallelStates_enter",
                                               @"stateD_enter",
                                               @"stateD_guard_internal",
                                               @"stateD_action_internal",
                                               @"stateD_guard_internal",
                                               @"stateD_exit",
                                               @"parallelStates_exit",
                                               @"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter"];
        
        NSMutableArray *executionSequence = [NSMutableArray new];
        
        stateA.executionSequence = executionSequence;
        stateB.executionSequence = executionSequence;
        stateC.executionSequence = executionSequence;
        stateD.executionSequence = executionSequence;
        
        parallelStates.executionSequence = executionSequence;
        
        // setup sub-state machine A
        
        [stateA registerEvent:eventA.name target:stateB];
        [stateB registerEvent:eventA.name target:stateD];
        
        NSArray *subStatesA = @[stateA, stateB];
        subStateMachineA.states = subStatesA;
        subStateMachineA.initialState = stateA;
        
        // setup sub-state machine B
        
        [stateC registerEvent:eventA.name target:stateD];
        [stateD registerEvent:eventA.name target:stateA];
        
        [stateD registerEvent:eventInternal.name target:nil action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_action_internal"];
        } guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
            [executionSequence addObject:@"stateD_guard_internal"];
            guardCount++;
            return (guardCount == 1);
        }];
        
        NSArray *subStatesB = @[stateC, stateD];
        subStateMachineB.states = subStatesB;
        subStateMachineB.initialState = stateC;
        
        // setup parallel wrapper
        parallelStates.stateMachines = @[subStateMachineB];
        
        // setup sub state machine wrapper
        SubA *subStateA = [[SubA alloc] initWithName:@"subStateA" stateMachine:subStateMachineA];
        subStateA.executionSequence = executionSequence;
        
        // setup main state machine
        NSArray *states = @[subStateA, parallelStates];
        stateMachine.states = states;
        stateMachine.initialState = subStateA;
        
        // enters state A
        [stateMachine setUp];
        
        // moves to state B
        [stateMachine scheduleEvent:eventA];
        
        // moves to state D
        [stateMachine scheduleEvent:eventA];
        
        // perform internal transition on state D
        [stateMachine scheduleEvent:eventInternal];
        
        // attempt to perform internal transition on state D blocked by guard
        [stateMachine scheduleEvent:eventInternal];
        
        // will go back to start
        eventA.data = eventDataA;
        [stateMachine scheduleEvent:eventA];
        
        // handled by state A
        [stateMachine scheduleEvent:eventA];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
});

SpecEnd
