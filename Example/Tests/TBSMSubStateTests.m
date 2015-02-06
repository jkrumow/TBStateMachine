//
//  TBSMSubStateTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMSubState)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_NAME_B = @"DummyEventB";
NSString * const EVENT_NAME_C = @"DummyEventC";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMSubState *subState;
__block TBSMStateMachine *stateMachine;
__block TBSMState *stateA;
__block TBSMState *stateB;

__block TBSMEvent *eventA;
__block TBSMEvent *eventB;
__block TBSMEvent *eventC;
__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMParallelState *parallelStates;
__block NSDictionary *eventDataA;
__block NSDictionary *eventDataB;


describe(@"TBSMSubState", ^{
    
    beforeEach(^{
        stateA = [TBSMState stateWithName:@"a"];
        stateB = [TBSMState stateWithName:@"B"];
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventDataB = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBSMEvent eventWithName:EVENT_NAME_A data:nil];
        eventB = [TBSMEvent eventWithName:EVENT_NAME_B data:nil];
        eventC = [TBSMEvent eventWithName:EVENT_NAME_C data:nil];
        
        stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"stateMachineA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"stateMachineB"];
        parallelStates = [TBSMParallelState parallelStateWithName:@"parallelStates"];
        
        subState = [TBSMSubState subStateWithName:@"subState"];
        subState.stateMachine = subStateMachineA;
    });
    
    afterEach(^{
        subState = nil;
        stateA = nil;
        stateB = nil;
        eventDataA = nil;
        eventDataB = nil;
        eventA = nil;
        eventB = nil;
        eventC = nil;
        
        stateMachine = nil;
        subStateMachineA = nil;
        subStateMachineB = nil;
        parallelStates = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                subState = [TBSMSubState subStateWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                subState = [TBSMSubState subStateWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when stateMachine is nil.", ^{
            
            expect(^{
                subState = [TBSMSubState subStateWithName:@"subState"];
                [subState enter:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                subState = [TBSMSubState subStateWithName:@"subState"];
                [subState exit:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
        });
        
    });
    
    it(@"registers events by the name of a provided TBSMEvent instance.", ^{
        [subState registerEvent:eventA.name target:nil kind:TBSMTransitionInternal];
        
        NSDictionary *registeredEvents = subState.eventHandlers;
        expect(registeredEvents.allKeys).to.haveCountOf(1);
        expect(registeredEvents).to.contain(eventA.name);
    });
    
    it(@"returns its path inside the state machine hierarchy containing all parent nodes in descending order", ^{
        
        subStateMachineB.states = @[stateA];
        TBSMSubState *subStateB = [TBSMSubState subStateWithName:@"subStateB"];
        subStateB.stateMachine = subStateMachineB;
        subStateMachineA.states = @[subStateB];
        
        parallelStates.stateMachines = @[subStateMachineA];
        stateMachine.states = @[parallelStates];
        stateMachine.initialState = parallelStates;
        
        NSArray *path = [subStateB path];
        
        expect(path.count).to.equal(4);
        expect(path[0]).to.equal(stateMachine);
        expect(path[1]).to.equal(parallelStates);
        expect(path[2]).to.equal(subStateMachineA);
        expect(path[3]).to.equal(subStateB);
    });
    
    it(@"executes enter exit blocks if defined", ^{
        
        __block BOOL enterStateA = NO;
        __block BOOL exitStateA = NO;
        __block BOOL enterSubStateA = NO;
        __block BOOL exitSubStateA = NO;
        
        subStateMachineA.states = @[stateA];
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"subStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        __block TBSMState *weakSubStateA = subStateA;
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            enterSubStateA = YES;
            
            expect(sourceState).to.equal(nil);
            expect(targetState).to.equal(weakSubStateA);
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            exitSubStateA = YES;
            
            expect(sourceState).to.equal(weakSubStateA);
            expect(targetState).to.equal(nil);
        };
        
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            enterStateA = YES;
            
            expect(sourceState).to.equal(nil);
            expect(targetState).to.equal(subStateA);
        };
        
        __block TBSMState *weakStateA = stateA;
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            exitStateA = YES;
            
            expect(sourceState).to.equal(weakStateA);
            expect(targetState).to.equal(nil);
        };
        
        stateMachine.states = @[subStateA];
        stateMachine.initialState = subStateA;
        
        [stateMachine setUp:nil];
        
        expect(enterStateA).to.equal(YES);
        expect(exitStateA).to.equal(NO);
        expect(enterSubStateA).to.equal(YES);
        expect(exitSubStateA).to.equal(NO);
        
        enterStateA = NO;
        exitStateA = NO;
        enterSubStateA = NO;
        exitSubStateA = NO;
        
        [stateMachine tearDown:nil];
        
        expect(enterStateA).to.equal(NO);
        expect(exitStateA).to.equal(YES);
        expect(enterSubStateA).to.equal(NO);
        expect(exitSubStateA).to.equal(YES);
    });
    
    it(@"handles registered events", ^{
        
        TBSMSubState *subStateA = [TBSMSubState subStateWithName:@"subStateA"];
        subStateA.stateMachine = subStateMachineA;
        
        __block BOOL enterStateA = NO;
        __block BOOL exitStateA = NO;
        __block BOOL enterStateB = NO;
        __block BOOL enterSubStateA = NO;
        __block BOOL exitSubStateA = NO;
        __block BOOL actionExecuted = NO;
        
        __block TBSMState *weakSubStateA = subStateA;
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            enterStateA = YES;
            expect(sourceState).to.equal(nil);
            expect(targetState).to.equal(weakSubStateA);
        };
        
        __block TBSMState *weakStateA = stateA;
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            exitStateA = YES;
            expect(sourceState).to.equal(weakStateA);
            expect(targetState).to.equal(nil);
        };
        
        __block TBSMState *weakStateB = stateB;
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            enterStateB = YES;
            expect(sourceState).to.equal(subStateA);
            expect(targetState).to.equal(weakStateB);
        };
        
        subStateMachineA.states = @[stateA];
        
        subStateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            enterSubStateA = YES;
            expect(sourceState).to.equal(nil);
            expect(targetState).to.equal(weakSubStateA);
        };
        
        subStateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            exitSubStateA = YES;
            expect(sourceState).to.equal(weakSubStateA);
            expect(targetState).to.equal(stateB);
        };
        
        __block BOOL subStateExecutedEventA = NO;
        [subStateA registerEvent:eventA.name
                          target:nil
                            kind:TBSMTransitionInternal
                          action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                              subStateExecutedEventA = YES;
                          }];
        
        __block BOOL stateExecutedEventA = NO;
        [stateA registerEvent:eventA.name
                       target:nil
                         kind:TBSMTransitionInternal
                       action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           stateExecutedEventA = YES;
                       }];
        
        __block BOOL subStateAExecutedEventB = NO;
        [subStateA registerEvent:eventB.name
                          target:nil
                            kind:TBSMTransitionInternal
                          action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                              subStateAExecutedEventB = YES;
                          }];
        
        __block BOOL stateAExecutedEventB = NO;
        [stateA registerEvent:eventB.name
                       target:nil
                         kind:TBSMTransitionInternal
                       action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           stateAExecutedEventB = YES;
                       } guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                           return NO;
                       }];
        
        [subStateA registerEvent:eventC.name
                          target:stateB
                            kind:TBSMTransitionExternal
                          action:^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                              actionExecuted = YES;
                          }];
        
        stateMachine.states = @[subStateA, stateB];
        stateMachine.initialState = subStateA;
        
        [stateMachine setUp:nil];
        
        expect(enterStateA).to.equal(YES);
        expect(exitStateA).to.equal(NO);
        expect(enterSubStateA).to.equal(YES);
        expect(exitSubStateA).to.equal(NO);
        
        enterStateA = NO;
        exitStateA = NO;
        enterSubStateA = NO;
        exitSubStateA = NO;
        
        // should be handled by state A, not bubble up to sub state A
        [stateMachine scheduleEvent:eventA];
        
        expect(subStateExecutedEventA).to.equal(NO);
        expect(stateExecutedEventA).to.equal(YES);
        
        // should be handled by state A but blocked by guard, handled by sub state A instead
        [stateMachine scheduleEvent:eventB];
        
        expect(stateAExecutedEventB).to.equal(NO);
        expect(subStateAExecutedEventB).to.equal(YES);
        
        // should not be handled by state A, but bubble up to sub state A -> move to state B
        [stateMachine scheduleEvent:eventC];
        
        expect(enterStateA).to.equal(NO);
        expect(exitStateA).to.equal(YES);
        expect(actionExecuted).to.equal(YES);
        expect(enterStateB).to.equal(YES);
    });
});

SpecEnd
