//
//  TBSMCompoundTransitionTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMCompoundTransition)

__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;
__block TBSMParallelState *parallel;
__block TBSMParallelState *empty;
__block TBSMFork *fork;
__block TBSMJoin *join;

describe(@"TBSMCompoundTransition", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        c = [TBSMState stateWithName:@"c"];
        parallel = [TBSMParallelState parallelStateWithName:@"parallel"];
        TBSMStateMachine *subMachineA = [TBSMStateMachine stateMachineWithName:@"subMachineA"];
        subMachineA.states = @[a];
        parallel.stateMachines = @[subMachineA];
        empty = [TBSMParallelState parallelStateWithName:@"empty"];
        fork = [TBSMFork forkWithName:@"fork"];
        [fork setTargetStates:@[a, b] inRegion:parallel];
        join = [TBSMJoin joinWithName:@"join"];
        [join setSourceStates:@[a, b] inRegion:parallel target:c];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        c = nil;
        parallel = nil;
        empty = nil;
        fork = nil;
        join = nil;
    });
    
    it (@"returns its name from a fork transition.", ^{
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:c targetPseudoState:fork action:nil guard:nil];
        expect(transition.name).to.equal(@"c --> fork --> [a,b](parallel)");
    });
    
    it (@"returns its name from a join transition.", ^{
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:nil guard:nil];
        expect(transition.name).to.equal(@"[a,b](parallel) --> join --> c");
    });
    
    it (@"returns source state.", ^{
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:nil guard:nil];
        expect(transition.sourceState).to.equal(a);
    });
    
    it (@"returns target pseudo state .", ^{
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:nil guard:nil];
        expect(transition.targetPseudoState).to.equal(join);
    });
    
    it (@"returns target state .", ^{
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:nil guard:nil];
        expect(transition.targetState).to.equal(c);
    });
    
    it (@"returns action block.", ^{
        
        TBSMActionBlock action = ^(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            
        };
        
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:action guard:nil];
        expect(transition.action).to.equal(action);
    });
    
    it (@"returns guard block.", ^{
        
        TBSMGuardBlock guard = ^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
            return YES;
        };
        
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:nil guard:guard];
        expect(transition.guard).to.equal(guard);
    });

    it(@"throws an exception when transition has ambiguous attributes.", ^{
        join = [TBSMJoin joinWithName:@"join"];
        [join setSourceStates:@[a] inRegion:empty target:b];
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:nil guard:nil];
        
        expect(^{
            [transition performTransitionWithData:nil];
        }).to.raise(TBSMException);
    });
});

SpecEnd
