//
//  TBSMCompoundTransitionTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMCompoundTransition)

__block TBSMState *a;
__block TBSMState *b;
__block TBSMParallelState *parallel;
__block TBSMParallelState *empty;
__block TBSMJoin *join;

describe(@"TBSMCompoundTransition", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        parallel = [TBSMParallelState parallelStateWithName:@"parallel"];
        TBSMStateMachine *subMachineA = [TBSMStateMachine stateMachineWithName:@"subMachineA"];
        subMachineA.states = @[a];
        parallel.stateMachines = @[subMachineA];
        empty = [TBSMParallelState parallelStateWithName:@"empty"];
        join = [TBSMJoin joinWithName:@"join"];
        [join setSourceStates:@[a] inRegion:parallel target:b];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        parallel = nil;
        empty = nil;
        join = nil;
    });
    
    it (@"returns its name.", ^{
        TBSMCompoundTransition *transition = [TBSMCompoundTransition compoundTransitionWithSourceState:a targetPseudoState:join action:nil guard:nil];
        expect(transition.name).to.equal(@"a_to_b");
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
        expect(transition.targetState).to.equal(b);
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
