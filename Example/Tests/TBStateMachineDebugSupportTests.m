//
//  TBStateMachineDebugSupportTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 04.04.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import <TBStatemachine/TBSMDebugger.h>

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
    
    p.states = @[@[b], @[c]];
    s.states = @[p, a];
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
                [[TBSMDebugger sharedInstance] debugStateMachine:s.stateMachine];
            }).to.raise(TBSMDebugSupportException);
        });
    });
    
    describe(@"-activeStateConfiguration", ^{
        
        it(@"returns an NSArray containing all names of the currently activated states and their containing state machines.", ^{
            
            NSString *expectedConfiguration = @"main\n\ts\n\t\tsSubMachine\n\t\t\tp\n\t\t\t\tpSubMachine-0\n\t\t\t\t\tb\n\t\t\t\tpSubMachine-1\n\t\t\t\t\tc\n";
            
            [[TBSMDebugger sharedInstance] debugStateMachine:stateMachine];
            NSString *configuration = [[TBSMDebugger sharedInstance] activeStateConfiguration];
            expect(configuration).to.equal(expectedConfiguration);
        });
    });
});

SpecEnd
