//
//  TBSMStateMachineNestedTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 18.09.14.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import <TBStateMachine/TBSMStateMachineBuilder.h>
#import <TBStateMachine/TBSMDebugger.h>

SpecBegin(TBSMStateMachineNested)

struct StateMachineEvents {
    __unsafe_unretained NSString *a_guard;
    __unsafe_unretained NSString *a2_a3;
    __unsafe_unretained NSString *a3_a1;
    __unsafe_unretained NSString *a3_b2;
    __unsafe_unretained NSString *a3_b22;
    __unsafe_unretained NSString *a_a2;
    __unsafe_unretained NSString *a2_a;
    __unsafe_unretained NSString *b_b22;
    __unsafe_unretained NSString *b22_b;
    __unsafe_unretained NSString *a1_internal;
    __unsafe_unretained NSString *b3xx_internal;
    __unsafe_unretained NSString *b311_a1;
    __unsafe_unretained NSString *b_b3;
    __unsafe_unretained NSString *a3_b322;
    __unsafe_unretained NSString *a_fork;
    __unsafe_unretained NSString *c212_join;
    __unsafe_unretained NSString *c222_join;
    __unsafe_unretained NSString *a_junction;
    __unsafe_unretained NSString *b_a3;
};

struct StateMachineEvents StateMachineEvents = {
    .a_guard = @"a_guard",
    .a2_a3 = @"a2_a3",
    .a3_a1 = @"a3_a1",
    .a3_b2 = @"a3_b2",
    .a3_b22 = @"a3_b22",
    .a_a2 = @"a_a2",
    .a2_a = @"a2_a",
    .b_b22 = @"b_b22",
    .b22_b = @"b22_b",
    .a1_internal = @"a1_internal",
    .b3xx_internal = @"b3xx_internal",
    .b311_a1 = @"b311_a1",
    .b_b3 = @"b_b3",
    .a3_b322 = @"a3_b322",
    .a_fork = @"a_fork",
    .c212_join = @"c212_join",
    .c222_join = @"c222_join",
    .a_junction = @"a_junction",
    .b_a3 = @"b_a3"
};

NSString * const event_data_key = @"DummyDataKey";
NSString * const event_data_value = @"DummyDataValue";

__block NSString * file;
__block TBSMStateMachine *stateMachine;

__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;

__block NSMutableArray *executionSequence;

