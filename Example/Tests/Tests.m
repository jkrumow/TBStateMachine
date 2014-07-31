//
//  TBStateMachineTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 08/01/2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(StateMachine)

NSString * const EVENT_NAME = @"DummyEvent";
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
__block TBStateMachine *subStateMachineA;
__block TBStateMachine *subStateMachineB;
__block TBStateMachineParallelWrapper *parallelStates;
__block NSDictionary *eventData;

beforeEach(^{
    stateMachine = [[TBStateMachine alloc] initWithName:@"StateMachine"];
    stateA = [[TBStateMachineState alloc] initWithName:@"StateA"];
    stateB = [[TBStateMachineState alloc] initWithName:@"StateB"];
    stateC = [[TBStateMachineState alloc] initWithName:@"StateC"];
    stateD = [[TBStateMachineState alloc] initWithName:@"StateD"];
    stateE = [[TBStateMachineState alloc] initWithName:@"StateE"];
    stateF = [[TBStateMachineState alloc] initWithName:@"StateF"];
    stateG = [[TBStateMachineState alloc] initWithName:@"StateG"];
    eventData = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
    eventA = [[TBStateMachineEvent alloc] initWithName:EVENT_NAME data:eventData];
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
    
    eventData = nil;
    eventA = nil;
    
    [subStateMachineA tearDown];
    [subStateMachineB tearDown];
    subStateMachineB = nil;
    parallelStates = nil;
});

describe(@"Will throw exception when state object has wrong type.", ^{

    it(@"throws TBStateMachineException", ^{
        id object = [[NSObject alloc] init];
        NSArray *states = @[stateA, stateB, object];
        expect(^{
            [stateMachine setStates:states];
        }).to.raise(TBStateMachineException);
    });

    
});

describe(@"Will throw exception when initial state is not defined.", ^{
    
    it(@"throws TBStateMachineException", ^{
        NSArray *states = @[stateA, stateB];
        [stateMachine setStates:states];
        expect(^{
            [stateMachine setInitialState:stateC];
        }).to.raise(TBStateMachineException);
        
    });
    
});

describe(@"Will throw exception when state switches before setup.", ^{
    
    it(@"throws TBStateMachineException", ^{
        NSArray *states = @[stateA, stateB];
        [stateMachine setStates:states];
        
        expect(^{
            [stateMachine setUp];
        }).to.raise(TBStateMachineException);
        
    });
    
});

describe(@"Will correctly set up and tear down statemachine.", ^{

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

});

SpecEnd

