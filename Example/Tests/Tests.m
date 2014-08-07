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

beforeEach(^{
    stateMachine = [[TBStateMachine alloc] initWithName:@"StateMachine"];
    stateA = [[TBStateMachineState alloc] initWithName:@"StateA"];
    stateB = [[TBStateMachineState alloc] initWithName:@"StateB"];
    stateC = [[TBStateMachineState alloc] initWithName:@"StateC"];
    stateD = [[TBStateMachineState alloc] initWithName:@"StateD"];
    stateE = [[TBStateMachineState alloc] initWithName:@"StateE"];
    stateF = [[TBStateMachineState alloc] initWithName:@"StateF"];
    stateG = [[TBStateMachineState alloc] initWithName:@"StateG"];
    
    eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
    eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
    eventA = [[TBStateMachineEvent alloc] initWithName:EVENT_NAME_A data:eventDataA];
    eventB = [[TBStateMachineEvent alloc] initWithName:EVENT_NAME_B data:eventDataB];
    
    subStateMachineA = [[TBStateMachine alloc] initWithName:@"SubStateMachineA"];
    subStateMachineB = [[TBStateMachine alloc] initWithName:@"SubStateMachineB"];
    parallelStates = [[TBStateMachineParallelWrapper alloc] initWithName:@"ParallelWrapper"];
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

describe(@"TBStateMachineState", ^{
    
    it(@"registers TBStateMachineEventBlock instances by the name of a provided TBStateMachineEvent instance.", ^{
        
        [stateA addEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event) {
            return nil;
        }];
        
        NSDictionary *registeredEvents = stateA.eventHandlers;
        expect(registeredEvents.allKeys).to.haveCountOf(1);
        expect(registeredEvents).to.contain(eventA.name);
    });
    
    it(@"handles events by returning nil or a TBStateMachineTransition containing source and destination state.", ^{
        
        [stateA addEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event) {
            return nil;
        }];
        
        [stateA addEvent:eventB handler:^id<TBStateMachineNode>(TBStateMachineEvent *event) {
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

    it(@"throws TBStateMachineException when state object does not implement the TBStateMachineNode protocol.", ^{
        id object = [[NSObject alloc] init];
        NSArray *states = @[stateA, stateB, object];
        expect(^{
            [parallelStates setStates:states];
        }).to.raise(TBStateMachineException);
    });
    
    it(@"switches states on all registered states", ^{
    
        __block id<TBStateMachineNode> previousStateA;
        __block TBStateMachineTransition *previousStateTransitionA;
        [stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateA = previousState;
            previousStateTransitionA = transition;
        }];
        
        __block TBStateMachineState *nextStateA;
        [stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateA = nextState;
        }];
        
        __block TBStateMachineState *previousStateB;
        [stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateB = previousState;
        }];
        
        __block id<TBStateMachineNode> nextStateB;
        [stateB setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateB = nextState;
        }];
        
        __block TBStateMachineState *previousStateC;
        [stateC setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateC = previousState;
        }];
        
        __block TBStateMachineState *nextStateC;
        [stateC setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateC = nextState;
        }];
        
        __block TBStateMachineState *previousStateD;
        [stateD setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateD = previousState;
        }];
        
        __block TBStateMachineState *nextStateD;
        [stateD setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateD = nextState;
        }];
        
        
        NSArray *parallelSubStateMachines = @[stateA, stateB, stateC, stateD];
        [parallelStates setStates:parallelSubStateMachines];
        
        [parallelStates enter:stateF transition:nil];

        expect(previousStateA).to.equal(stateF);
        expect(previousStateB).to.equal(stateF);
        expect(previousStateC).to.equal(stateF);
        expect(previousStateD).to.equal(stateF);
        
        [parallelStates exit:stateE transition:nil];
        
        expect(nextStateA).to.equal(stateE);
        expect(nextStateB).to.equal(stateE);
        expect(nextStateC).to.equal(stateE);
        expect(nextStateD).to.equal(stateE);
    });
    
    it(@"handles events on all registered states and will return the first valid follow-up state returned by the contained states.", ^{
        
        __block BOOL stateAHasHandledEvent = NO;
        [stateA addEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event) {
            stateAHasHandledEvent = YES;
            return nil;
        }];
        
        __block BOOL stateBHasHandledEvent = NO;
        [stateB addEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event) {
            stateBHasHandledEvent = YES;
            return nil;
        }];
        
        __block BOOL stateCHasHandledEvent = NO;
        [stateC addEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event) {
            stateCHasHandledEvent = YES;
            return stateE;
        }];
        
        __block BOOL stateDHasHandledEvent = NO;
        [stateD addEvent:eventA handler:^id<TBStateMachineNode>(TBStateMachineEvent *event) {
            stateDHasHandledEvent = YES;
            return stateF;
        }];
        
        NSArray *states = @[stateA, stateB, stateC, stateD];
        [parallelStates setStates:states];
        TBStateMachineTransition *result = [parallelStates handleEvent:eventA];
        
        expect(stateAHasHandledEvent).to.equal(YES);
        expect(stateBHasHandledEvent).to.equal(YES);
        expect(stateCHasHandledEvent).to.equal(YES);
        expect(stateDHasHandledEvent).to.equal(YES);
        
        expect(result).toNot.beNil;
        expect(result.sourceState).to.equal(stateC);
        expect(result.destinationState).to.equal(stateE);
    });


});

