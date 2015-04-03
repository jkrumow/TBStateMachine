//
//  TBSMForkTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMFork)

__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;
__block TBSMParallelState *parallel;
__block TBSMParallelState *empty;

describe(@"TBSMFork", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        c = [TBSMState stateWithName:@"c"];
        parallel = [TBSMParallelState parallelStateWithName:@"parallel"];
        TBSMStateMachine *submachineA = [TBSMStateMachine stateMachineWithName:@"submachineA"];
        TBSMStateMachine *submachineB = [TBSMStateMachine stateMachineWithName:@"submachineB"];
        submachineA.states = @[a];
        submachineB.states = @[b];
        parallel.stateMachines = @[submachineA, submachineB];
        empty = [TBSMParallelState parallelStateWithName:@"empty"];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        c = nil;
        parallel = nil;
        empty = nil;
    });

    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMFork forkWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMFork forkWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws an exception when source and target states are invalid.", ^{
            
            expect(^{
                TBSMFork *fork = [TBSMFork forkWithName:@"Fork"];
                [fork setTargetStates:nil inRegion:parallel];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMFork *fork = [TBSMFork forkWithName:@"Fork"];
                [fork setTargetStates:@[] inRegion:parallel];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMFork *fork = [TBSMFork forkWithName:@"Fork"];
                [fork setTargetStates:@[a, b] inRegion:nil];
            }).to.raise(TBSMException);
        });
    });
    
    it(@"returns its name.", ^{
        TBSMFork *fork = [TBSMFork forkWithName:@"Fork"];
        expect(fork.name).to.equal(@"Fork");
    });
});

SpecEnd
