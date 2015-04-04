//
//  TBStateMachineDebugSupportTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 04.04.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import <TBStatemachine/TBSMStateMachine+DebugSupport.h>

SpecBegin(DebugSupport)

__block TBSMStateMachine *stateMachine;
__block TBSMSubState *s;
__block TBSMState *a;

beforeEach(^{
    
    stateMachine = [TBSMStateMachine stateMachineWithName:@"main"];
    s = [TBSMSubState subStateWithName:@"s"];
    a = [TBSMState stateWithName:@"a"];
    
    s.stateMachine = [TBSMStateMachine stateMachineWithName:@"sub"];
    s.stateMachine.states = @[a];
    stateMachine.states = @[s];
    [stateMachine setUp:nil];
});

afterEach(^{
    
    [stateMachine tearDown:nil];
    stateMachine = nil;
});

describe(@"DebugSupport", ^{
    
    describe(@"-activateDebugSupport", ^{
        
        it (@"throws a TBSMException when activated on non-toplevel state machine.", ^{
            
            expect(^{
                [s.stateMachine activateDebugSupport];
            }).to.raise(TBSMDebugSupportException);
        });
    });
    
    describe(@"-scheduleEvent:withCompletion:", ^{
        
        it (@"throws a TBSMException when '-activateDebugSupport' was not called beforehand.", ^{
            
            expect(^{
                [stateMachine scheduleEvent:[TBSMEvent eventWithName:@"test" data:nil] withCompletion:nil];
            }).to.raise(TBSMDebugSupportException);
        });
    });
});

SpecEnd
