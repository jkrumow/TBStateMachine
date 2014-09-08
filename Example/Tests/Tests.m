//
//  TBStateMachineTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 08/01/2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(StateMachine)

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
__block TBStateMachineParallelWrapper *parallelStates;
__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;

describe(@"TBStateMachineState", ^{
    
    beforeEach(^{
        stateA = [TBStateMachineState stateWithName:@"a"];
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBStateMachineEvent eventWithName:EVENT_NAME_A];
        eventB = [TBStateMachineEvent eventWithName:EVENT_NAME_B];
    });
    
    afterEach(^{
        stateA = nil;
        eventDataA = nil;
        eventDataB = nil;
        eventA = nil;
        eventB = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                stateA = [TBStateMachineState stateWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                stateA = [TBStateMachineState stateWithName:@""];
            }).to.raise(TBStateMachineException);
            
        });
        
    });
    
    it(@"registers TBStateMachineEventBlock instances by the name of a provided TBStateMachineEvent instance.", ^{
        
        [stateA registerEvent:eventA target:nil];
        
        NSDictionary *registeredEvents = stateA.eventHandlers;
        expect(registeredEvents.allKeys).to.haveCountOf(1);
        expect(registeredEvents).to.contain(eventA.name);
    });
    
    it(@"handles events by returning nil or a TBStateMachineTransition containing source and destination state.", ^{
        
        [stateA registerEvent:eventA target:nil];
        [stateA registerEvent:eventB target:stateB];
        
        TBStateMachineTransition *resultA = [stateA handleEvent:eventA];
        expect(resultA).to.beNil;
        
        TBStateMachineTransition *resultB = [stateA handleEvent:eventB];
        expect(resultB.sourceState).to.equal(stateA);
        expect(resultB.destinationState).to.equal(stateB);
    });
    
});

describe(@"TBStateMachineParallelWrapper", ^{
    
    beforeEach(^{
        parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
        stateA = [TBStateMachineState stateWithName:@"a"];
        stateB = [TBStateMachineState stateWithName:@"b"];
        stateC = [TBStateMachineState stateWithName:@"c"];
        stateD = [TBStateMachineState stateWithName:@"d"];
        stateE = [TBStateMachineState stateWithName:@"e"];
        stateF = [TBStateMachineState stateWithName:@"f"];
        
        subStateMachineA = [TBStateMachine stateMachineWithName:@"SubA"];
        subStateMachineB = [TBStateMachine stateMachineWithName:@"SubB"];
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBStateMachineEvent eventWithName:EVENT_NAME_A];
    });
    
    afterEach(^{
        parallelStates = nil;
        stateA = nil;
        stateB = nil;
        stateC = nil;
        stateD = nil;
        stateE = nil;
        stateF = nil;
        
        subStateMachineA = nil;
        subStateMachineB = nil;
        
        eventDataA = nil;
        eventA = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:@""];
            }).to.raise(TBStateMachineException);
            
        });
        
        it(@"throws TBStateMachineException when state object is not of type TBStateMachine.", ^{
            
            id object = [[NSObject alloc] init];
            NSArray *states = @[subStateMachineA, subStateMachineB, object];
            expect(^{
                parallelStates.states = states;
            }).to.raise(TBStateMachineException);
        });
        
    });
    
    it(@"switches states on all registered states", ^{
        
        __block BOOL enteredStateA = NO;
        stateA.enterBlock = ^(id<TBStateMachineNode> previousState, NSDictionary *data) {
            enteredStateA = YES;
        };
        
        __block BOOL exitedStateA = NO;
        stateA.exitBlock = ^(id<TBStateMachineNode>nextState, NSDictionary *data) {
            exitedStateA = YES;
        };
        
        __block BOOL enteredStateB = NO;
        stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
            enteredStateB = YES;
        };
        
        __block BOOL exitedStateB = NO;
        stateB.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
            exitedStateB = YES;
        };
        
        subStateMachineA.states = @[stateA];
        subStateMachineA.initialState = stateA;
        
        subStateMachineB.states = @[stateB];
        subStateMachineB.initialState = stateB;
        
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
        parallelStates.states = parallelSubStateMachines;
        
        [parallelStates enter:nil data:nil];
        
        expect(enteredStateA).to.equal(YES);
        expect(enteredStateB).to.equal(YES);
        
        [parallelStates exit:nil data:nil];
        
        expect(exitedStateA).to.equal(YES);
        expect(exitedStateB).to.equal(YES);
    });
    
    it(@"handles events on all registered states until the first valid follow-up state is returned.", ^{
        
        [stateA registerEvent:eventA target:stateC];
        [stateB registerEvent:eventA target:stateD];
        
        subStateMachineA.states = @[stateA];
        subStateMachineA.initialState = stateA;
        
        subStateMachineB.states = @[stateB];
        subStateMachineB.initialState = stateB;
        
        NSArray *states = @[subStateMachineA, subStateMachineB];
        parallelStates.states = states;
        
        [parallelStates enter:nil data:nil];
        TBStateMachineTransition *result = [parallelStates handleEvent:eventA];
        
        expect(result).toNot.beNil;
        
        NSArray *validSourceStates = @[stateA, stateB];
        expect(validSourceStates).contain(result.sourceState);
        NSArray *validDestinationStates = @[stateC, stateD];
        expect(validDestinationStates).contain(result.destinationState);
        
        if (result.sourceState == stateA) {
            expect(result.destinationState).to.equal(stateC);
        } else if (result.sourceState == stateB) {
            expect(result.destinationState).to.equal(stateD);
        }
        
    });
    
});

