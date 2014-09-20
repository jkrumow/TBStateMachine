//
//  TBStateMachineSubStateTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(StateMachineSubState)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_NAME_B = @"DummyEventB";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBStateMachineSubState *subState;
__block TBStateMachine *stateMachine;
__block TBStateMachineState *stateA;
__block TBStateMachineState *stateB;

__block TBStateMachineEvent *eventA;
__block TBStateMachineEvent *eventB;
__block TBStateMachine *subStateMachineA;
__block TBStateMachine *subStateMachineB;
__block TBStateMachineParallelState *parallelStates;
__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;


describe(@"TBStateMachineSubState", ^{
    
    beforeEach(^{
        stateA = [TBStateMachineState stateWithName:@"a"];
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBStateMachineEvent eventWithName:EVENT_NAME_A];
        eventB = [TBStateMachineEvent eventWithName:EVENT_NAME_B];
        
        stateMachine = [TBStateMachine stateMachineWithName:@"stateMachine"];
        subStateMachineA = [TBStateMachine stateMachineWithName:@"stateMachineA"];
        subStateMachineB = [TBStateMachine stateMachineWithName:@"stateMachineB"];
        parallelStates = [TBStateMachineParallelState parallelStateWithName:@"parallelStates"];
        
        subState = [TBStateMachineSubState subStateWithName:@"subState" stateMachine:subStateMachineA];
    });
    
    afterEach(^{
        subState = nil;
        stateA = nil;
        eventDataA = nil;
        eventDataB = nil;
        eventA = nil;
        eventB = nil;
        
        stateMachine = nil;
        subStateMachineA = nil;
        subStateMachineB = nil;
        parallelStates = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                subState = [TBStateMachineSubState subStateWithName:nil stateMachine:subStateMachineA];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                subState = [TBStateMachineSubState subStateWithName:@"" stateMachine:subStateMachineA];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when stateMachine is nil.", ^{
            
            expect(^{
                subState = [TBStateMachineSubState subStateWithName:@"subState" stateMachine:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
    });
    
    it(@"registers TBStateMachineEventBlock instances by the name of a provided TBStateMachineEvent instance.", ^{
        
        [subState registerEvent:eventA target:nil];
        
        NSDictionary *registeredEvents = subState.eventHandlers;
        expect(registeredEvents.allKeys).to.haveCountOf(1);
        expect(registeredEvents).to.contain(eventA.name);
    });
    
    it(@"handles events by returning nil or a TBStateMachineTransition containing source and destination state.", ^{
        
        [subState registerEvent:eventA target:nil];
        [subState registerEvent:eventB target:stateB];
        
        TBStateMachineTransition *resultA = [subState handleEvent:eventA];
        expect(resultA).to.beNil;
        
        TBStateMachineTransition *resultB = [subState handleEvent:eventB];
        expect(resultB.sourceState).to.equal(stateA);
        expect(resultB.destinationState).to.equal(stateB);
    });
    
    it(@"returns its path inside the state machine hierarchy", ^{
        
        subStateMachineB.states = @[stateA];
        TBStateMachineSubState *subStateB = [TBStateMachineSubState subStateWithName:@"subStateB" stateMachine:subStateMachineB];
        subStateMachineA.states = @[subStateB];
        
        parallelStates.states = @[subStateMachineA];
        stateMachine.states = @[parallelStates];
        stateMachine.initialState = parallelStates;
        
        NSArray *path = [subStateB getPath];
        
        expect(path.count).to.equal(3);
        expect(path[0]).to.equal(stateMachine);
        expect(path[1]).to.equal(parallelStates);
        expect(path[2]).to.equal(subStateMachineA);
    });
    
});

SpecEnd
