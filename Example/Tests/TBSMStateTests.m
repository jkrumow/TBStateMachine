//
//  TBSMStateTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMState)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_NAME_B = @"DummyEventB";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMStateMachine *stateMachine;
__block TBSMState *stateA;
__block TBSMState *stateB;

__block TBSMEvent *eventA;
__block TBSMEvent *eventB;
__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMParallelState *parallelStates;
__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;


describe(@"TBSMState", ^{
    
    beforeEach(^{
        stateA = [TBSMState stateWithName:@"a"];
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBSMEvent eventWithName:EVENT_NAME_A data:nil];
        eventB = [TBSMEvent eventWithName:EVENT_NAME_B data:nil];
        
        stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"stateMachineA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"stateMachineB"];
        parallelStates = [TBSMParallelState parallelStateWithName:@"parallelStates"];
    });
    
    afterEach(^{
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
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                stateA = [TBSMState stateWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                stateA = [TBSMState stateWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
    });
    
    it(@"returns its name.", ^{
        TBSMState *stateXYZ = [TBSMState stateWithName:@"StateXYZ"];
        expect(stateXYZ.name).to.equal(@"StateXYZ");
    });
    
    it(@"registers TBSMEvent instances with a given target TBSMState.", ^{
        
        [stateA registerEvent:eventA.name target:stateA];
        
        NSDictionary *registeredEvents = stateA.eventHandlers;
        expect(registeredEvents.allKeys).to.haveCountOf(1);
        expect(registeredEvents).to.contain(eventA.name);
        
        NSArray *eventHandlers = registeredEvents[eventA.name];
        expect(eventHandlers.count).to.equal(1);
        TBSMEventHandler *eventHandler = eventHandlers[0];
        expect(eventHandler.target).to.equal(stateA);
    });
    
    describe(@"Exception handling when registering and deferring events.", ^{
        
        it(@"throws an exception when attempting to register an event which was already marked as deferred.", ^{
            
            [stateA deferEvent:eventA.name];
            
            expect(^{
                [stateA registerEvent:eventA.name target:stateB];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws an exception when attempting to defer an event which was already registered.", ^{
            
            [stateA registerEvent:eventA.name target:stateB];
            
            expect(^{
                [stateA deferEvent:eventA.name];
            }).to.raise(TBSMException);
            
        });
    });
    
    it(@"should return an array of TBSMEventHandler instances containing source and destination state for a given event.", ^{
        
        [stateA registerEvent:eventA.name target:nil kind:TBSMTransitionInternal];
        [stateA registerEvent:eventB.name target:stateB];
        
        NSArray *resultA = [stateA eventHandlersForEvent:eventA];
        expect(resultA).to.beNil;
        
        NSArray *resultB = [stateA eventHandlersForEvent:eventB];
        expect(resultB.count).to.equal(1);
        TBSMEventHandler *eventHandlerB = resultB[0];
        expect(eventHandlerB.target).to.equal(stateB);
    });
    
    it(@"returns its path inside the state machine hierarchy containing all parent nodes in descending order", ^{
        
        subStateMachineB.states = @[stateA];
        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"subStateB"];
        subStateB.stateMachine = subStateMachineB;
        subStateMachineA.states = @[subStateB];
        
        parallelStates.stateMachines = @[subStateMachineA];
        stateMachine.states = @[parallelStates];
        stateMachine.initialState = parallelStates;
        
        NSArray *path = [stateA path];
        
        expect(path.count).to.equal(6);
        expect(path[0]).to.equal(stateMachine);
        expect(path[1]).to.equal(parallelStates);
        expect(path[2]).to.equal(subStateMachineA);
        expect(path[3]).to.equal(subStateB);
        expect(path[4]).to.equal(subStateMachineB);
        expect(path[5]).to.equal(stateA);
    });
});

SpecEnd