describe(@"TBSMStateMachine", ^{
    
    beforeEach(^{
        
        eventDataA = @{event_data_key : event_data_value};
        eventDataB = @{event_data_key : event_data_value};
        
        file = [[NSBundle bundleForClass:[self class]] pathForResource:@"statemachine" ofType:@"json"];
        stateMachine = [TBSMStateMachineBuilder buildFromFile:file];
        
        TBSMState *a = [stateMachine stateWithPath:@"a"];
        TBSMState *a1 = [stateMachine stateWithPath:@"a/a1"];
        TBSMState *a2 = [stateMachine stateWithPath:@"a/a2"];
        TBSMState *a3 = [stateMachine stateWithPath:@"a/a3"];
        
        TBSMState *b = [stateMachine stateWithPath:@"b"];
        TBSMState *b1 = [stateMachine stateWithPath:@"b/b1"];
        TBSMState *b2 = [stateMachine stateWithPath:@"b/b2"];
        TBSMState *b21 = [stateMachine stateWithPath:@"b/b2/b21"];
        TBSMState *b22 = [stateMachine stateWithPath:@"b/b2/b22"];
        
        TBSMState *b3 = [stateMachine stateWithPath:@"b/b3"];
        TBSMState *b311 = [stateMachine stateWithPath:@"b/b3@0/b311"];
        TBSMState *b312 = [stateMachine stateWithPath:@"b/b3@0/b312"];
        TBSMState *b321 = [stateMachine stateWithPath:@"b/b3@1/b321"];
        TBSMState *b322 = [stateMachine stateWithPath:@"b/b3@1/b322"];
        
        TBSMState *c = [stateMachine stateWithPath:@"c"];
        TBSMState *c1 = [stateMachine stateWithPath:@"c/c1"];
        TBSMState *c2 = [stateMachine stateWithPath:@"c/c2"];
        TBSMState *c211 = [stateMachine stateWithPath:@"c/c2@0/c211"];
        TBSMState *c212 = [stateMachine stateWithPath:@"c/c2@0/c212"];
        TBSMState *c221 = [stateMachine stateWithPath:@"c/c2@1/c221"];
        TBSMState *c222 = [stateMachine stateWithPath:@"c/c2@1/c222"];
        
        a.enterBlock = ^(id data) {
            [executionSequence addObject:@"a_enter"];
        };
        
        a.exitBlock = ^(id data) {
            [executionSequence addObject:@"a_exit"];
        };
        
        a1.enterBlock = ^(id data) {
            [executionSequence addObject:@"a1_enter"];
        };
        
        a1.exitBlock = ^(id data) {
            [executionSequence addObject:@"a1_exit"];
        };
        
        a2.enterBlock = ^(id data) {
            [executionSequence addObject:@"a2_enter"];
        };
        
        a2.exitBlock = ^(id data) {
            [executionSequence addObject:@"a2_exit"];
        };
        
        a3.enterBlock = ^(id data) {
            [executionSequence addObject:@"a3_enter"];
        };
        
        a3.exitBlock = ^(id data) {
            [executionSequence addObject:@"a3_exit"];
        };
        
        b.enterBlock = ^(id data) {
            [executionSequence addObject:@"b_enter"];
        };
        
        b.exitBlock = ^(id data) {
            [executionSequence addObject:@"b_exit"];
        };
        
        b1.enterBlock = ^(id data) {
            [executionSequence addObject:@"b1_enter"];
        };
        
        b1.exitBlock = ^(id data) {
            [executionSequence addObject:@"b1_exit"];
        };
        
        b2.enterBlock = ^(id data) {
            [executionSequence addObject:@"b2_enter"];
        };
        
        b2.exitBlock = ^(id data) {
            [executionSequence addObject:@"b2_exit"];
        };
        
        b21.enterBlock = ^(id data) {
            [executionSequence addObject:@"b21_enter"];
        };
        
        b21.exitBlock = ^(id data) {
            [executionSequence addObject:@"b21_exit"];
        };
        
        b22.enterBlock = ^(id data) {
            [executionSequence addObject:@"b22_enter"];
        };
        
        b22.exitBlock = ^(id data) {
            [executionSequence addObject:@"b22_exit"];
        };
        
        b3.enterBlock = ^(id data) {
            [executionSequence addObject:@"b3_enter"];
        };
        
        b3.exitBlock = ^(id data) {
            [executionSequence addObject:@"b3_exit"];
        };
        
        b311.enterBlock = ^(id data) {
            [executionSequence addObject:@"b311_enter"];
        };
        
        b311.exitBlock = ^(id data) {
            [executionSequence addObject:@"b311_exit"];
        };
        
        b312.enterBlock = ^(id data) {
            [executionSequence addObject:@"b312_enter"];
        };
        
        b312.exitBlock = ^(id data) {
            [executionSequence addObject:@"b312_exit"];
        };
        
        b321.enterBlock = ^(id data) {
            [executionSequence addObject:@"b321_enter"];
        };
        
        b321.exitBlock = ^(id data) {
            [executionSequence addObject:@"b321_exit"];
        };
        
        b322.enterBlock = ^(id data) {
            [executionSequence addObject:@"b322_enter"];
        };
        
        b322.exitBlock = ^(id data) {
            [executionSequence addObject:@"b322_exit"];
        };
        
        c.enterBlock = ^(id data) {
            [executionSequence addObject:@"c_enter"];
        };
        
        c.exitBlock = ^(id data) {
            [executionSequence addObject:@"c_exit"];
        };
        
        c1.enterBlock = ^(id data) {
            [executionSequence addObject:@"c1_enter"];
        };
        
        c1.exitBlock = ^(id data) {
            [executionSequence addObject:@"c1_exit"];
        };
        
        c2.enterBlock = ^(id data) {
            [executionSequence addObject:@"c2_enter"];
        };
        
        c2.exitBlock = ^(id data) {
            [executionSequence addObject:@"c2_exit"];
        };
        
        c211.enterBlock = ^(id data) {
            [executionSequence addObject:@"c211_enter"];
        };
        
        c211.exitBlock = ^(id data) {
            [executionSequence addObject:@"c211_exit"];
        };
        
        c212.enterBlock = ^(id data) {
            [executionSequence addObject:@"c212_enter"];
        };
        
        c212.exitBlock = ^(id data) {
            [executionSequence addObject:@"c212_exit"];
        };
        
        c221.enterBlock = ^(id data) {
            [executionSequence addObject:@"c221_enter"];
        };
        
        c221.exitBlock = ^(id data) {
            [executionSequence addObject:@"c221_exit"];
        };
        
        c222.enterBlock = ^(id data) {
            [executionSequence addObject:@"c222_enter"];
        };
        
        c222.exitBlock = ^(id data) {
            [executionSequence addObject:@"c222_exit"];
        };
        
        // superstates / substates guards
        [a1 addHandlerForEvent:StateMachineEvents.a_guard target:a2 kind:TBSMTransitionExternal action:nil guard:^BOOL(id data) {
            return (data && data[event_data_key] == event_data_value);
        }];
        [a1 addHandlerForEvent:StateMachineEvents.a_guard target:a3 kind:TBSMTransitionExternal action:nil guard:^BOOL(id data) {
            return (data && data[event_data_key] != event_data_value);
        }];
        
        // run to completion test / queuing
        [a2 addHandlerForEvent:StateMachineEvents.a2_a3 target:a3 kind:TBSMTransitionExternal action:^(id data) {
            [executionSequence addObject:@"a2_to_a3_action"];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a3_a1 data:nil]];
        }];
        
        // internal transitions
        [a1 addHandlerForEvent:StateMachineEvents.a1_internal target:a1 kind:TBSMTransitionInternal action:^(id data) {
            [executionSequence addObject:@"a1_internal_action"];
        }];
        
        [b311 addHandlerForEvent:StateMachineEvents.b3xx_internal target:b311 kind:TBSMTransitionInternal action:^(id data) {
            [executionSequence addObject:@"b311_internal_action"];
        }];
        [b321 addHandlerForEvent:StateMachineEvents.b3xx_internal target:b321 kind:TBSMTransitionInternal action:^(id data) {
            [executionSequence addObject:@"b321_internal_action"];
        }];
        
        // junction between b1 and c2
        TBSMJunction *junction = [TBSMJunction junctionWithName:@"junction"];
        [junction addOutgoingPathWithTarget:b1 action:nil guard:^BOOL(id data) {
            return (data[@"junction_b1"] != nil);
        }];
        [junction addOutgoingPathWithTarget:c2 action:^(id data) {
            [executionSequence addObject:@"junction_to_c2_outgoing_path_action"];
        } guard:^BOOL(id data) {
            return (data[@"junction_c2"] != nil);
        }];
        [a addHandlerForEvent:StateMachineEvents.a_junction target:junction kind:TBSMTransitionExternal action:^(id data) {
            [executionSequence addObject:@"a_to_junction_ingoing_path_action"];
        }];
        
        [[TBSMDebugger sharedInstance] debugStateMachine:stateMachine];
        [stateMachine setUp:nil];
        
        executionSequence = [NSMutableArray new];
    });
    
    afterEach(^{
        [stateMachine tearDown:nil];
        stateMachine = nil;
        
        eventDataA = nil;
        eventDataB = nil;
        executionSequence = nil;
    });
    
    it(@"evalutes the guards and chooses the transition defined on super state.", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a_exit",
                                               @"b_enter",
                                               @"b1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"evalutes the guards and chooses the first transition defined on sub state.", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:event_data_value}] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a2_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"evalutes the guards and chooses the second transition defined on sub state.", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:@(1)}] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a3_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"handles events which are scheduled in the middle of a transition considering the run to completion model.", ^{
        
        waitUntil(^(DoneCallback done) {
            
            TBSMState *a1 = [stateMachine stateWithPath:@"a/a1"];
            a1.enterBlock = ^(id data) {
                [executionSequence addObject:@"a1_enter"];
                done();
            };
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:event_data_value}] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a2_a3 data:nil]];
        });
        
        NSArray *expectedExecutionSequence = @[@"a2_exit",
                                               @"a2_to_a3_action",
                                               @"a3_enter",
                                               @"a3_exit",
                                               @"a1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    
    it(@"switches deep from and into a sub state which enters initial state.", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:@(1)}] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a3_b2 data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a3_exit",
                                               @"a_exit",
                                               @"b_enter",
                                               @"b2_enter",
                                               @"b21_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"switches even deeper from and into a specified sub state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:@(1)}] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a3_b22 data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a3_exit",
                                               @"a_exit",
                                               @"b_enter",
                                               @"b2_enter",
                                               @"b22_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs an external transition from containing source state to contained target state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_a2 data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a_exit",
                                               @"a_enter",
                                               @"a2_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs an external transition from contained source state to containing target state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:event_data_value}] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a2_a data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a2_exit",
                                               @"a_exit",
                                               @"a_enter",
                                               @"a1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs a local transition from containing source state to contained target state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:nil] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b_b22 data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"b1_exit",
                                               @"b2_enter",
                                               @"b22_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs a local transition from contained source state to containing target state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:@(1)}]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a3_b22 data:nil] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b22_b data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"b22_exit",
                                               @"b2_exit",
                                               @"b1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"defaults to an external transition when source and target of a local transition are no ancestors.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b_a3 data:nil] withCompletion:^{
                done();
            }];
        });
        
        TBSMSubState *a = (TBSMSubState *)[stateMachine stateWithPath:@"a"];
        expect(stateMachine.currentState).to.equal(a);
        expect(a.stateMachine.currentState.name).to.equal(@"a3");
    });
    
    it(@"performs an internal transition.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a1_internal data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a1_internal data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a1_internal data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_internal_action",
                                               @"a1_internal_action",
                                               @"a1_internal_action"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs parallel internal transitions.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b_b3 data:nil] withCompletion:^{
                
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b3xx_internal data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b3xx_internal data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"b311_internal_action",
                                               @"b321_internal_action",
                                               @"b311_internal_action",
                                               @"b321_internal_action"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs a transition out of a parallel sub state into a top level state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b_b3 data:nil] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b311_a1 data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"b311_exit",
                                               @"b321_exit",
                                               @"b3_exit",
                                               @"b_exit",
                                               @"a_enter",
                                               @"a1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
    });
    
    it(@"performs a transition into a parallel state and enters default sub states.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.b_b3 data:nil] withCompletion:^{
                done();
            }];
        });
        
        expect(stateMachine.currentState.name).to.equal(@"b");
        
        TBSMSubState *b = (TBSMSubState *)[stateMachine stateWithPath:@"b"];
        expect(b.stateMachine.currentState.name).to.equal(@"b3");
        
        TBSMParallelState *b3 = (TBSMParallelState *)[stateMachine stateWithPath:@"b/b3"];
        expect(b3.stateMachines[0].currentState.name).to.equal(@"b311");
        expect(b3.stateMachines[1].currentState.name).to.equal(@"b321");
    });
    
    it(@"performs a transition into a parallel state and enters specified sub state while entering all other parallel machines with default state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_guard data:@{event_data_key:@(1)}]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a3_b322 data:nil] withCompletion:^{
                done();
            }];
        });
        
        expect(stateMachine.currentState.name).to.equal(@"b");
        
        TBSMSubState *b = (TBSMSubState *)[stateMachine stateWithPath:@"b"];
        expect(b.stateMachine.currentState.name).to.equal(@"b3");
        
        TBSMParallelState *b3 = (TBSMParallelState *)[stateMachine stateWithPath:@"b/b3"];
        expect(b3.stateMachines[0].currentState.name).to.equal(@"b311");
        expect(b3.stateMachines[1].currentState.name).to.equal(@"b322");
    });
    
    it(@"performs a fork compound transition into the specified region.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_fork data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a_exit",
                                               @"c_enter",
                                               @"c2_enter",
                                               @"c212_enter",
                                               @"c222_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
        
        expect(stateMachine.currentState.name).to.equal(@"c");
        
        TBSMSubState *c = (TBSMSubState *)[stateMachine stateWithPath:@"c"];
        expect(c.stateMachine.currentState.name).to.equal(@"c2");
        
        TBSMParallelState *c2 = (TBSMParallelState *)[stateMachine stateWithPath:@"c/c2"];
        expect(c2.stateMachines[0].currentState.name).to.equal(@"c212");
        expect(c2.stateMachines[1].currentState.name).to.equal(@"c222");
    });
    
    it(@"performs a join compound transition into the join target state.", ^{
        
        waitUntil(^(DoneCallback done) {
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_fork data:nil] withCompletion:^{
                [executionSequence removeAllObjects];
            }];
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.c212_join data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.c212_join data:nil]];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.c222_join data:nil] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"c212_exit",
                                               @"c222_exit",
                                               @"c2_exit",
                                               @"c_exit",
                                               @"b_enter",
                                               @"b1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
        
        expect(stateMachine.currentState.name).to.equal(@"b");
    });
    
    it(@"performs a junction compound transition into the first target state.", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_junction data:@{@"junction_b1":@""}] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a_exit",
                                               @"a_to_junction_ingoing_path_action",
                                               @"b_enter",
                                               @"b1_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
        
        expect(stateMachine.currentState.name).to.equal(@"b");
        
        TBSMSubState *b = (TBSMSubState *)[stateMachine stateWithPath:@"b"];
        expect(b.stateMachine.currentState.name).to.equal(@"b1");
    });
    
    it(@"performs a junction compound transition into the second target state.", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_junction data:@{@"junction_c2":@""}] withCompletion:^{
                done();
            }];
        });
        
        NSArray *expectedExecutionSequence = @[@"a1_exit",
                                               @"a_exit",
                                               @"a_to_junction_ingoing_path_action",
                                               @"junction_to_c2_outgoing_path_action",
                                               @"c_enter",
                                               @"c2_enter",
                                               @"c211_enter",
                                               @"c221_enter"];
        
        expect(executionSequence).to.equal(expectedExecutionSequence);
        
        expect(stateMachine.currentState.name).to.equal(@"c");
        
        TBSMSubState *c = (TBSMSubState *)[stateMachine stateWithPath:@"c"];
        expect(c.stateMachine.currentState.name).to.equal(@"c2");
    });
    
    it(@"resolves a path", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_fork data:nil] withCompletion:^{
                done();
            }];
        });
        
        TBSMState *state = [stateMachine stateWithPath:@"c/c2@1/c222"];
        expect(state.name).to.equal(@"c222");
    });
    
    it(@"fails to resolve a path", ^{
        
        waitUntil(^(DoneCallback done) {
            
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:StateMachineEvents.a_fork data:nil] withCompletion:^{
                done();
            }];
        });
        
        expect(^{
            [stateMachine stateWithPath:@"c/c2/c222"];
        }).to.raise(TBSMException);
        
        expect(^{
            [stateMachine stateWithPath:@"c/c2@5/c222"];
        }).to.raise(TBSMException);
        
        expect(^{
            [stateMachine stateWithPath:@"c/c2@-1/c222"];
        }).to.raise(TBSMException);
        
        expect(^{
            [stateMachine stateWithPath:@"c/c1/c222"];
        }).to.raise(TBSMException);
        
        expect(^{
            [stateMachine stateWithPath:@"c/c1/c222/cFoobar"];
        }).to.raise(TBSMException);
        
        expect(^{
            [stateMachine stateWithPath:@""];
        }).to.raise(TBSMException);
    });
});

SpecEnd
