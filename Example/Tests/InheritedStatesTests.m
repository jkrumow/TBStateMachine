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

__block TBSMStateMachine *stateMachine;
__block StateA *stateA;
__block StateA *stateB;
__block StateA *stateC;
__block StateB *stateD;

__block ParallelA *parallelStates;

__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;

describe(@"InheritedStates", ^{
    
    beforeEach(^{
        stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        stateA = [[StateA alloc] initWithName:@"stateA"];
        stateB = [[StateA alloc] initWithName:@"stateB"];
        stateC = [[StateA alloc] initWithName:@"stateC"];
        stateD = [[StateB alloc] initWithName:@"stateD"];
        parallelStates = [[ParallelA alloc] initWithName:@"parallelStates"];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"subMachineA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"subMachineB"];
    });
    
    afterEach(^{
        
        [stateMachine tearDown:nil];
        stateMachine = nil;
        
        stateA = nil;
        stateB = nil;
        stateC = nil;
        stateD = nil;
        parallelStates = nil;
        
        [subStateMachineA tearDown:nil];
        [subStateMachineB tearDown:nil];
        subStateMachineA = nil;
        subStateMachineB = nil;
    });
    
    it(@"can deeply switch into and out of sub-state and parallel machines using least common ancestor algorithm while scheduling events from within the state.", ^{
        
        NSArray *expectedExecutionSequence = @[@"subStateA_enter",
                                               @"stateA_enter",
                                               @"stateA_exit",
                                               @"stateB_enter",
                                               @"stateB_exit",
                                               @"subStateA_exit",
                                               @"parallelStates_enter",
                                               @"stateD_enter",
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
        
        [stateA registerEvent:EVENT_NAME_A target:stateB];
        [stateB registerEvent:EVENT_NAME_A target:stateD];
        [stateD registerEvent:EVENT_NAME_B target:stateA];
        
        NSArray *subStatesA = @[stateA, stateB];
        subStateMachineA.states = subStatesA;
        subStateMachineA.initialState = stateA;
        
        // setup sub-state machine B
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
        [stateMachine setUp:nil];
        
        // moves to state B
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // moves to state D
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        // will internally schedule eventA
        
        // handled by state A
        [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        
        NSString *expectedExecutionSequenceString = [expectedExecutionSequence componentsJoinedByString:@"-"];
        NSString *executionSequenceString = [executionSequence componentsJoinedByString:@"-"];
        expect(executionSequenceString).to.equal(expectedExecutionSequenceString);
    });
});

SpecEnd
