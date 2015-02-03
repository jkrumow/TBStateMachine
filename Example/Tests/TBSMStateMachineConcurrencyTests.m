//
//  TBSMStateMachineConcurrencyTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 18.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMStateMachineConcurrency)

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

__block dispatch_queue_t parallelQueue;


describe(@"TBSMStateMachine", ^{
    
    beforeAll(^{
        parallelQueue = dispatch_queue_create("ParallelStateQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    afterAll(^{
#if !OS_OBJECT_USE_OBJC
        dispatch_release(parallelQueue);
        parallelQueue = nil;
#endif
    });
    
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
        eventA = [TBSMEvent eventWithName:EVENT_NAME_A data:nil];
        eventB = [TBSMEvent eventWithName:EVENT_NAME_B data:nil];
        eventC = [TBSMEvent eventWithName:EVENT_NAME_C data:nil];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"SubA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"SubB"];
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
        eventA = nil;
        eventB = nil;
        eventC = nil;
        
        [subStateMachineA tearDown:nil];
        [subStateMachineB tearDown:nil];
        subStateMachineA = nil;
        subStateMachineB = nil;
        parallelStates = nil;
    });
    
    describe(@"Concurrency", ^{
        
        it(@"queues up events if an event is being currently handled", ^{
            
            NSArray *expectedExecutionSequence = @[@"stateA_enter",
                                                   @"stateA_exit",
                                                   @"stateA_action",
                                                   @"stateB_enter",
                                                   @"stateB_exit",
                                                   @"stateB_action",
                                                   @"subStateC_enter",
                                                   @"stateC_enter",
                                                   @"stateC_exit",
                                                   @"subStateC_exit",
                                                   @"subStateC_action",
                                                   @"stateA_enter"];
            
            NSMutableArray *executionSequence = [NSMutableArray new];
            
            __block NSUInteger enteredCount = 0;
            __block NSUInteger guardExecutedCount = 0;
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_enter"];
                enteredCount++;
                [stateMachine scheduleEvent:eventA];
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_exit"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_enter"];
                [stateMachine scheduleEvent:eventC];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_exit"];
            };
            
            stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_enter"];
            };
            
            stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_exit"];
            };
            
            subStateMachineA.states = @[stateC];
            TBSMSubState *subStateC = [TBSMSubState subStateWithName:@"SubStateC" stateMachine:subStateMachineA];
            
            subStateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"subStateC_enter"];
                [stateMachine scheduleEvent:eventA];
            };
            
            subStateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"subStateC_exit"];
            };
            
            [stateA registerEvent:eventA.name
                           target:stateB
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               [executionSequence addObject:@"stateA_action"];
                               [stateMachine scheduleEvent:eventB];
                           } guard:^BOOL(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               guardExecutedCount++;
                               return (enteredCount == 1);
                           }];
            
            [stateB registerEvent:eventB.name
                           target:subStateC
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               [executionSequence addObject:@"stateB_action"];
                           }];
            
            [subStateC registerEvent:eventC.name
                              target:stateA
                                type:TBSMTransitionExternal
                              action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                  [executionSequence addObject:@"subStateC_action"];
                              }];
            
            
            NSArray *states = @[stateA, stateB, subStateC];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // enter A --> send eventA
            // switch to B with action --> send eventB (queued)
            // enter B --> send eventC (queued)
            
            // -------------------
            // stateB handles eventB
            // switch to subStateC with action
            
            // -------------------
            // subStateC handles eventC
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
                                                   @"subStateC_enter",
                                                   @"stateC_enter",
                                                   @"stateC_exit",
                                                   @"subStateC_exit",
                                                   @"subStateC_action",
                                                   @"stateD_enter",
                                                   @"stateD_exit",
                                                   @"stateD_action",
                                                   @"stateA_enter"];
            
            NSMutableArray *executionSequence = [NSMutableArray new];
            
            __block NSUInteger enteredCount = 0;
            stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_enter"];
                enteredCount++;
                
                // quit if we have finished the roundtrip and arrived back in stateA.
                if (enteredCount == 2) {
                    done();
                }
            };
            
            stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_exit"];
            };
            
            stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_enter"];
            };
            
            stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_exit"];
            };
            
            stateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_enter"];
            };
            
            stateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_exit"];
            };
            
            stateD.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_enter"];
            };
            
            stateD.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_exit"];
            };
            
            subStateMachineA.states = @[stateC];
            TBSMSubState *subStateC = [TBSMSubState subStateWithName:@"SubStateC" stateMachine:subStateMachineA];
            
            subStateC.enterBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"subStateC_enter"];
            };
            
            subStateC.exitBlock = ^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                [executionSequence addObject:@"subStateC_exit"];
            };
            
            [stateA registerEvent:eventA.name
                           target:stateB
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               [executionSequence addObject:@"stateA_action"];
                           }];
            
            [stateB registerEvent:eventA.name
                           target:stateC
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               [executionSequence addObject:@"stateB_action"];
                           }];
            
            [subStateC registerEvent:eventA.name
                              target:stateD
                                type:TBSMTransitionExternal
                              action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                                  [executionSequence addObject:@"subStateC_action"];
                              }];
            
            [stateD registerEvent:eventA.name
                           target:stateA
                             type:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *destinationState, NSDictionary *data) {
                               [executionSequence addObject:@"stateD_action"];
                           }];
            
            
            NSArray *states = @[stateA, stateB, subStateC, stateD];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // send all events concurrently.
            dispatch_apply(stateMachine.states.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t idx) {
                [stateMachine scheduleEvent:eventA];
            });
            
            expect(executionSequence).to.equal(expectedExecutionSequence);
        });
    });
    
    describe(@"Concurrency in parallel state wrapper", ^{
        
        it(@"should switch all parallel states concurrently.", ^{
            
            // setup sub-machine A
            NSArray *subStatesA = @[stateC, stateD];
            subStateMachineA.states = subStatesA;
            subStateMachineA.initialState = stateC;
            
            // setup sub-machine B
            NSArray *subStatesB = @[stateE, stateF];
            subStateMachineB.states = subStatesB;
            subStateMachineB.initialState = stateE;
            
            // setup parallel wrapper
            NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
            parallelStates.stateMachines = parallelSubStateMachines;
            parallelStates.parallelQueue = parallelQueue;
            
            // setup main state machine
            [stateA registerEvent:eventA.name target:stateC type:TBSMTransitionExternal];
            [stateC registerEvent:eventA.name target:stateD type:TBSMTransitionExternal];
            [stateD registerEvent:eventA.name target:nil type:TBSMTransitionInternal];
            [stateE registerEvent:eventA.name target:stateF type:TBSMTransitionExternal];
            [stateF registerEvent:eventA.name target:stateA type:TBSMTransitionExternal];
            
            NSArray *states = @[stateA, parallelStates];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp:nil];
            
            // moves to stateC inside parallel state wrapper
            // enters state C in subStateMachine A
            // enters state E in subStateMachine B
            [stateMachine scheduleEvent:eventA];
            
            expect(subStateMachineA.currentState).to.equal(stateC);
            expect(subStateMachineB.currentState).to.equal(stateE);
            
            // moves subStateMachine A from C to state D
            // moves subStateMachine B from E to state F
            [stateMachine scheduleEvent:eventA];
            
            expect(subStateMachineA.currentState).to.equal(stateD);
            expect(subStateMachineB.currentState).to.equal(stateF);
            
            eventA.data = eventDataA;
            [stateMachine scheduleEvent:eventA];
        });
        
    });
});

SpecEnd
