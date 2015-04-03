//
//  TBSMJoinTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMJoin)

__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;
__block TBSMParallelState *parallel;
__block TBSMParallelState *empty;

describe(@"TBSMJoin", ^{

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
                [TBSMJoin joinWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMJoin joinWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws an exception when source and target states are invalid.", ^{
            
            expect(^{
                TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
                [join setSourceStates:nil inRegion:parallel target:c];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
                [join setSourceStates:@[] inRegion:parallel target:c];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
                [join setSourceStates:@[a, b] inRegion:parallel target:nil];
            }).to.raise(TBSMException);
        });
    });
    
    it(@"returns its name.", ^{
        TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
        expect(join.name).to.equal(@"Join");
    });
    
    describe(@"managing source states.", ^{
    
        it(@"returns YES if all source states have been joined.", ^{
            TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
            [join setSourceStates:@[a, b] inRegion:parallel target:c];
            expect([join joinSourceState:a]).to.equal(NO);
            expect([join joinSourceState:b]).to.equal(YES);
        });
    });
});

SpecEnd
