//
//  TBSMParallelStateTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 01.08.2014.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMParallelState)

__block TBSMState *a;
__block TBSMState *b;

__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMParallelState *parallelStates;

describe(@"TBSMParallelState", ^{
    
    beforeEach(^{
        parallelStates = [TBSMParallelState parallelStateWithName:@"p"];
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"smA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"smB"];
    });
    
    afterEach(^{
        parallelStates = nil;
        a = nil;
        b = nil;
        
        subStateMachineA = nil;
        subStateMachineB = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMParallelState parallelStateWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMParallelState parallelStateWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws TBSMException when state object is not of type TBSMStateMachine.", ^{
            
            id object = [[NSObject alloc] init];
            NSArray *states = @[subStateMachineA, subStateMachineB, object];
            expect(^{
                parallelStates.stateMachines = states;
            }).to.raise(TBSMException);
        });
        
    });
    
    it(@"enters and exits all initial states", ^{
        
        subStateMachineA.states = @[a];
        subStateMachineB.states = @[b];
        
        parallelStates.stateMachines = @[subStateMachineA, subStateMachineB];
        
        [parallelStates enter:nil targetState:nil data:nil];
        
        expect(subStateMachineA.currentState).to.equal(a);
        expect(subStateMachineB.currentState).to.equal(b);
        
        [parallelStates exit:nil targetState:nil data:nil];
        
        expect(subStateMachineA.currentState).to.beNil;
        expect(subStateMachineB.currentState).to.beNil;
    });
});

SpecEnd
