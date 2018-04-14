//
//  TBSMCompoundTransitionTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMCompoundTransition)

NSString * const EVENT_NAME_A = @"DummyEventA";

__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;
__block TBSMParallelState *p;
__block TBSMParallelState *empty;
__block TBSMFork *fork;
__block TBSMJoin *join;

describe(@"TBSMCompoundTransition", ^{
    
    beforeEach(^{
        
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        c = [TBSMState stateWithName:@"c"];
        p = [TBSMParallelState parallelStateWithName:@"parallel"];
        empty = [TBSMParallelState parallelStateWithName:@"empty"];
        
        p.states = @[@[a]];
        fork = [TBSMFork forkWithName:@"fork"];
        [fork setTargetStates:@[a, b] inRegion:p];
        join = [TBSMJoin joinWithName:@"join"];
        [join setSourceStates:@[a, b] inRegion:p target:c];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        c = nil;
        p = nil;
        empty = nil;
        fork = nil;
        join = nil;
    });
    
    it (@"returns its name from a fork transition.", ^{
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:c targetPseudoState:fork action:nil guard:nil eventName:EVENT_NAME_A];
        expect(transition.name).to.equal(@"c --> fork --> parallel/[a,b]");
    });
    
    it (@"returns its name from a join transition.", ^{
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:a targetPseudoState:join action:nil guard:nil eventName:EVENT_NAME_A];
        expect(transition.name).to.equal(@"parallel/[a,b] --> join --> c");
    });
    
    it (@"returns source state.", ^{
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:a targetPseudoState:join action:nil guard:nil eventName:EVENT_NAME_A];
        expect(transition.sourceState).to.equal(a);
    });
    
    it (@"returns target pseudo state .", ^{
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:a targetPseudoState:join action:nil guard:nil eventName:EVENT_NAME_A];
        expect(transition.targetPseudoState).to.equal(join);
    });
    
    it (@"returns target state .", ^{
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:a targetPseudoState:join action:nil guard:nil eventName:EVENT_NAME_A];
        expect(transition.targetState).to.equal(c);
    });
    
    it (@"returns action block.", ^{
        
        TBSMActionBlock action = ^(id data) {};
        
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:a targetPseudoState:join action:action guard:nil eventName:EVENT_NAME_A];
        expect(transition.action).to.equal(action);
    });
    
    it (@"returns guard block.", ^{
        
        TBSMGuardBlock guard = ^BOOL(id data) {
            return YES;
        };
        
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:a targetPseudoState:join action:nil guard:guard eventName:EVENT_NAME_A];
        expect(transition.guard).to.equal(guard);
    });

    it(@"throws a `TBSMException` when transition has ambiguous attributes.", ^{
        join = [TBSMJoin joinWithName:@"join"];
        [join setSourceStates:@[a] inRegion:empty target:b];
        TBSMCompoundTransition *transition = [[TBSMCompoundTransition alloc] initWithSourceState:a targetPseudoState:join action:nil guard:nil eventName:EVENT_NAME_A];
        
        expect(^{
            [transition performTransitionWithData:nil];
        }).to.raise(TBSMException);
    });
});

SpecEnd
