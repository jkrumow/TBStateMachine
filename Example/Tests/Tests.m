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
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBStateMachine *stateMachine;
__block TBStateMachineState *stateA;
__block TBStateMachineState *stateB;
__block TBStateMachineState *stateC;
__block TBStateMachineState *stateD;
__block TBStateMachineState *stateE;
__block TBStateMachineState *stateF;
__block TBStateMachineState *stateG;
__block TBStateMachineEvent *eventA;
__block TBStateMachineEvent *eventB;
__block TBStateMachine *subStateMachineA;
__block TBStateMachine *subStateMachineB;
__block TBStateMachineParallelWrapper *parallelStates;
__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;

__block id<TBStateMachineNode>(^processEventData)(NSDictionary *);
__block void(^processEntranceData)(NSString *, NSDictionary *);

describe(@"TBStateMachineState", ^{
    
    beforeEach(^{
        stateA = [TBStateMachineState stateWithName:@"StateA"];
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
    
    
    it(@"registers TBStateMachineEventBlock instances by the name of a provided TBStateMachineEvent instance.", ^{
        
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event, NSDictionary *data) {
            return nil;
        }];
        
        NSDictionary *registeredEvents = stateA.eventHandlers;
        expect(registeredEvents.allKeys).to.haveCountOf(1);
        expect(registeredEvents).to.contain(eventA.name);
    });
    
    it(@"handles events by returning nil or a TBStateMachineTransition containing source and destination state.", ^{
        
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event, NSDictionary *data) {
            return nil;
        }];
        
        [stateA registerEvent:eventB handler:^id<TBStateMachineNode>(TBStateMachineEvent *event, NSDictionary *data) {
            return stateB;
        }];
        
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
        stateA = [TBStateMachineState stateWithName:@"StateA"];
        stateB = [TBStateMachineState stateWithName:@"StateB"];
        stateC = [TBStateMachineState stateWithName:@"StateC"];
        stateD = [TBStateMachineState stateWithName:@"StateD"];
        stateE = [TBStateMachineState stateWithName:@"StateE"];
        stateF = [TBStateMachineState stateWithName:@"StateF"];
        
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
        
        eventDataA = nil;
        eventA = nil;
    });
    
    
    it(@"throws TBStateMachineException when state object does not implement the TBStateMachineNode protocol.", ^{
        id object = [[NSObject alloc] init];
        NSArray *states = @[stateA, stateB, object];
        expect(^{
            parallelStates.states = states;
        }).to.raise(TBStateMachineException);
    });
    
    it(@"switches states on all registered states", ^{
        
        __block id<TBStateMachineNode> previousStateA;
        stateA.enterBlock = ^(id<TBStateMachineNode> previousState, NSDictionary *data) {
            previousStateA = previousState;
        };
        
        __block TBStateMachineState *nextStateA;
        stateA.exitBlock = ^(id<TBStateMachineNode>nextState, NSDictionary *data) {
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
        
        
        NSArray *parallelSubStateMachines = @[stateA, stateB, stateC, stateD];
        parallelStates.states = parallelSubStateMachines;
        
        [parallelStates enter:stateF data:nil];
        
        expect(previousStateA).to.equal(stateF);
        expect(previousStateB).to.equal(stateF);
        expect(previousStateC).to.equal(stateF);
        expect(previousStateD).to.equal(stateF);
        
        [parallelStates exit:stateE data:nil];
        
        expect(nextStateA).to.equal(stateE);
        expect(nextStateB).to.equal(stateE);
        expect(nextStateC).to.equal(stateE);
        expect(nextStateD).to.equal(stateE);
    });
    
    it(@"handles events on all registered states until the first valid follow-up state is returned.", ^{
        
        __block BOOL stateAHasHandledEvent = NO;
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event, NSDictionary *data) {
            stateAHasHandledEvent = YES;
            return nil;
        }];
        
        __block BOOL stateBHasHandledEvent = NO;
        [stateB registerEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event, NSDictionary *data) {
            stateBHasHandledEvent = YES;
            return nil;
        }];
        
        __block BOOL stateCHasHandledEvent = NO;
        [stateC registerEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event, NSDictionary *data) {
            stateCHasHandledEvent = YES;
            return stateE;
        }];
        
        __block BOOL stateDHasHandledEvent = NO;
        [stateD registerEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event, NSDictionary *data) {
            stateDHasHandledEvent = YES;
            return stateF;
        }];
        
        NSArray *states = @[stateA, stateB, stateC, stateD];
        parallelStates.states = states;
        TBStateMachineTransition *result = [parallelStates handleEvent:eventA];
        
        expect(stateAHasHandledEvent).to.equal(YES);
        expect(stateBHasHandledEvent).to.equal(YES);
        expect(stateCHasHandledEvent).to.equal(YES);
        expect(stateDHasHandledEvent).to.equal(YES);
        
        expect(result).toNot.beNil;
        
        NSArray *validSourceStates = @[stateC, stateD];
        expect(validSourceStates).contain(result.sourceState);
        NSArray *validDestinationStates = @[stateE, stateF];
        expect(validDestinationStates).contain(result.destinationState);
        
        
        if (result.sourceState == stateC) {
            expect(result.destinationState).to.equal(stateE);
        } else if (result.sourceState == stateD) {
            expect(result.destinationState).to.equal(stateF);
        }
        
    });
    
});

