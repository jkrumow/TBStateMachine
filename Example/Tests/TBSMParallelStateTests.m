//
//  TBSMParallelStateTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 01.08.2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMParallelState)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBSMState *stateA;
__block TBSMState *stateB;
__block TBSMState *stateC;
__block TBSMState *stateD;
__block TBSMState *stateE;
__block TBSMState *stateF;

__block TBSMEvent *eventA;
__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMParallelState *parallelStates;
__block NSDictionary *eventDataA;


describe(@"TBSMParallelState", ^{
    
    beforeEach(^{
        parallelStates = [TBSMParallelState parallelStateWithName:@"ParallelWrapper"];
        stateA = [TBSMState stateWithName:@"a"];
        stateB = [TBSMState stateWithName:@"b"];
        stateC = [TBSMState stateWithName:@"c"];
        stateD = [TBSMState stateWithName:@"d"];
        stateE = [TBSMState stateWithName:@"e"];
        stateF = [TBSMState stateWithName:@"f"];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"SubA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"SubB"];
        
        eventDataA = @{EVENT_DATA_KEY : EVENT_DATA_VALUE};
        eventA = [TBSMEvent eventWithName:EVENT_NAME_A data:nil];
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
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                parallelStates = [TBSMParallelState parallelStateWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                parallelStates = [TBSMParallelState parallelStateWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws TBSMException when state object is not of type TBSM.", ^{
            
            id object = [[NSObject alloc] init];
            NSArray *states = @[subStateMachineA, subStateMachineB, object];
            expect(^{
                parallelStates.stateMachines = states;
            }).to.raise(TBSMException);
        });
        
    });
    
    it(@"returns its states.", ^{
        subStateMachineA.states = @[stateA];
        subStateMachineB.states = @[stateB];
        parallelStates.stateMachines = @[subStateMachineA, subStateMachineB];
        
        expect(parallelStates.stateMachines).notTo.beNil;
        expect(parallelStates.stateMachines.count).to.equal(2);
        expect(parallelStates.stateMachines[0]).to.equal(subStateMachineA);
        expect(parallelStates.stateMachines[1]).to.equal(subStateMachineB);
    });
    
    it(@"switches states on all registered states", ^{
        
        __block BOOL enteredStateA = NO;
        __block BOOL exitedStateA = NO;
        __block BOOL enteredStateB = NO;
        __block BOOL exitedStateB = NO;
        
        stateA.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            enteredStateA = YES;
        };
        
        stateA.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            exitedStateA = YES;
        };
        
        stateB.enterBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            enteredStateB = YES;
        };
        
        stateB.exitBlock = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            exitedStateB = YES;
        };
        
        subStateMachineA.states = @[stateA];
        subStateMachineA.initialState = stateA;
        
        subStateMachineB.states = @[stateB];
        subStateMachineB.initialState = stateB;
        
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
        parallelStates.stateMachines = parallelSubStateMachines;
        
        [parallelStates enter:nil targetState:nil data:nil];
        
        expect(enteredStateA).to.equal(YES);
        expect(enteredStateB).to.equal(YES);
        
        [parallelStates exit:nil targetState:nil data:nil];
        
        expect(exitedStateA).to.equal(YES);
        expect(exitedStateB).to.equal(YES);
    });
});

SpecEnd
