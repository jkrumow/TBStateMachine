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
__block TBSMParallelState *p;
__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;

beforeEach(^{
    
    stateMachine = [TBSMStateMachine stateMachineWithName:@"main"];
    s = [TBSMSubState subStateWithName:@"s"];
    p = [TBSMParallelState parallelStateWithName:@"p"];
    a = [TBSMState stateWithName:@"a"];
    b = [TBSMState stateWithName:@"b"];
    c = [TBSMState stateWithName:@"c"];
    
    TBSMStateMachine *paraB = [TBSMStateMachine stateMachineWithName:@"paraB"];
    TBSMStateMachine *paraC = [TBSMStateMachine stateMachineWithName:@"paraC"];
    paraB.states = @[b];
    paraC.states = @[c];
    p.stateMachines = @[paraB, paraC];
    
    s.stateMachine = [TBSMStateMachine stateMachineWithName:@"sub"];
    s.stateMachine.states = @[p, a];
    
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
    
    describe(@"-activeStateConfiguration", ^{
        
        it(@"returns an NSArray containing all names of the currently activated states and their containing state machines.", ^{
            
            NSString *expectedConfiguration = @"main\n\ts\n\t\tsub\n\t\t\tp\n\t\t\t\tparaB\n\t\t\t\t\tb\n\t\t\t\tparaC\n\t\t\t\t\tc\n";
            
            NSString *configuration = [stateMachine activeStateConfiguration];
            expect(configuration).to.equal(expectedConfiguration);
        });
    });
});

SpecEnd