describe(@"TBStateMachine", ^{
    
    beforeEach(^{
        stateMachine = [TBStateMachine stateMachineWithName:@"StateMachine"];
        stateA = [TBStateMachineState stateWithName:@"StateA"];
        stateB = [TBStateMachineState stateWithName:@"StateB"];
        stateC = [TBStateMachineState stateWithName:@"StateC"];
        stateD = [TBStateMachineState stateWithName:@"StateD"];
        stateE = [TBStateMachineState stateWithName:@"StateE"];
        stateF = [TBStateMachineState stateWithName:@"StateF"];
        stateG = [TBStateMachineState stateWithName:@"StateG"];
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBStateMachineEvent eventWithName:EVENT_NAME_A];
        eventB = [TBStateMachineEvent eventWithName:EVENT_NAME_B];
        
        subStateMachineA = [TBStateMachine stateMachineWithName:@"SubStateMachineA"];
        subStateMachineB = [TBStateMachine stateMachineWithName:@"SubStateMachineB"];
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
        stateG = nil;
        
        eventDataA = nil;
        eventDataB = nil;
        eventA = nil;
        eventB = nil;
        
        [subStateMachineA tearDown];
        [subStateMachineB tearDown];
        subStateMachineA = nil;
        subStateMachineB = nil;
        parallelStates = nil;
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
    
    it(@"throws TBStateMachineException when initial state has not been defined before setup.", ^{
        NSArray *states = @[stateA, stateB];
        stateMachine.states = states;
        
        expect(^{
            [stateMachine setUp];
        }).to.raise(TBStateMachineException);
    });
    
    it(@"enters into initial state and exits it", ^{
        
        NSArray *states = @[stateA, stateB];
        
        __block TBStateMachineState *previousStateA;
        __block NSDictionary *dataEnterA;
        stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
            previousStateA = previousState;
            dataEnterA = data;
        };
        
        __block TBStateMachineState *nextStateA;
        __block NSDictionary *dataExitA;
        stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
            nextStateA = nextState;
            dataExitA = data;
        };
        
        stateMachine.states = states;
        stateMachine.initialState = stateA;
        [stateMachine setUp];
        
        expect(previousStateA).to.beNil;
        expect(dataEnterA[EVENT_DATA_KEY]).to.beNil;
        
        [stateMachine tearDown];
        
        expect(nextStateA).to.beNil;
        expect(dataExitA[EVENT_DATA_KEY]).to.beNil;
    });
    
    it(@"handles an event and switches to the specified state.", ^{
        
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
        
        __block TBStateMachineEvent *receivedEvent;
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            receivedEvent = event;
            return stateB;
        }];
        
        stateMachine.states = states;
        stateMachine.initialState = stateA;
        [stateMachine setUp];
        
        // enters state B
        [stateMachine handleEvent:eventA];
        
        expect(previousStateA).to.beNil;
        expect(nextStateA).to.equal(stateB);
        expect(previousStateB).to.equal(stateA);
    });
    
    it(@"passes event data into the enter and exit blocks of the involved states.", ^{
        
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
        __block NSDictionary *previousStateBData;
        stateB.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
            previousStateB = previousState;
            previousStateBData = data;
        };
        
        __block TBStateMachineEvent *receivedEvent;
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            receivedEvent = event;
            return stateB;
        }];
        
        stateMachine.states = states;
        stateMachine.initialState = stateA;
        [stateMachine setUp];
        
        // enters state B
        [stateMachine handleEvent:eventA data:eventDataA];
        
        expect(previousStateA).to.beNil;
        expect(nextStateA).to.equal(stateB);
        expect(previousStateB).to.equal(stateA);
        expect(previousStateBData).to.equal(eventDataA);
        expect(previousStateBData.allKeys).haveCountOf(1);
        expect(previousStateBData[EVENT_DATA_KEY]).toNot.beNil;
        expect(previousStateBData[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
    });
    
    it(@"returns an unprocessed transition when the result of a given event can not be handled.", ^{
        
        NSArray *states = @[stateA, stateB];
        
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateC;
        }];
        
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
        
        __block typeof (stateA) weakStateA = stateA;
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return weakStateA;
        }];
        
        stateMachine.states = states;
        stateMachine.initialState = stateA;
        
        [stateMachine setUp];
        
        [stateMachine handleEvent:eventA];
        
        expect(previousStateA).to.equal(stateA);
        expect(nextStateA).to.equal(stateA);
    });
    
    it(@"can handle events to switch into and out of sub statemachines.", ^{
        
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
        
        NSArray *subStates = @[stateC, stateD];
        subStateMachineA.states = subStates;
        subStateMachineA.initialState = stateC;
        
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateB;
        }];
        
        [stateB registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return subStateMachineA;
        }];
        
        [stateC registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateD;
        }];
        
        [stateD registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateA;
        }];
        
        NSArray *states = @[stateA, stateB, subStateMachineA];
        stateMachine.states = states;
        stateMachine.initialState = stateA;
        [stateMachine setUp];
        
        expect(previousStateA).to.beNil;
        
        // moves to state B
        [stateMachine handleEvent:eventA];
        
        expect(nextStateA).to.equal(stateB);
        expect(previousStateB).to.equal(stateA);
        
        // moves to state C
        [stateMachine handleEvent:eventA];
        
        expect(nextStateB).to.equal(subStateMachineA);
        expect(previousStateC).to.beNil;
        
        // moves to state D
        [stateMachine handleEvent:eventA];
        
        expect(nextStateC).to.equal(stateD);
        expect(previousStateD).to.equal(stateC);
        
        dataEnterA = nil;
        
        // will go back to start
        [stateMachine handleEvent:eventA data:eventDataA];
        
        expect(dataExitD[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        
        expect(previousStateA).to.equal(subStateMachineA);
        expect(nextStateD).to.beNil;
        
        expect(dataEnterA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
        
        // handled by state A
        [stateMachine handleEvent:eventA];
        
        expect(nextStateA).to.equal(stateB);
        expect(previousStateB).to.equal(stateA);
    });
    
    it(@"can handle events to switch into and out of parallel states and statemachines.", ^{
        
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
        
        // running in parallel machine wrapper in subStateMachine A
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
        
        // running in parallel machine wrapper in subStateMachine B
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
        
        __block TBStateMachineState *previousStateG;
        stateG.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
            previousStateG = previousState;
        };
        
        __block TBStateMachineState *nextStateG;
        stateF.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
            nextStateG = nextState;
        };
        
        NSArray *subStatesA = @[stateC, stateD];
        subStateMachineA.states = subStatesA;
        subStateMachineA.initialState = stateC;
        
        NSArray *subStatesB = @[stateE, stateF];
        subStateMachineB.states = subStatesB;
        subStateMachineB.initialState = stateE;
        
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB, stateG];
        parallelStates.states = parallelSubStateMachines;
        
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateB;
        }];
        
        [stateB registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return parallelStates;
        }];
        
        [stateC registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateD;
        }];
        
        [stateD registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return nil;
        }];
        
        [stateE registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateF;
        }];
        
        [stateF registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return stateA;
        }];
        
        __block TBStateMachineEvent *receivedEventG;
        [stateG registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            receivedEventG = event;
            return nil;
        }];
        
        NSArray *states = @[stateA, stateB, parallelStates];
        stateMachine.states = states;
        stateMachine.initialState = stateA;
        [stateMachine setUp];
        
        expect(previousStateA).to.beNil;
        
        // moves to state B
        [stateMachine handleEvent:eventA];
        
        expect(nextStateA).to.equal(stateB);
        expect(previousStateB).to.equal(stateA);
        
        // moves to parallel state wrapper
        // enters state C in subStateMachine A
        // enters state E in subStateMachine B
        // enters state G
        [stateMachine handleEvent:eventA];
        
        expect(nextStateB).to.equal(parallelStates);
        expect(previousStateC).to.beNil;
        expect(previousStateE).to.beNil;
        expect(previousStateG).to.equal(stateB);
        
        // moves subStateMachine A from C to state D
        // moves subStateMachine B from E to state F
        // does nothing on state G
        [stateMachine handleEvent:eventA];
        
        expect(nextStateC).to.equal(stateD);
        expect(previousStateD).to.equal(stateC);
        
        expect(nextStateE).to.equal(stateF);
        expect(previousStateF).to.equal(stateE);
        expect(receivedEventG).to.equal(eventA);
        
        [stateMachine handleEvent:eventA data:eventDataA];
        
        // moves back to state A
        expect(nextStateD).to.beNil;
        expect(nextStateF).to.beNil;
        expect(nextStateG).to.beNil;
        expect(previousStateA).to.beNil;
        expect(previousStateDataA[EVENT_DATA_KEY]).to.equal(EVENT_DATA_VALUE);
    });
    
    it(@"handles events sent concurrently from multiple threads", ^AsyncBlock{
        
        // sequence of states as seen by the event handler.
        __block NSMutableString *inputSequence = @"".mutableCopy;
        
        // sequence of states which as they will be actually entered.
        __block NSMutableString *outputSequence = @"".mutableCopy;
        
        NSString *destinationStates = @"abcd";
        
        // processes the data received in event handler blocks of states.
        processEntranceData = ^void(NSString *enteredState, NSDictionary *data) {
            if (data == nil) {
                return;
            }
            
            [outputSequence appendString:enteredState];
            
            // entered state should be identical to moniker transmitted in event data.
            expect(data[@"val"]).to.equal(enteredState);
            
            // call example finished when maximum number of transitions has been performed.
            if (inputSequence.length == destinationStates.length) {
                done();
            }
        };
        
        // processes the data received in enter blocks of states.
        processEventData = ^id<TBStateMachineNode>(NSDictionary *data) {
            NSString *nextState = data[@"val"];
            [inputSequence appendString:nextState];
            
            if ([nextState isEqualToString:@"a"]) {
                return stateA;
            }
            if ([nextState isEqualToString:@"b"]) {
                return stateB;
            }
            if ([nextState isEqualToString:@"c"]) {
                return stateC;
            }
            if ([nextState isEqualToString:@"d"]) {
                return stateD;
            }
            return nil;
        };
        
        // state machine setup
        stateA.enterBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
            processEntranceData(@"a", data);
        };
        
        stateB.enterBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
            processEntranceData(@"b", data);
        };
        
        stateC.enterBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
            processEntranceData(@"c", data);
        };
        
        stateD.enterBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
            processEntranceData(@"d", data);
        };
        
        [stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return processEventData(data);
        }];
        
        [stateB registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return processEventData(data);
        }];
        
        [stateC registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return processEventData(data);
        }];
        
        [stateD registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {
            return processEventData(data);
        }];
        
        stateMachine.states = @[stateA, stateB, stateC, stateD];
        stateMachine.initialState = stateA;
        [stateMachine setUp];
        
        // send all events concurrently.
        dispatch_apply(destinationStates.length, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t idx) {
            NSString *stateName = [destinationStates substringWithRange:NSMakeRange(idx, 1)];
            [stateMachine handleEvent:eventA data:@{@"val" : stateName}];
        });
        
        // sequence of states triggered by sent events should be identical sequence of actually entered states.
        expect(inputSequence).will.equal(outputSequence);
        
    });
    
});

SpecEnd
