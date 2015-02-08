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

__block TBSMState *a;
__block TBSMState *b;

describe(@"TBSMState", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMState stateWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMState stateWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
    });
    
    it(@"returns its name.", ^{
        TBSMState *stateXYZ = [TBSMState stateWithName:@"StateXYZ"];
        expect(stateXYZ.name).to.equal(@"StateXYZ");
    });
    
    it(@"registers TBSMEvent instances with a given target TBSMState.", ^{
        
        [a addHandlerForEvent:EVENT_NAME_A target:a];
        
        NSDictionary *registeredEvents = a.eventHandlers;
        expect(registeredEvents.allKeys).to.haveCountOf(1);
        expect(registeredEvents).to.contain(EVENT_NAME_A);
        
        NSArray *eventHandlers = registeredEvents[EVENT_NAME_A];
        expect(eventHandlers.count).to.equal(1);
        TBSMEventHandler *eventHandler = eventHandlers[0];
        expect(eventHandler.target).to.equal(a);
    });
    
    describe(@"Exception handling when registering and deferring events.", ^{
        
        it(@"throws an exception when attempting to register an event which was already marked as deferred.", ^{
            
            [a deferEvent:EVENT_NAME_A];
            
            expect(^{
                [a addHandlerForEvent:EVENT_NAME_A target:a];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws an exception when attempting to defer an event which was already registered.", ^{
            
            [a addHandlerForEvent:EVENT_NAME_A target:a];
            
            expect(^{
                [a deferEvent:EVENT_NAME_A];
            }).to.raise(TBSMException);
            
        });
    });
    
    it(@"should return an array of TBSMEventHandler instances containing source and destination state for a given event.", ^{
        
        [a addHandlerForEvent:EVENT_NAME_A target:nil kind:TBSMTransitionInternal];
        [a addHandlerForEvent:EVENT_NAME_B target:a];
        
        NSArray *resultA = [a eventHandlersForEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        expect(resultA).to.beNil;
        
        NSArray *resultB = [a eventHandlersForEvent:[TBSMEvent eventWithName:EVENT_NAME_B data:nil]];
        expect(resultB.count).to.equal(1);
        TBSMEventHandler *eventHandlerB = resultB[0];
        expect(eventHandlerB.target).to.equal(a);
    });
    
    it(@"returns its path inside the state machine hierarchy containing all parent nodes in descending order", ^{
        
        TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        TBSMStateMachine *subStateMachineA = [TBSMStateMachine stateMachineWithName:@"stateMachineA"];
        TBSMStateMachine *subStateMachineB = [TBSMStateMachine stateMachineWithName:@"stateMachineB"];
        TBSMParallelState *parallelStates = [TBSMParallelState parallelStateWithName:@"parallelStates"];

        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"subStateB"];
        
        subStateMachineB.states = @[b];
        subStateB.stateMachine = subStateMachineB;
        subStateMachineA.states = @[subStateB];
        
        parallelStates.stateMachines = @[subStateMachineA];
        stateMachine.states = @[parallelStates];
        
        NSArray *path = [b path];
        
        expect(path.count).to.equal(6);
        expect(path[0]).to.equal(stateMachine);
        expect(path[1]).to.equal(parallelStates);
        expect(path[2]).to.equal(subStateMachineA);
        expect(path[3]).to.equal(subStateB);
        expect(path[4]).to.equal(subStateMachineB);
        expect(path[5]).to.equal(b);
    });
});

SpecEnd