//
//  TBSMSubStateTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMSubState)

describe(@"TBSMSubState", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMSubState subStateWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
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
            
            expect(^{
                TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
                [subState enter:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
                [subState enter:nil targetStates:nil region:nil data:nil];
            }).to.raise(TBSMException);
            
            expect(^{
                TBSMSubState *subState = [TBSMSubState subStateWithName:@"subState"];
                [subState exit:nil targetState:nil data:nil];
            }).to.raise(TBSMException);
            
        });
        
    });
    
    it(@"enters and exits all initial states", ^{
        
        TBSMSubState *a = [TBSMSubState subStateWithName:@"a"];
        TBSMState *a1 = [TBSMState stateWithName:@"a1"];
        TBSMState *a2 = [TBSMState stateWithName:@"a2"];
        
        TBSMStateMachine *subStateMachineA = [TBSMStateMachine stateMachineWithName:@"smA"];
        
        subStateMachineA.states = @[a1, a2];
        
        a.stateMachine = subStateMachineA;
        
        [a enter:nil targetState:nil data:nil];
        
        expect(subStateMachineA.currentState).to.equal(a1);
        
        [a exit:nil targetState:nil data:nil];
        
        expect(subStateMachineA.currentState).to.beNil;
    });
});

SpecEnd
