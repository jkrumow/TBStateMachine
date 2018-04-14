//
//  TBSMSubStateTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.09.14.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMSubState)

describe(@"TBSMSubState", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMSubState subStateWithName:@""];
            }).to.raise(TBSMException);
        });
        
        it(@"throws a TBSMException when adding an object which is not of type TBSMStateMachine.", ^{
            
            id object = [[NSObject alloc] init];
            TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
            expect(^{
                subState.stateMachine = object;
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when stateMachine is nil.", ^{
            
            TBSMState *a1 = [TBSMState stateWithName:@"a1"];
            TBSMState *a2 = [TBSMState stateWithName:@"a2"];
            
            TBSMParallelState *p = [TBSMParallelState parallelStateWithName:@"parallelstate"];
            p.states = @[@[a1, a2]];
            
            expect(^{
                TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
                [subState enter:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
                [subState enter:nil targetStates:@[a1, a2] region:p data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
                [subState exit:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
        });
    });
    
    describe(@"Convenience setters", ^{
        
        it(@"creates a state machine implicitly", ^{
            
            TBSMState *a1 = [TBSMState stateWithName:@"a1"];
            TBSMState *a2 = [TBSMState stateWithName:@"a2"];
            TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
            subState.states = @[a1, a2];
            
            expect(subState.stateMachine).notTo.beNil();
            expect(subState.stateMachine.name).to.equal(@"subStateSubMachine");
        });
    });
    
    it(@"enters and exits all initial states", ^{
        
        TBSMSubState *a = [TBSMSubState subStateWithName:@"a"];
        TBSMState *a1 = [TBSMState stateWithName:@"a1"];
        TBSMState *a2 = [TBSMState stateWithName:@"a2"];
        a.states = @[a1, a2];
        
        [a enter:nil targetState:nil data:nil];
        expect(a.stateMachine.currentState).to.equal(a1);
        
        [a exit:nil targetState:nil data:nil];
        expect(a.stateMachine.currentState).to.beNil;
    });
});

SpecEnd
