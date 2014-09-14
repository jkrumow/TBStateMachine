//
//  TBStateMachineParallelWrapperTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 08/01/2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(TBStateMachineParallelWrapper)

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
__block TBStateMachineParallelWrapper *parallelStates;
__block NSDictionary *eventDataA;


describe(@"TBStateMachineParallelWrapper", ^{
    
    beforeEach(^{
        parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
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
                parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                parallelStates = [TBStateMachineParallelWrapper parallelWrapperWithName:@""];
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
        stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            enteredStateA = YES;
        };
        
        __block BOOL exitedStateA = NO;
        stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            exitedStateA = YES;
        };
        
        __block BOOL enteredStateB = NO;
        stateB.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            enteredStateB = YES;
        };
        
        __block BOOL exitedStateB = NO;
        stateB.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
            exitedStateB = YES;
        };
        
        subStateMachineA.states = @[stateA];
        subStateMachineA.initialState = stateA;
        
        subStateMachineB.states = @[stateB];
        subStateMachineB.initialState = stateB;
        
        NSArray *parallelSubStateMachines = @[subStateMachineA, subStateMachineB];
        parallelStates.states = parallelSubStateMachines;
        
        [parallelStates enter:nil destinationState:nil data:nil];
        
        expect(enteredStateA).to.equal(YES);
        expect(enteredStateB).to.equal(YES);
        
        [parallelStates exit:nil destinationState:nil data:nil];
        
        expect(exitedStateA).to.equal(YES);
        expect(exitedStateB).to.equal(YES);
    });
    
});

SpecEnd
