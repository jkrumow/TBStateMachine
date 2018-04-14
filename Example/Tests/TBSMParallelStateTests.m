//
//  TBSMParallelStateTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 01.08.2014.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMParallelState)

__block TBSMState *a1;
__block TBSMState *a2;
__block TBSMState *b1;
__block TBSMState *b2;
__block TBSMState *c1;
__block TBSMState *c2;
__block TBSMParallelState *p;

describe(@"TBSMParallelState", ^{
    
    beforeEach(^{
        p = [TBSMParallelState parallelStateWithName:@"p"];
        a1 = [TBSMState stateWithName:@"a1"];
        a2 = [TBSMState stateWithName:@"a2"];
        b1 = [TBSMState stateWithName:@"b1"];
        b2 = [TBSMState stateWithName:@"b2"];
        c1 = [TBSMState stateWithName:@"c1"];
        c2 = [TBSMState stateWithName:@"c2"];
    });
    
    afterEach(^{
        p = nil;
        a1 = nil;
        a2 = nil;
        b1 = nil;
        b2 = nil;
        c1 = nil;
        c2 = nil;
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
                p.stateMachines = @[@[], @[], object];
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when instance does not contain one or more stateMachines.", ^{
            
            expect(^{
                [p enter:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                [p enter:nil targetStates:@[a1, b1, c1] region:p data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                [p exit:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
        });
        
    });
    
    describe(@"getters", ^{
        
        it(@"return the stored states.", ^{
            p.states = @[@[], @[]];
            expect(p.stateMachines).haveCountOf(2);
            expect(p.stateMachines.count).equal(2);
        });
    });
    
    describe(@"Convenience setters", ^{
        
        it(@"creates a state machine implicitly", ^{
            
            TBSMState *a1 = [TBSMState stateWithName:@"a1"];
            TBSMState *a2 = [TBSMState stateWithName:@"a2"];
            p.states = @[@[a1], @[a2]];
            
            expect(p.stateMachines.count).to.equal(2);
            
            TBSMStateMachine *first = p.stateMachines.firstObject;
            TBSMStateMachine *second = p.stateMachines.lastObject;
            expect(first.name).to.equal(@"pSubMachine-0");
            expect(second.name).to.equal(@"pSubMachine-1");
        });
    });
    
    it(@"enters and exits all initial states", ^{
        
        p.states = @[@[a1, a2], @[b1, b2], @[c1, c2]];
        
        [p enter:nil targetState:nil data:nil];
        
        expect(p.stateMachines[0].currentState).to.equal(a1);
        expect(p.stateMachines[1].currentState).to.equal(b1);
        expect(p.stateMachines[2].currentState).to.equal(c1);
        
        [p exit:nil targetState:nil data:nil];
    });
    
    it(@"enters dedicated target states.", ^{
    
        p.states = @[@[a1, a2], @[b1, b2], @[c1, c2]];
        
        [p enter:nil targetStates:@[a2, b2] region:p data:nil];
    
        expect(p.stateMachines[0].currentState).to.equal(a2);
        expect(p.stateMachines[1].currentState).to.equal(b2);
        expect(p.stateMachines[2].currentState).to.equal(c1);
    });
});

SpecEnd
