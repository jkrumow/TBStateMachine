//
//  InheritedStatesTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 22.01.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import "TBSMStateMachine+TestHelper.h"

#import "StateA.h"
#import "StateB.h"
#import "SubA.h"
#import "ParallelA.h"

SpecBegin(InheritedStates)

NSString * const EVENT_A1 = @"event_a1";
NSString * const EVENT_A2 = @"event_a2";
NSString * const EVENT_B2 = @"event_b2";

__block TBSMStateMachine *stateMachine;

__block SubA *a;
__block StateA *a1;
__block StateA *a2;

__block ParallelA *b;
__block StateA *b1;
__block StateB *b2;

__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;

__block NSMutableArray *executionSequence;

describe(@"InheritedStates", ^{
    
    beforeEach(^{
        
        executionSequence = [NSMutableArray new];
        
        stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        
        a = [[SubA alloc] initWithName:@"a"];
        a1 = [[StateA alloc] initWithName:@"a1"];
        a2 = [[StateA alloc] initWithName:@"a2"];
        
        b = [[ParallelA alloc] initWithName:@"b"];
        b1 = [[StateA alloc] initWithName:@"b1"];
        b2 = [[StateB alloc] initWithName:@"b2"];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"smA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"smB"];
        
        a.executionSequence = executionSequence;
        a1.executionSequence = executionSequence;
        a2.executionSequence = executionSequence;
        
        b.executionSequence = executionSequence;
        b1.executionSequence = executionSequence;
        b2.executionSequence = executionSequence;
        
        [a1 addHandlerForEvent:EVENT_A1 target:a2];
        [a2 addHandlerForEvent:EVENT_A2 target:b2];
        
        [b2 addHandlerForEvent:EVENT_B2 target:a1];
        
        subStateMachineA.states = @[a1, a2];
        subStateMachineB.states = @[b1, b2];
        
        a.stateMachine = subStateMachineA;
        b.stateMachines = @[subStateMachineB];
        
        stateMachine.states = @[a, b];
        [stateMachine setUp:nil];
        
        [executionSequence removeAllObjects];
    });
    
    afterEach(^{
        
        [stateMachine tearDown:nil];
        stateMachine = nil;
        
        a = nil;
        a1 = nil;
        a2 = nil;
        b = nil;
        b1 = nil;
        b2 = nil;
        
        subStateMachineA = nil;
        subStateMachineB = nil;
    });
    
    it(@"can deeply switch into and out of sub-state and parallel machines using least common ancestor algorithm while scheduling events from within the state.", ^{
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a2_enter",
                                               @"a2_exit",
                                               @"a_exit",
                                               @"b_enter",
                                               @"b2_enter",
                                               @"b2_exit",
                                               @"b_exit",
                                               @"a_enter",
                                               @"a1_enter"];
        
        waitUntil(^(DoneCallback done) {
            
            a1.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                done();
            };
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A1 data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A2 data:nil]];
        });
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
});

SpecEnd