describe(@"TBStateMachineEvent", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                [TBStateMachineEvent eventWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                [TBStateMachineEvent eventWithName:@""];
            }).to.raise(TBStateMachineException);
            
        });
        
    });
    
});

describe(@"TBStateMachineEventHandler", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                [TBStateMachineEventHandler eventHandlerWithName:nil target:nil action:nil guard:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                [TBStateMachineEventHandler eventHandlerWithName:@"" target:nil action:nil guard:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
    });
    
});

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
        parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
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
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                stateMachine = [TBStateMachine stateMachineWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                stateMachine = [TBStateMachine stateMachineWithName:@""];
            }).to.raise(TBStateMachineException);
            
        });
        
        it(@"throws TBStateMachineException when state object does not implement the TBStateMachineNode protocol.", ^{
            id object = [[NSObject alloc] init];
            NSArray *states = @[stateA, stateB, object];
            expect(^{
                stateMachine.states = states;
            }).to.raise(TBStateMachineException);
        });
        
        it(@"throws TBStateMachineException initial state does not exist in set of defined states.", ^{
            NSArray *states = @[stateA, stateB];
            stateMachine.states = states;
            expect(^{
                stateMachine.initialState = stateC;
            }).to.raise(TBStateMachineException);
            
        });
        
        it(@"throws TBStateMachineException when initial state has not been set before setup.", ^{
            NSArray *states = @[stateA, stateB];
            stateMachine.states = states;
            
            expect(^{
                [stateMachine setUp];
            }).to.raise(TBStateMachineException);
        });
        
    });
    
    describe(@"State switching.", ^{
        
        it(@"enters initial state on set up.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBStateMachineState *previousStateA;
            __block NSDictionary *dataEnterA;
            __block BOOL wasEnterExecuted = NO;
            __block BOOL wasExitExecuted = NO;
            
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                wasEnterExecuted = YES;
                previousStateA = previousState;
                dataEnterA = data;
            };
            
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                wasExitExecuted = YES;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            expect(wasEnterExecuted).to.equal(YES);
            expect(previousStateA).to.beNil;
            expect(dataEnterA).to.beNil;
            expect(wasExitExecuted).to.equal(NO);
        });
        
        it(@"exits current state on tear down.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL wasEnterExecuted = NO;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                wasEnterExecuted = YES;
            };
            
            __block TBStateMachineState *nextStateA;
            __block NSDictionary *dataExitA;
            __block BOOL wasExitExecuted = NO;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                wasExitExecuted = YES;
                nextStateA = nextState;
                dataExitA = data;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            expect(wasEnterExecuted).to.equal(YES);
            expect(wasExitExecuted).to.equal(NO);
            
            wasEnterExecuted = NO;
            
            [stateMachine tearDown];
            
            expect(stateMachine.currentState).to.beNil;
            
            expect(nextStateA).to.beNil;
            expect(dataExitA).to.beNil;
            expect(wasEnterExecuted).to.equal(NO);
            expect(wasExitExecuted).to.equal(YES);
        });
        
        it(@"switches to the specified state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block TBStateMachineState *previousStateA;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateA = previousState;
            };
            
            __block TBStateMachineState *nextStateA;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateA = nextState;
            };
            
            __block TBStateMachineState *previousStateB;
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateB = previousState;
            };
            
            [stateA registerEvent:eventA target:stateB];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(stateMachine.currentState).to.equal(stateA);
            
            // enters state B
            [stateMachine scheduleEvent:eventA];
            
            expect(stateMachine.currentState).to.equal(stateB);
            
            expect(previousStateA).to.beNil;
            expect(nextStateA).to.equal(stateB);
            expect(previousStateB).to.equal(stateA);
        });
        
        it(@"evaluates a guard function, exits the current state, executes transition action and enters the next state.", ^{
            
            NSMutableString *executionOrder = [NSMutableString stringWithString:@""];
            
            NSArray *states = @[stateA, stateB];
            
            __block TBStateMachineState *previousStateA;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateA = previousState;
            };
            
            __block TBStateMachineState *nextStateA;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateA = nextState;
                [executionOrder appendString:@"-exit"];
            };
            
            __block TBStateMachineState *previousStateB;
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateB = previousState;
                [executionOrder appendString:@"-enter"];
            };
            
            __block BOOL didExecuteAction = NO;
            [stateA registerEvent:eventA
                           target:stateB
                           action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                               didExecuteAction = YES;
                               [executionOrder appendString:@"-action"];
                           }
                            guard:^BOOL(id<TBStateMachineNode> nextState, NSDictionary *data) {
                                [executionOrder appendString:@"guard"];
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will enter state B
            [stateMachine scheduleEvent:eventA];
            
            expect(didExecuteAction).to.equal(YES);
            expect(previousStateA).to.beNil;
            expect(nextStateA).to.equal(stateB);
            expect(previousStateB).to.equal(stateA);
            expect(executionOrder).to.equal(@"guard-exit-action-enter");
        });
        
        it(@"evaluates a guard function, and skips switching to the next state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block BOOL didExecuteEnterA = NO;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                didExecuteEnterA = YES;
            };
            
            __block BOOL didExecuteExitA = NO;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                didExecuteExitA = YES;
            };
            
            __block BOOL didExecuteEnterB = NO;
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                didExecuteEnterB = YES;
            };
            
            __block BOOL didExecuteAction = NO;
            [stateA registerEvent:eventA
                           target:stateB
                           action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                               didExecuteAction = YES;
                           }
                            guard:^BOOL(id<TBStateMachineNode> nextState, NSDictionary *data) {
                                return NO;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(didExecuteEnterA).to.equal(YES);
            
            // will not enter state B
            [stateMachine scheduleEvent:eventA];
            
            expect(didExecuteAction).to.equal(NO);
            expect(didExecuteExitA).to.equal(NO);
            expect(didExecuteEnterB).to.equal(NO);
        });
        
        it(@"passes next state and event data into the guard function and transition action of the involved state.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block id<TBStateMachineNode> nextStateAction;
            __block NSDictionary *receivedDataAction;
            __block id<TBStateMachineNode> nextStateGuard;
            __block NSDictionary *receivedDataGuard;
            [stateA registerEvent:eventA
                           target:stateB
                           action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                               nextStateAction = nextState;
                               receivedDataAction = data;
                           }
                            guard:^BOOL(id<TBStateMachineNode> nextState, NSDictionary *data) {
                                nextStateGuard = nextState;
                                receivedDataGuard = data;
                                return YES;
                            }];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // will enter state B
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            expect(nextStateAction).to.equal(stateB);
            expect(receivedDataAction).to.equal(eventDataA);
            expect(receivedDataAction[EVENT_DATA_KEY]).toNot.beNil;
            expect(receivedDataAction[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(nextStateGuard).to.equal(stateB);
            expect(receivedDataGuard).to.equal(eventDataA);
            expect(receivedDataGuard[EVENT_DATA_KEY]).toNot.beNil;
            expect(receivedDataGuard[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"passes next state and event data into the enter and exit blocks of the involved states.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            __block id<TBStateMachineNode> nextStateA;
            __block NSDictionary *nextStateAData;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateA = nextState;
                nextStateAData = data;
            };
            
            [stateA registerEvent:eventA target:stateB];
            
            __block TBStateMachineState *previousStateB;
            __block NSDictionary *previousStateBData;
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateB = previousState;
                previousStateBData = data;
            };
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // enters state B
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            expect(nextStateA).to.equal(stateB);
            expect(nextStateAData).to.equal(eventDataA);
            expect(nextStateAData.allKeys).haveCountOf(1);
            expect(nextStateAData[EVENT_DATA_KEY]).toNot.beNil;
            expect(nextStateAData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(previousStateB).to.equal(stateA);
            expect(previousStateBData).to.equal(eventDataA);
            expect(previousStateBData.allKeys).haveCountOf(1);
            expect(previousStateBData[EVENT_DATA_KEY]).toNot.beNil;
            expect(previousStateBData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
        
        it(@"returns an unprocessed transition when the result of a given event can not be handled.", ^{
            
            NSArray *states = @[stateA, stateB];
            
            [stateA registerEvent:eventA target:stateC];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            TBStateMachineTransition *transition = [stateMachine handleEvent:eventA];
            expect(transition.destinationState).to.equal(stateC);
        });
        
        it(@"can re-enter a state.", ^{
            
            NSArray *states = @[stateA];
            
            __block TBStateMachineState *previousStateA;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateA = previousState;
            };
            
            __block TBStateMachineState *nextStateA;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateA = nextState;
            };
            
            [stateA registerEvent:eventA target:stateA];
            
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            
            [stateMachine setUp];
            
            [stateMachine scheduleEvent:eventA];
            
            expect(previousStateA).to.equal(stateA);
            expect(nextStateA).to.equal(stateA);
        });
        
        it(@"can switch into and out of sub-state machines.", ^{
            
            // setup sub-state machine A
            __block TBStateMachineState *previousStateC;
            stateC.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateC = previousState;
            };
            
            __block id<TBStateMachineNode> nextStateC;
            stateC.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateC = nextState;
            };
            
            __block TBStateMachineState *previousStateD;
            stateD.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateD = previousState;
            };
            
            __block id<TBStateMachineNode> nextStateD;
            __block NSDictionary *dataExitD;
            stateD.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateD = nextState;
                dataExitD = data;
            };
            
            [stateC registerEvent:eventA target:stateD];
            [stateD registerEvent:eventA target:stateA];
            
            NSArray *subStates = @[stateC, stateD];
            subStateMachineA.states = subStates;
            subStateMachineA.initialState = stateC;
            
            // setup main state machine
            __block id<TBStateMachineNode> previousStateA;
            __block NSDictionary *dataEnterA;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateA = previousState;
                dataEnterA = data;
            };
            
            __block TBStateMachineState *nextStateA;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateA = nextState;
            };
            
            __block TBStateMachineState *previousStateB;
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateB = previousState;
            };
            
            __block id<TBStateMachineNode> nextStateB;
            stateB.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateB = nextState;
            };
            
            [stateA registerEvent:eventA target:stateB];
            [stateB registerEvent:eventA target:subStateMachineA];
            
            NSArray *states = @[stateA, stateB, subStateMachineA];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            expect(previousStateA).to.beNil;
            
            // moves to state B
            [stateMachine scheduleEvent:eventA];
            
            expect(nextStateA).to.equal(stateB);
            expect(previousStateB).to.equal(stateA);
            
            // moves to state C
            [stateMachine scheduleEvent:eventA];
            
            expect(nextStateB).to.equal(subStateMachineA);
            expect(previousStateC).to.beNil;
            
            // moves to state D
            [stateMachine scheduleEvent:eventA];
            
            expect(nextStateC).to.equal(stateD);
            expect(previousStateD).to.equal(stateC);
            
            dataEnterA = nil;
            
            // will go back to start
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            expect(dataExitD[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            expect(previousStateA).to.equal(subStateMachineA);
            expect(nextStateD).to.beNil;
            
            expect(dataEnterA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
            
            // handled by state A
            [stateMachine scheduleEvent:eventA];
            
            expect(nextStateA).to.equal(stateB);
            expect(previousStateB).to.equal(stateA);
        });
        
        it(@"can switch into and out of parallel state machines.", ^{
            
            // setup sub-machine A
            __block TBStateMachineState *previousStateC;
            stateC.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateC = previousState;
            };
            
            __block TBStateMachineState *nextStateC;
            stateC.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateC = nextState;
            };
            
            __block TBStateMachineState *previousStateD;
            stateD.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateD = previousState;
            };
            
            __block TBStateMachineState *nextStateD;
            stateD.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateD = nextState;
            };
            
            NSArray *subStatesA = @[stateC, stateD];
            subStateMachineA.states = subStatesA;
            subStateMachineA.initialState = stateC;
            
            // setup sub-machine B
            __block TBStateMachineState *previousStateE;
            stateE.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateE = previousState;
            };
            
            __block TBStateMachineState *nextStateE;
            stateE.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateE = nextState;
            };
            
            __block TBStateMachineState *previousStateF;
            stateF.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateF = previousState;
            };
            
            __block TBStateMachineState *nextStateF;
            stateF.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateF = nextState;
            };
            
            NSArray *subStatesB = @[stateE, stateF];
            subStateMachineB.states = subStatesB;
            subStateMachineB.initialState = stateE;
            
            // setup parallel wrapper
            NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
            parallelStates.states = parallelSubStateMachines;
            
            // setup main state machine
            __block id<TBStateMachineNode> previousStateA;
            __block NSDictionary *previousStateDataA;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateA = previousState;
                previousStateDataA = data;
            };
            
            __block TBStateMachineState *nextStateA;
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateA = nextState;
            };
            
            __block TBStateMachineState *previousStateB;
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                previousStateB = previousState;
            };
            
            __block id<TBStateMachineNode> nextStateB;
            stateB.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                nextStateB = nextState;
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
            
            expect(previousStateA).to.beNil;
            
            // moves to state B
            [stateMachine scheduleEvent:eventA];
            
            expect(nextStateA).to.equal(stateB);
            expect(previousStateB).to.equal(stateA);
            
            // moves to parallel state wrapper
            // enters state C in subStateMachine A
            // enters state E in subStateMachine B
            [stateMachine scheduleEvent:eventA];
            
            expect(nextStateB).to.equal(parallelStates);
            expect(previousStateC).to.beNil;
            expect(previousStateE).to.beNil;
            
            // moves subStateMachine A from C to state D
            // moves subStateMachine B from E to state F
            [stateMachine scheduleEvent:eventA];
            
            expect(nextStateC).to.equal(stateD);
            expect(previousStateD).to.equal(stateC);
            
            expect(nextStateE).to.equal(stateF);
            expect(previousStateF).to.equal(stateE);
            //        expect(receivedEventG).to.equal(eventA);
            
            [stateMachine scheduleEvent:eventA data:eventDataA];
            
            // moves back to state A
            expect(nextStateD).to.beNil;
            expect(nextStateF).to.beNil;
            expect(previousStateA).to.beNil;
            expect(previousStateDataA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        });
    });
    
    describe(@"Concurrency", ^{
        
        it(@"queues up events if an event is currently handled", ^{
            
            NSArray *expectedExecutionSequence = @[@"stateA_enter",
                                                   @"stateA_exit",
                                                   @"stateA_action",
                                                   @"stateB_enter",
                                                   @"stateB_exit",
                                                   @"stateB_action",
                                                   @"stateC_enter",
                                                   @"stateC_exit",
                                                   @"stateC_action",
                                                   @"stateA_enter"];
            
            NSMutableArray *executionSequence = [NSMutableArray new];
            
            __block NSUInteger enteredCount = 0;
            __block NSUInteger guardExecutedCount = 0;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_enter"];
                enteredCount++;
                [stateMachine scheduleEvent:eventA];
            };
            
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_exit"];
            };
            
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_enter"];
                [stateMachine scheduleEvent:eventC];
            };
            
            stateB.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_exit"];
            };
            
            stateC.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_enter"];
            };
            
            stateC.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_exit"];
            };
            
            [stateA registerEvent:eventA target:stateB action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_action"];
                [stateMachine scheduleEvent:eventB];
            } guard:^BOOL(id<TBStateMachineNode> nextState, NSDictionary *data) {
                guardExecutedCount++;
                return (enteredCount == 1);
            }];
            
            [stateB registerEvent:eventB target:stateC action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_action"];
            }];
            
            [stateC registerEvent:eventC target:stateA action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_action"];
            }];
            
            
            NSArray *states = @[stateA, stateB, stateC];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // enter A --> send eventA
            // switch to B with action --> send eventB (queued)
            // enter B --> send eventC (queued)
            
            // -------------------
            // stateB handles eventB
            // switch to stateC with action
            
            // -------------------
            // stateC handles eventC
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
                                                   @"stateC_enter",
                                                   @"stateC_exit",
                                                   @"stateC_action",
                                                   @"stateD_enter",
                                                   @"stateD_exit",
                                                   @"stateD_action",
                                                   @"stateA_enter"];
            
            NSMutableArray *executionSequence = [NSMutableArray new];
            
            __block NSUInteger enteredCount = 0;
            stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_enter"];
                enteredCount++;
                
                // quit if we have finished the roundtrip and arrived back in stateA.
                if (enteredCount == 2) {
                    done();
                }
            };
            
            stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_exit"];
            };
            
            stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_enter"];
            };
            
            stateB.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_exit"];
            };
            
            stateC.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_enter"];
            };
            
            stateC.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_exit"];
            };
            
            stateD.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_enter"];
            };
            
            stateD.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_exit"];
            };
            
            [stateA registerEvent:eventA target:stateB action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateA_action"];
            }];
            
            [stateB registerEvent:eventA target:stateC action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateB_action"];
            }];
            
            [stateC registerEvent:eventA target:stateD action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateC_action"];
            }];
            
            [stateD registerEvent:eventA target:stateA action:^(id<TBStateMachineNode> nextState, NSDictionary *data) {
                [executionSequence addObject:@"stateD_action"];
            }];
            
            
            NSArray *states = @[stateA, stateB, stateC, stateD];
            stateMachine.states = states;
            stateMachine.initialState = stateA;
            [stateMachine setUp];
            
            // send all events concurrently.
            dispatch_apply(4, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t idx) {
                [stateMachine scheduleEvent:eventA];
            });
            
            expect(executionSequence).to.equal(expectedExecutionSequence);
            
        });
        
    });
    
});

SpecEnd
