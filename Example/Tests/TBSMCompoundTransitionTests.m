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
__block TBSMJoin *join;

describe(@"TBSMCompoundTransition", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        parallel = [TBSMParallelState parallelStateWithName:@"parallel"];
        join = [TBSMJoin joinWithName:@"join"];
        [join addSourceStates:@[] inRegion:parallel target:b];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        parallel = nil;
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

});

SpecEnd
