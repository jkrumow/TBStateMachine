//
//  TBSMStateMachineSimpleTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import "TBSMStateMachine+TestHelper.h"

SpecBegin(TBSMStateMachineSimple)

NSString * const EVENT_A = @"DummyEventA";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;
__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;
__block NSDictionary *eventDataA;

describe(@"TBSMStateMachine", ^{
    
    beforeEach(^{
        stateMachine = [TBSMStateMachine stateMachineWithName:@"StateMachine"];
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        c = [TBSMState stateWithName:@"c"];
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
    });
    
    afterEach(^{
        [stateMachine tearDown:nil];
        stateMachine = nil;
        a = nil;
        b = nil;
        c = nil;
        eventDataA = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            expect(^{
                stateMachine = [TBSMStateMachine stateMachineWithName:nil];
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            expect(^{
                stateMachine = [TBSMStateMachine stateMachineWithName:@""];
            }).to.raise(TBSMException);
        });
        
        it(@"throws a TBSMException when state object is not of type TBSMState.", ^{
            id object = [NSObject new];
            expect(^{
                stateMachine.states = @[a, b, object];
            }).to.raise(TBSMException);
        });
        
        it(@"throws a TBSMException when initial state does not exist in set of defined states.", ^{
            stateMachine.states = @[a, b];
            expect(^{
                stateMachine.initialState = c;
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws a TBSMException when initial state has not been set on setup.", ^{
            expect(^{
                [stateMachine setUp:nil];
            }).to.raise(TBSMException);
        });
        
        it(@"throws a TBSMException when the configured queue is not a serial queue.", ^{
            NSOperationQueue *queue = [NSOperationQueue new];
            queue.maxConcurrentOperationCount = 10;
            stateMachine.scheduledEventsQueue = queue;
            
            expect(^{
                [stateMachine setUp:nil];
            }).to.raise(TBSMException);
        });
    });
    
    describe(@"Location inside hierarchy.", ^{
        
        it(@"returns its path inside the state machine hierarchy containing all parent state machines in descending order.", ^{
            
            TBSMStateMachine *subStateMachineA = [TBSMStateMachine stateMachineWithName:@"SubA"];
            TBSMStateMachine *subStateMachineB = [TBSMStateMachine stateMachineWithName:@"SubB"];
            TBSMParallelState *parallelStates = [TBSMParallelState parallelStateWithName:@"ParallelWrapper"];
            subStateMachineB.states = @[b];
            TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"subStateB"];
            subStateB.stateMachine = subStateMachineB;
            subStateMachineA.states = @[subStateB];
            
            parallelStates.stateMachines = @[subStateMachineA];
            stateMachine.states = @[parallelStates];
            
            NSArray *path = [subStateMachineB path];
            
            expect(path.count).to.equal(3);
            expect(path[0]).to.equal(stateMachine);
            expect(path[1]).to.equal(subStateMachineA);
            expect(path[2]).to.equal(subStateMachineB);
        });
        
        it(@"returns its name.", ^{
            TBSMStateMachine *stateMachineXYZ = [TBSMStateMachine stateMachineWithName:@"StateMachineXYZ"];
            expect(stateMachineXYZ.name).to.equal(@"StateMachineXYZ");
        });
        
    });
    
    describe(@"State switching.", ^{
        
        it(@"enters initial state on set up when it has been set explicitly.", ^{
            
            stateMachine.states = @[a, b];
            stateMachine.initialState = a;
            
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateMachine.initialState);
            expect(stateMachine.currentState).to.equal(a);
        });
        
        it(@"enters initial state on set up when it has been set implicitly.", ^{
            
            stateMachine.states = @[a, b];
            
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(stateMachine.initialState);
            expect(stateMachine.currentState).to.equal(a);
        });
        
        it(@"exits current state on tear down.", ^{
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(a);
            
            [stateMachine tearDown:nil];
            
            expect(stateMachine.currentState).to.beNil;
        });
        
        it(@"switches to the specified state.", ^{
            
            [a addHandlerForEvent:EVENT_A target:b kind:TBSMTransitionExternal];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            expect(stateMachine.currentState).to.equal(a);
            
            waitUntil(^(DoneCallback done) {
                
                // enters state B
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
                
            });
            
            expect(stateMachine.currentState).to.equal(b);
        });
        
        it(@"evaluates a guard function, exits the current state, executes transition action and enters the next state.", ^{
            
            NSMutableString *executionSequence = [NSMutableString stringWithString:@""];
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"enterA"];
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-exitA"];
            };
            
            b.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                [executionSequence appendString:@"-enterB"];
            };
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               [executionSequence appendString:@"-actionA"];
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                [executionSequence appendString:@"-guardA"];
                                return YES;
                            }];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            waitUntil(^(DoneCallback done) {
                
                // will enter state B
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
                
            });
            
            expect(executionSequence).to.equal(@"enterA-guardA-exitA-actionA-enterB");
        });
        
        it(@"evaluates a guard function, and skips switching to the next state.", ^{
            
            __block BOOL didExecuteAction = NO;
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteAction = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return NO;
                            }];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            waitUntil(^(DoneCallback done) {
                
                // will not enter state B
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(didExecuteAction).to.equal(NO);
            expect(stateMachine.currentState).to.equal(a);
        });
        
        it(@"evaluates multiple guard functions, and switches to the next state.", ^{
            
            __block BOOL didExecuteActionA = NO;
            __block BOOL didExecuteActionB = NO;
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteActionA = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return NO;
                            }];
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               didExecuteActionB = YES;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                return YES;
                            }];
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            waitUntil(^(DoneCallback done) {
                
                // will enter state B through second transition
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(didExecuteActionA).to.equal(NO);
            expect(didExecuteActionB).to.equal(YES);
            expect(stateMachine.currentState).to.equal(b);
        });
        
        it(@"passes source and target state and event data into the enter, exit, action and guard blocks of the involved states.", ^{
            
            __block TBSMState *sourceStateEnter;
            __block TBSMState *targetStateEnter;
            __block NSDictionary *stateDataEnter;
            __block TBSMState *sourceStateExit;
            __block TBSMState *targetStateExit;
            __block NSDictionary *stateDataExit;
            
            __block TBSMState *sourceStateGuard;
            __block TBSMState *targetStateGuard;
            __block TBSMState *sourceStateAction;
            __block TBSMState *targetStateAction;
            __block NSDictionary *actionData;
            __block NSDictionary *guardData;
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateExit = sourceState;
                targetStateExit = targetState;
                stateDataExit = data;
            };
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateExit = sourceState;
                targetStateExit = targetState;
                stateDataExit = data;
            };
            
            [a addHandlerForEvent:EVENT_A
                           target:b
                             kind:TBSMTransitionExternal
                           action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                               sourceStateAction = sourceState;
                               targetStateAction = targetState;
                               actionData = data;
                           }
                            guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                                sourceStateGuard = sourceState;
                                targetStateGuard = targetState;
                                guardData = data;
                                return YES;
                            }];
            
            b.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                sourceStateEnter = sourceState;
                targetStateEnter = targetState;
                stateDataEnter = data;
            };
            
            stateMachine.states = @[a, b];
            [stateMachine setUp:nil];
            
            expect(sourceStateEnter).to.beNil;
            expect(targetStateEnter).to.equal(a);
            expect(stateDataEnter).to.beNil;
            
            waitUntil(^(DoneCallback done) {
                
                // enters state B
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:eventDataA] withCompletion:^{
                    done();
                }];
                
            });
            expect(sourceStateExit).to.equal(a);
            expect(targetStateExit).to.equal(b);
            
            expect(stateDataExit).to.equal(eventDataA);
            expect(stateDataExit.allKeys).haveCountOf(1);
            expect(stateDataExit[EVENT_DATA_KEY]).toNot.beNil;
            expect(stateDataExit[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(guardData).to.equal(eventDataA);
            expect(guardData.allKeys).haveCountOf(1);
            expect(guardData[EVENT_DATA_KEY]).toNot.beNil;
            expect(guardData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(actionData).to.equal(eventDataA);
            expect(actionData.allKeys).haveCountOf(1);
            expect(actionData[EVENT_DATA_KEY]).toNot.beNil;
            expect(actionData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(sourceStateEnter).to.equal(a);
            expect(targetStateEnter).to.equal(b);
            
            expect(stateDataEnter).to.equal(eventDataA);
            expect(stateDataEnter.allKeys).haveCountOf(1);
            expect(stateDataEnter[EVENT_DATA_KEY]).toNot.beNil;
            expect(stateDataEnter[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"can re-enter a state.", ^{
            
            __block BOOL didEnterStateA = NO;
            __block BOOL didExitStateA = NO;
            
            a.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                didEnterStateA = YES;
            };
            
            a.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                didExitStateA = YES;
            };
            
            [a addHandlerForEvent:EVENT_A target:a kind:TBSMTransitionExternal];
            
            stateMachine.states = @[a, b];
            
            [stateMachine setUp:nil];
            
            didEnterStateA = NO;
            
            waitUntil(^(DoneCallback done) {
                
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:EVENT_A data:nil] withCompletion:^{
                    done();
                }];
            });
            
            expect(stateMachine.currentState).to.equal(a);
            expect(didExitStateA).to.equal(YES);
            expect(didEnterStateA).to.equal(YES);
        });
    });
});

SpecEnd
