//
//  TBSMStateTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.14.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
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
    
    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMState stateWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws a `TBSMException` when attempting to add event handler which makes no sense.", ^{
            
            expect(^{
                [a addHandlerForEvent:EVENT_NAME_A target:b kind:TBSMTransitionInternal];
            }).to.raise(TBSMException);
            
            expect(^{
                [a addHandlerForEvent:EVENT_NAME_A target:b kind:TBSMTransitionInternal];
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
    
    it(@"should return YES if an event can be handled.", ^{
        
        [a addHandlerForEvent:EVENT_NAME_A target:a kind:TBSMTransitionInternal];
        BOOL canHandle = [a hasHandlerForEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        expect(canHandle).to.equal(YES);
        canHandle = [a hasHandlerForEvent:[TBSMEvent eventWithName:EVENT_NAME_B data:nil]];
        expect(canHandle).to.equal(NO);
        
    });
    
    it(@"should return an array of TBSMEventHandler instances containing source and target state for a given event.", ^{
        
        [a addHandlerForEvent:EVENT_NAME_A target:a kind:TBSMTransitionInternal];
        [a addHandlerForEvent:EVENT_NAME_B target:a];
        
        NSArray *resultA = [a eventHandlersForEvent:[TBSMEvent eventWithName:EVENT_NAME_A data:nil]];
        expect(resultA).to.beNil;
        
        NSArray *resultB = [a eventHandlersForEvent:[TBSMEvent eventWithName:EVENT_NAME_B data:nil]];
        expect(resultB.count).to.equal(1);
        TBSMEventHandler *eventHandlerB = resultB[0];
        expect(eventHandlerB.target).to.equal(a);
    });
    
    it(@"returns its path inside the state machine hierarchy containing all parent nodes in descending order", ^{
        
        TBSMSubState *s = [TBSMSubState subStateWithName:@"s"];
        s.states = @[b];
        
        TBSMParallelState *p = [TBSMParallelState parallelStateWithName:@"p"];
        p.states = @[@[s]];
        
        TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        stateMachine.states = @[p];
        
        NSArray *path = [b path];
        
        expect(path.count).to.equal(6);
        expect(path[0]).to.equal(stateMachine);
        expect(path[1]).to.equal(p);
        expect(path[2]).to.equal(p.stateMachines.firstObject);
        expect(path[3]).to.equal(s);
        expect(path[4]).to.equal(s.stateMachine);
        expect(path[5]).to.equal(b);
    });
});

SpecEnd
