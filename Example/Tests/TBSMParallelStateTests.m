//
//  TBSMParallelStateTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 01.08.2014.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMParallelState)

__block TBSMState *a1;
__block TBSMState *a2;
__block TBSMState *b1;
__block TBSMState *b2;
__block TBSMState *c1;
__block TBSMState *c2;

__block TBSMStateMachine *subStateMachineA;
__block TBSMStateMachine *subStateMachineB;
__block TBSMStateMachine *subStateMachineC;
__block TBSMParallelState *parallelStates;

describe(@"TBSMParallelState", ^{
    
    beforeEach(^{
        parallelStates = [TBSMParallelState parallelStateWithName:@"p"];
        a1 = [TBSMState stateWithName:@"a1"];
        a2 = [TBSMState stateWithName:@"a2"];
        b1 = [TBSMState stateWithName:@"b1"];
        b2 = [TBSMState stateWithName:@"b2"];
        c1 = [TBSMState stateWithName:@"c1"];
        c2 = [TBSMState stateWithName:@"c2"];
        
        subStateMachineA = [TBSMStateMachine stateMachineWithName:@"smA"];
        subStateMachineB = [TBSMStateMachine stateMachineWithName:@"smB"];
        subStateMachineC = [TBSMStateMachine stateMachineWithName:@"smC"];
    });
    
    afterEach(^{
        parallelStates = nil;
        a1 = nil;
        a2 = nil;
        b1 = nil;
        b2 = nil;
        c1 = nil;
        c2 = nil;
        
        subStateMachineA = nil;
        subStateMachineB = nil;
        subStateMachineC = nil;
    });
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMParallelState parallelStateWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws a TBSMException when adding objects which are not of type TBSMStateMachine.", ^{
            
            id object = [[NSObject alloc] init];
            expect(^{
                parallelStates.stateMachines = @[subStateMachineA, subStateMachineB, object];
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when instance does not contain one or more stateMachines.", ^{
            
            expect(^{
                [parallelStates enter:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                [parallelStates enter:nil targetStates:@[a1, b1, c1] region:parallelStates data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                [parallelStates exit:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
        });
        
    });
    
    describe(@"getters", ^{
        
        it(@"return the stored states.", ^{
            parallelStates.stateMachines = @[subStateMachineA, subStateMachineB];
            expect(parallelStates.stateMachines).haveCountOf(2);
            expect(parallelStates.stateMachines).contain(subStateMachineA);
            expect(parallelStates.stateMachines).contain(subStateMachineB);
        });
    });
    
    
    it(@"enters and exits all initial states", ^{
        
        subStateMachineA.states = @[a1, a2];
        subStateMachineB.states = @[b1, b2];
        subStateMachineC.states = @[c1, c2];
        
        parallelStates.stateMachines = @[subStateMachineA, subStateMachineB, subStateMachineC];
        
        [parallelStates enter:nil targetState:nil data:nil];
        
        expect(subStateMachineA.currentState).to.equal(a1);
        expect(subStateMachineB.currentState).to.equal(b1);
        expect(subStateMachineC.currentState).to.equal(c1);
        
        [parallelStates exit:nil targetState:nil data:nil];
        
        expect(subStateMachineA.currentState).to.beNil;
        expect(subStateMachineB.currentState).to.beNil;
        expect(subStateMachineC.currentState).to.beNil;
    });
    
    it(@"enters dedicated target states.", ^{
    
        subStateMachineA.states = @[a1, a2];
        subStateMachineB.states = @[b1, b2];
        subStateMachineC.states = @[c1, c2];
        
        parallelStates.stateMachines = @[subStateMachineA, subStateMachineB, subStateMachineC];
        
        [parallelStates enter:nil targetStates:@[a2, b2] region:parallelStates data:nil];
    
        expect(subStateMachineA.currentState).to.equal(a2);
        expect(subStateMachineB.currentState).to.equal(b2);
        expect(subStateMachineC.currentState).to.equal(c1);
    });
});

SpecEnd