/*
- (void)testHandleEvent
{
    __weak typeof(self) weakSelf = self;
    
    NSArray *states = @[_stateA, _stateB];
    
    __block TBStateMachineState *previousStateA;
    [_stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateA = previousState;
    }];
    
    __block TBStateMachineState *nextStateA;
    [_stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateA = nextState;
    }];
    
    __block TBStateMachineState *previousStateB;
    [_stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateB = previousState;
    }];
    
    __block TBStateMachineEvent *receivedEvent;
    [_stateA addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        receivedEvent = event;
        return weakSelf.stateB;
    }];
    
    [_stateMachine setStates:states];
    [_stateMachine setInitialState:_stateA];
    [_stateMachine setUp];
    
    // enters state B
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertNil(previousStateA, @"previousStateA should be nil.");
    XCTAssertEqual(nextStateA, _stateB, @"nextStateA should be stateB.");
    XCTAssertEqual(previousStateB, _stateA, @"previousStateB should be stateA.");
}

- (void)testSwitchStateToNonExistentState
{
    __weak typeof(self) weakSelf = self;
    
    NSArray *states = @[_stateA, _stateB];
    
    [_stateA addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateC;
    }];
    
    [_stateMachine setStates:states];
    [_stateMachine setInitialState:_stateA];
    [_stateMachine setUp];
    
    TBStateMachineTransition *transition = [_stateMachine handleEvent:_eventA];
    XCTAssertEqual(transition.destinationState, _stateC, @"Should return transition with destination state equal to stateC.");
}

- (void)testSwitchStateWithReEntryAllowed
{
    __weak typeof(self) weakSelf = self;
    
    NSArray *states = @[_stateA, _stateB];
    
    __block TBStateMachineState *previousStateA;
    [_stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateA = previousState;
    }];
    
    __block TBStateMachineState *nextStateA;
    [_stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateA = nextState;
    }];
    
    __block TBStateMachineState *previousStateB;
    [_stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateB = previousState;
    }];
    
    __block TBStateMachineState *nextStateB;
    [_stateB setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateB = nextState;
    }];
    
    [_stateA addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateB;
    }];
    
    [_stateB addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateB;
    }];
    
    [_stateMachine setStates:states];
    [_stateMachine setInitialState:_stateA];
    
    _stateMachine.allowReentrantStates = YES;
    [_stateMachine setUp];
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertNil(previousStateA, @"previousStateA should be nil.");
    XCTAssertEqual(nextStateA, _stateB, @"nextStateA should be stateB.");
    XCTAssertEqual(previousStateB, _stateA, @"previousStateB should be stateA.");
    
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(previousStateB, _stateB, @"previousStateB should be stateB.");
    XCTAssertEqual(nextStateB, _stateB, @"nextStateB should be stateB.");
}

- (void)testSwitchStateWithReEntryDisallowed
{
    __weak typeof (self) weakSelf = self;
    
    NSArray *states = @[_stateA, _stateB];
    
    __block TBStateMachineState *previousStateA;
    [_stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateA = previousState;
    }];
    
    __block TBStateMachineState *nextStateA;
    [_stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateA = nextState;
    }];
    
    __block TBStateMachineState *previousStateB;
    [_stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateB = previousState;
    }];
    
    [_stateA addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateB;
    }];
    
    [_stateB addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateB;
    }];
    
    [_stateMachine setStates:states];
    [_stateMachine setInitialState:_stateA];
    
    [_stateMachine setUp];
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertNil(previousStateA, @"previousStateA should be nil.");
    XCTAssertEqual(nextStateA, _stateB, @"nextStateA should be stateB.");
    XCTAssertEqual(previousStateB, _stateA, @"previousStateB should be stateA.");
    
    XCTAssertThrowsSpecificNamed([_stateMachine handleEvent:_eventA], NSException, TBStateMachineException, @"Should throw an NSException named 'TBStateMachineException'.");
}

- (void)testSubStateMachine
{
    __weak typeof(self) weakSelf = self;
    
    __block id<TBStateMachineNode> previousStateA;
    __block TBStateMachineTransition *transitionEnterA;
    [_stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateA = previousState;
        transitionEnterA = transition;
    }];
    
    __block TBStateMachineState *nextStateA;
    [_stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateA = nextState;
    }];
    
    __block TBStateMachineState *previousStateB;
    [_stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateB = previousState;
    }];
    
    __block id<TBStateMachineNode> nextStateB;
    [_stateB setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateB = nextState;
    }];
    
    __block TBStateMachineState *previousStateC;
    [_stateC setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateC = previousState;
    }];
    
    __block id<TBStateMachineNode> nextStateC;
    [_stateC setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateC = nextState;
    }];
    
    __block TBStateMachineState *previousStateD;
    [_stateD setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateD = previousState;
    }];
    
    __block id<TBStateMachineNode> nextStateD;
    __block TBStateMachineTransition *transitionExitD;
    [_stateD setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateD = nextState;
        transitionExitD = transition;
    }];
    
    NSArray *subStates = @[_stateC, _stateD];
    [_subStateMachineA setStates:subStates];
    [_subStateMachineA setInitialState:_stateC];
    
    [_stateA addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateB;
    }];
    
    [_stateB addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.subStateMachineA;
    }];
    
    [_stateC addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateD;
    }];
    
    [_stateD addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateA;
    }];
    
    NSArray *states = @[_stateA, _stateB, _subStateMachineA];
    [_stateMachine setStates:states];
    [_stateMachine setInitialState:_stateA];
    [_stateMachine setUp];
    
    XCTAssertNil(previousStateA, @"previousStateA should be nil.");
    
    // moves to state B
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(nextStateA, _stateB, @"nextStateA should be stateB.");
    XCTAssertEqual(previousStateB, _stateA, @"previousStateB should be stateA.");
    
    // moves to state C
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(nextStateB, _subStateMachineA, @"nextStateB should be subStateMachineA.");
    XCTAssertNil(previousStateC, @"previousStateC should be nil.");
    
    // moves to state D
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(nextStateC, _stateD, @"nextStateC should be stateD.");
    XCTAssertEqual(previousStateD, _stateC, @"previousStateD should be stateC.");
    
    transitionEnterA = nil;
    
    // will go back to start
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(transitionExitD.sourceState, _stateD, @"source state of transitionExitD should be stateD");
    XCTAssertEqual(transitionExitD.destinationState, _stateA, @"destination state of transitionExitD should be stateA");
    
    XCTAssertEqual(previousStateA, _subStateMachineA, @"previousStateA should be subStateMachineA.");
    XCTAssertNil(nextStateD, @"nextStateD should be nil.");
    
    XCTAssertEqual(transitionEnterA.sourceState, _stateD, @"source state of transitionEnterA should be _subStateMachineA");
    XCTAssertEqual(transitionEnterA.destinationState, _stateA, @"destination state of transitionEnterA should be stateA.");
    
    // handled by state A
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(nextStateA, _stateB, @"nextStateA should be stateB.");
    XCTAssertEqual(previousStateB, _stateA, @"previousStateB should be stateA.");
}

- (void)testParallelAndSubStateMachines
{
    __weak typeof(self) weakSelf = self;
    
    __block id<TBStateMachineNode> previousStateA;
    __block TBStateMachineTransition *previousStateTransitionA;
    [_stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateA = previousState;
        previousStateTransitionA = transition;
    }];
    
    __block TBStateMachineState *nextStateA;
    [_stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateA = nextState;
    }];
    
    __block TBStateMachineState *previousStateB;
    [_stateB setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateB = previousState;
    }];
    
    __block id<TBStateMachineNode> nextStateB;
    [_stateB setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateB = nextState;
    }];
    
    // running in parallel machine wrapper in subStateMachine A
    __block TBStateMachineState *previousStateC;
    [_stateC setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateC = previousState;
    }];
    
    __block TBStateMachineState *nextStateC;
    [_stateC setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateC = nextState;
    }];
    
    __block TBStateMachineState *previousStateD;
    [_stateD setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateD = previousState;
    }];
    
    __block TBStateMachineState *nextStateD;
    [_stateD setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateD = nextState;
    }];
    
    // running in parallel machine wrapper in subStateMachine B
    __block TBStateMachineState *previousStateE;
    [_stateE setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateE = previousState;
    }];
    
    __block TBStateMachineState *nextStateE;
    [_stateE setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateE = nextState;
    }];
    
    __block TBStateMachineState *previousStateF;
    [_stateF setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateF = previousState;
    }];
    
    __block TBStateMachineState *nextStateF;
    [_stateF setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateF = nextState;
    }];
    
    __block TBStateMachineState *previousStateG;
    [_stateG setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        previousStateG = previousState;
    }];
    
    __block TBStateMachineState *nextStateG;
    [_stateF setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        nextStateG = nextState;
    }];
    
    NSArray *subStatesA = @[_stateC, _stateD];
    [_subStateMachineA setStates:subStatesA];
    [_subStateMachineA setInitialState:_stateC];
    
    NSArray *subStatesB = @[_stateE, _stateF];
    [_subStateMachineB setStates:subStatesB];
    [_subStateMachineB setInitialState:_stateE];
    
    NSArray *parallelSubStateMachines = @[_subStateMachineA, _subStateMachineB, _stateG];
    [_parallelStates setStates:parallelSubStateMachines];
    
    [_stateA addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateB;
    }];
    
    [_stateB addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.parallelStates;
    }];
    
    [_stateC addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateD;
    }];
    
    [_stateD addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return nil;
    }];
    
    [_stateE addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateF;
    }];
    
    [_stateF addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        return weakSelf.stateA;
    }];
    
    __block TBStateMachineEvent *receivedEventG;
    [_stateG addEvent:_eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
        receivedEventG = event;
        return nil;
    }];
    
    NSArray *states = @[_stateA, _stateB, _parallelStates];
    [_stateMachine setStates:states];
    [_stateMachine setInitialState:_stateA];
    [_stateMachine setUp];
    
    XCTAssertNil(previousStateA, @"previousStateA should be nil.");
    
    // moves to state B
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(nextStateA, _stateB, @"nextStateA should be stateB.");
    XCTAssertEqual(previousStateB, _stateA, @"previousStateB should be stateA.");
    
    // moves to parallel state wrapper
    // enters state C in subStateMachine A
    // enters state E in subStateMachine B
    // enters state G
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(nextStateB, _parallelStates, @"nextStateB should be parallelMachines.");
    
    XCTAssertNil(previousStateC, @"previousStateC should be nil.");
    XCTAssertNil(previousStateE, @"previousStateE should be nil.");
    XCTAssertEqual(previousStateG, _stateB, @"previousStateG should be stateB.");
    
    // moves subStateMachine A from C to state D
    // moves subStateMachine B from E to state F
    // does nothing on state G
    [_stateMachine handleEvent:_eventA];
    
    XCTAssertEqual(nextStateC, _stateD, @"nextStateC should be stateD.");
    XCTAssertEqual(previousStateD, _stateC, @"previousStateD should be stateC.");
    
    XCTAssertEqual(nextStateE, _stateF, @"nextStateE should be stateF.");
    XCTAssertEqual(previousStateF, _stateE, @"previousStateF should be stateE.");
    XCTAssertEqual(receivedEventG, _eventA, @"receivedEventG should be eventA");
    
    [_stateMachine handleEvent:_eventA];
    
    // moves back to state A
    XCTAssertNil(nextStateD, @"nextStateD should be nil.");
    XCTAssertNil(nextStateF, @"nextStateF should be nil.");
    XCTAssertNil(nextStateG, @"nextStateG should be nil.");
    XCTAssertNil(previousStateA, @"previousStateA should be nil.");
    XCTAssertEqual(previousStateTransitionA.sourceState, _stateF, @"previousStateTransitionA.sourceState should be stateF.");
}
*/