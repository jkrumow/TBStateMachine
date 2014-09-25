//
//  TBStateMachineParallelStateTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 01.08.2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(TBStateMachineParallelState)

NSString * const EVENT_NAME_A = @"DummyEventA";
NSString * const EVENT_DATA_KEY = @"DummyDataKey";
NSString * const EVENT_DATA_VALUE = @"DummyDataValue";

__block TBStateMachineState *stateA;
__block TBStateMachineState *stateB;
__block TBStateMachineState *stateC;
__block TBStateMachineState *stateD;
__block TBStateMachineState *stateE;
__block TBStateMachineState *stateF;

__block TBStateMachineEvent *eventA;
__block TBStateMachine *subStateMachineA;
__block TBStateMachine *subStateMachineB;
__block TBStateMachineParallelState *parallelStates;
__block NSDictionary *eventDataA;


describe(@"TBStateMachineParallelState", ^{
    
    beforeEach(^{
        parallelStates = [TBStateMachineParallelState parallelStateWithName:@"ParallelWrapper"];
        stateA = [TBStateMachineState stateWithName:@"a"];
        stateB = [TBStateMachineState stateWithName:@"b"];
        stateC = [TBStateMachineState stateWithName:@"c"];
        stateD = [TBStateMachineState stateWithName:@"d"];
        stateE = [TBStateMachineState stateWithName:@"e"];
        stateF = [TBStateMachineState stateWithName:@"f"];
        
        subStateMachineA = [TBStateMachine stateMachineWithName:@"SubA"];
        subStateMachineB = [TBStateMachine stateMachineWithName:@"SubB"];
        
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
        
        subStateMachineA = nil;
        subStateMachineB = nil;
        
        eventDataA = nil;
        eventA = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                parallelStates = [TBStateMachineParallelState parallelStateWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                parallelStates = [TBStateMachineParallelState parallelStateWithName:@""];
            }).to.raise(TBStateMachineException);
            
        });
        
        it(@"throws TBStateMachineException when state object is not of type TBStateMachine.", ^{
            
            id object = [[NSObject alloc] init];
            NSArray *states = @[subStateMachineA, subStateMachineB, object];
            expect(^{
                parallelStates.states = states;
            }).to.raise(TBStateMachineException);
        });
        
    });
    
    it(@"switches states on all registered states", ^{
        
        __block BOOL enteredStateA = NO;
        __block BOOL exitedStateA = NO;
        __block BOOL enteredStateB = NO;
        __block BOOL exitedStateB = NO;
        
        stateA.enterBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            enteredStateA = YES;
        };
        
        stateA.exitBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            exitedStateA = YES;
        };
        
        stateB.enterBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            enteredStateB = YES;
        };
        
        stateB.exitBlock = ^(TBStateMachineState *sourceState, TBStateMachineState *destinationState, NSDictionary *data) {
            exitedStateB = YES;
        };
        
        subStateMachineA.states = @[stateA];
        subStateMachineA.initialState = stateA;
        
        subStateMachineB.states = @[stateB];
        subStateMachineB.initialState = stateB;
        
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
        parallelStates.states = parallelSubStateMachines;
        
        [parallelStates enter:nil destinationState:parallelStates data:nil];
        
        expect(enteredStateA).to.equal(YES);
        expect(enteredStateB).to.equal(YES);
        
        [parallelStates exit:nil destinationState:nil data:nil];
        
        expect(exitedStateA).to.equal(YES);
        expect(exitedStateB).to.equal(YES);
    });
    
});

SpecEnd
