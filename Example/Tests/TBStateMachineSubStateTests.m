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
        stateB = [TBStateMachineState stateWithName:@"B"];
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
        stateB = nil;
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
    
    it(@"executes enter exit blocks if defined", ^{
        
        __block BOOL enterStateA = NO;
        __block BOOL exitStateA = NO;
        __block BOOL enterSubStateA = NO;
        __block BOOL exitSubStateA = NO;
        
        __block TBStateMachineState *weakStateA = stateA;
        stateA.enterBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            enterStateA = YES;
            
            expect(sourceState).to.equal(nil);
            expect(destinationState).to.equal(weakStateA);
        };
        
        stateA.exitBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            exitStateA = YES;
            
            expect(sourceState).to.equal(weakStateA);
            expect(destinationState).to.equal(nil);
        };
        
        subStateMachineA.states = @[stateA];
        TBStateMachineSubState *subStateA = [TBStateMachineSubState subStateWithName:@"subStateA" stateMachine:subStateMachineA];
        
        __block TBStateMachineState *weakSubStateA = subStateA;
        subStateA.enterBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            enterSubStateA = YES;
            
            expect(sourceState).to.equal(nil);
            expect(destinationState).to.equal(weakSubStateA);
        };
        
        subStateA.exitBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            exitSubStateA = YES;
            
            expect(sourceState).to.equal(weakSubStateA);
            expect(destinationState).to.equal(nil);
        };
        
        stateMachine.states = @[subStateA];
        stateMachine.initialState = subStateA;
        
        [stateMachine setUp];
        
        expect(enterStateA).to.equal(YES);
        expect(exitStateA).to.equal(NO);
        expect(enterSubStateA).to.equal(YES);
        expect(exitSubStateA).to.equal(NO);
        
        enterStateA = NO;
        exitStateA = NO;
        enterSubStateA = NO;
        exitSubStateA = NO;
        
        [stateMachine tearDown];
        
        expect(enterStateA).to.equal(NO);
        expect(exitStateA).to.equal(YES);
        expect(enterSubStateA).to.equal(NO);
        expect(exitSubStateA).to.equal(YES);
    });
    
    it(@"handles registered events", ^{
        
        TBStateMachineSubState *subStateA = [TBStateMachineSubState subStateWithName:@"subStateA" stateMachine:subStateMachineA];
        
        __block BOOL enterStateA = NO;
        __block BOOL exitStateA = NO;
        __block BOOL enterStateB = NO;
        __block BOOL enterSubStateA = NO;
        __block BOOL exitSubStateA = NO;
        __block BOOL actionExecuted = NO;
        
        __block TBStateMachineState *weakStateA = stateA;
        stateA.enterBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            enterStateA = YES;
            expect(sourceState).to.equal(nil);
            expect(destinationState).to.equal(weakStateA);
        };
        
        stateA.exitBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            exitStateA = YES;
            expect(sourceState).to.equal(subStateA);
            expect(destinationState).to.equal(stateB);
        };
        
        __block TBStateMachineState *weakStateB = stateB;
        stateB.enterBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            enterStateB = YES;
            expect(sourceState).to.equal(subStateA);
            expect(destinationState).to.equal(weakStateB);
        };
        
        subStateMachineA.states = @[stateA];
        
        __block TBStateMachineState *weakSubStateA = subStateA;
        subStateA.enterBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            enterSubStateA = YES;
            expect(sourceState).to.equal(nil);
            expect(destinationState).to.equal(weakSubStateA);
        };
        
        subStateA.exitBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            exitSubStateA = YES;
            expect(sourceState).to.equal(weakSubStateA);
            expect(destinationState).to.equal(stateB);
        };
        
        [subStateA registerEvent:eventA target:stateB action:^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            actionExecuted = YES;
        } guard:^BOOL(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            return YES;
        }];
        
        stateMachine.states = @[subStateA, stateB];
        stateMachine.initialState = subStateA;
        
        [stateMachine setUp];
        
        expect(enterStateA).to.equal(YES);
        expect(exitStateA).to.equal(NO);
        expect(enterSubStateA).to.equal(YES);
        expect(exitSubStateA).to.equal(NO);
        
        enterStateA = NO;
        exitStateA = NO;
        enterSubStateA = NO;
        exitSubStateA = NO;
        
        [stateMachine scheduleEvent:eventA];
        
        expect(enterStateA).to.equal(NO);
        expect(exitStateA).to.equal(YES);
        expect(actionExecuted).to.equal(YES);
        expect(enterStateB).to.equal(YES);
        
    });
    
});

SpecEnd