describe(@"TBStateMachine", ^{
    
    it(@"throws TBStateMachineException when state object does not implement the TBStateMachineNode protocol.", ^{
        id object = [[NSObject alloc] init];
        NSArray *states = @[stateA, stateB, object];
        expect(^{
            [stateMachine setStates:states];
        }).to.raise(TBStateMachineException);
    });
    
    it(@"throws TBStateMachineException initial state does not exist in set of defined states.", ^{
        NSArray *states = @[stateA, stateB];
        [stateMachine setStates:states];
        expect(^{
            [stateMachine setInitialState:stateC];
        }).to.raise(TBStateMachineException);
        
    });
    
    it(@"throws TBStateMachineException when initial state has not been defined before setup.", ^{
        NSArray *states = @[stateA, stateB];
        [stateMachine setStates:states];
        
        expect(^{
            [stateMachine setUp];
        }).to.raise(TBStateMachineException);
    });
    
    it(@"enters into initial state and exits it", ^{
        
        NSArray *states = @[stateA, stateB];
        
        __block TBStateMachineState *previousStateA;
        __block TBStateMachineTransition *transitionEnterA;
        [stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateA = previousState;
            transitionEnterA = transition;
        }];
        
        __block TBStateMachineState *nextStateA;
        __block TBStateMachineTransition *transitionExitA;
        [stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateA = nextState;
            transitionExitA = transition;
        }];
        
        [stateMachine setStates:states];
        [stateMachine setInitialState:stateA];
        [stateMachine setUp];
        
        expect(previousStateA).to.beNil;
        expect(transitionEnterA.sourceState).to.beNil;
        expect(transitionEnterA.destinationState).to.equal(stateA);
        
        [stateMachine tearDown];
        
        expect(nextStateA).to.beNil;
        expect(transitionExitA.sourceState).to.equal(stateA);
        expect(transitionExitA.destinationState).to.beNil;
    });
    
    it(@"handles an event and switches to the specified state.", ^{
        
        NSArray *states = @[stateA, stateB];
        
        __block TBStateMachineState *previousStateA;
        [stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateA = previousState;
        }];
        
        __block TBStateMachineState *nextStateA;
        [stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateA = nextState;
        }];
        
        __block TBStateMachineState *previousStateB;
        [stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateB = previousState;
        }];
        
        __block TBStateMachineEvent *receivedEvent;
        [stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            receivedEvent = event;
            return stateB;
        }];
        
        [stateMachine setStates:states];
        [stateMachine setInitialState:stateA];
        [stateMachine setUp];
        
        // enters state B
        [stateMachine handleEvent:eventA];
        
        expect(previousStateA).to.beNil;
        expect(nextStateA).to.equal(stateB);
        expect(previousStateB).to.equal(stateA);
    });
    
    it(@"returns an unprocessed transition when the result of a given event can not be handled.", ^{
        
        NSArray *states = @[stateA, stateB];
        
        [stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateC;
        }];
        
        [stateMachine setStates:states];
        [stateMachine setInitialState:stateA];
        [stateMachine setUp];
        
        TBStateMachineTransition *transition = [stateMachine handleEvent:eventA];
        expect(transition.destinationState).to.equal(stateC);
    });
    
    it(@"re-enters a state when allowed by configured.", ^{
        
        NSArray *states = @[stateA];
        
        __block TBStateMachineState *previousStateA;
        [stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateA = previousState;
        }];
        
        __block TBStateMachineState *nextStateA;
        [stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateA = nextState;
        }];

        __block typeof (stateA) weakStateA = stateA;
        [stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return weakStateA;
        }];
        
        [stateMachine setStates:states];
        [stateMachine setInitialState:stateA];
        
        stateMachine.allowReentrantStates = YES;
        [stateMachine setUp];
        
        [stateMachine handleEvent:eventA];
        
        expect(previousStateA).to.equal(stateA);
        expect(nextStateA).to.equal(stateA);
    });
    
    it(@"throws an exception on re-entering a state when not allowed by configuration.", ^{
        
        NSArray *states = @[stateA];
        
        __block TBStateMachineState *previousStateA;
        [stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateA = previousState;
        }];
        
        __block TBStateMachineState *nextStateA;
        [stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateA = nextState;
        }];
        
        __block typeof (stateA) weakStateA = stateA;
        [stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return weakStateA;
        }];
        
        stateMachine.allowReentrantStates = NO;
        [stateMachine setStates:states];
        [stateMachine setInitialState:stateA];
        
        [stateMachine setUp];
        
        expect(^{
            [stateMachine handleEvent:eventA];
        }).to.raise(TBStateMachineException);
    });
    
    it(@"can handle events to switch into and out of sub statemachines.", ^{
        
        __block id<TBStateMachineNode> previousStateA;
        __block TBStateMachineTransition *transitionEnterA;
        [stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateA = previousState;
            transitionEnterA = transition;
        }];
        
        __block TBStateMachineState *nextStateA;
        [stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateA = nextState;
        }];
        
        __block TBStateMachineState *previousStateB;
        [stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateB = previousState;
        }];
        
        __block id<TBStateMachineNode> nextStateB;
        [stateB setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateB = nextState;
        }];
        
        __block TBStateMachineState *previousStateC;
        [stateC setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateC = previousState;
        }];
        
        __block id<TBStateMachineNode> nextStateC;
        [stateC setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateC = nextState;
        }];
        
        __block TBStateMachineState *previousStateD;
        [stateD setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateD = previousState;
        }];
        
        __block id<TBStateMachineNode> nextStateD;
        __block TBStateMachineTransition *transitionExitD;
        [stateD setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateD = nextState;
            transitionExitD = transition;
        }];
        
        NSArray *subStates = @[stateC, stateD];
        [subStateMachineA setStates:subStates];
        [subStateMachineA setInitialState:stateC];
        
        [stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateB;
        }];
        
        [stateB addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return subStateMachineA;
        }];
        
        [stateC addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateD;
        }];
        
        [stateD addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateA;
        }];
        
        NSArray *states = @[stateA, stateB, subStateMachineA];
        [stateMachine setStates:states];
        [stateMachine setInitialState:stateA];
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
        
        transitionEnterA = nil;
        
        // will go back to start
        [stateMachine handleEvent:eventA];
        
        expect(transitionExitD.sourceState).to.equal(stateD);
        expect(transitionExitD.destinationState).to.equal(stateA);
        
        expect(previousStateA).to.equal(subStateMachineA);
        expect(nextStateD).to.beNil;
        
        expect(transitionEnterA.sourceState).to.equal(stateD);
        expect(transitionEnterA.destinationState).to.equal(stateA);
        
        // handled by state A
        [stateMachine handleEvent:eventA];
        
        expect(nextStateA).to.equal(stateB);
        expect(previousStateB).to.equal(stateA);
    });
        
    it(@"can handle events to switch into and out of parallel states and statemachines.", ^{
        
        __block id<TBStateMachineNode> previousStateA;
        __block TBStateMachineTransition *previousStateTransitionA;
        [stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateA = previousState;
            previousStateTransitionA = transition;
        }];
        
        __block TBStateMachineState *nextStateA;
        [stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateA = nextState;
        }];
        
        __block TBStateMachineState *previousStateB;
        [stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateB = previousState;
        }];
        
        __block id<TBStateMachineNode> nextStateB;
        [stateB setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateB = nextState;
        }];
        
        // running in parallel machine wrapper in subStateMachine A
        __block TBStateMachineState *previousStateC;
        [stateC setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateC = previousState;
        }];
        
        __block TBStateMachineState *nextStateC;
        [stateC setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateC = nextState;
        }];
        
        __block TBStateMachineState *previousStateD;
        [stateD setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateD = previousState;
        }];
        
        __block TBStateMachineState *nextStateD;
        [stateD setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateD = nextState;
        }];
        
        // running in parallel machine wrapper in subStateMachine B
        __block TBStateMachineState *previousStateE;
        [stateE setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateE = previousState;
        }];
        
        __block TBStateMachineState *nextStateE;
        [stateE setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateE = nextState;
        }];
        
        __block TBStateMachineState *previousStateF;
        [stateF setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateF = previousState;
        }];
        
        __block TBStateMachineState *nextStateF;
        [stateF setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateF = nextState;
        }];
        
        __block TBStateMachineState *previousStateG;
        [stateG setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
            previousStateG = previousState;
        }];
        
        __block TBStateMachineState *nextStateG;
        [stateF setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
            nextStateG = nextState;
        }];
        
        NSArray *subStatesA = @[stateC, stateD];
        [subStateMachineA setStates:subStatesA];
        [subStateMachineA setInitialState:stateC];
        
        NSArray *subStatesB = @[stateE, stateF];
        [subStateMachineB setStates:subStatesB];
        [subStateMachineB setInitialState:stateE];
        
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB, stateG];
        [parallelStates setStates:parallelSubStateMachines];
        
        [stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateB;
        }];
        
        [stateB addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return parallelStates;
        }];
        
        [stateC addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateD;
        }];
        
        [stateD addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return nil;
        }];
        
        [stateE addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateF;
        }];
        
        [stateF addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            return stateA;
        }];
        
        __block TBStateMachineEvent *receivedEventG;
        [stateG addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
            receivedEventG = event;
            return nil;
        }];
        
        NSArray *states = @[stateA, stateB, parallelStates];
        [stateMachine setStates:states];
        [stateMachine setInitialState:stateA];
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
        
        [stateMachine handleEvent:eventA];
        
        // moves back to state A
        expect(nextStateD).to.beNil;
        expect(nextStateF).to.beNil;
        expect(nextStateG).to.beNil;
        expect(previousStateA).to.beNil;
        expect(previousStateTransitionA.sourceState).to.equal(stateF);
    });
    
});

SpecEnd
