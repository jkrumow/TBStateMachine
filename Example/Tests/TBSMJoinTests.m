//
//  TBSMJoinTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMJoin)

__block TBSMState *a;
__block TBSMState *b;
__block TBSMState *c;
__block TBSMParallelState *parallel;

describe(@"TBSMJoin", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        c = [TBSMState stateWithName:@"c"];
        parallel = [TBSMParallelState parallelStateWithName:@"parallel"];
        parallel.states = @[@[a], @[b]];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        c = nil;
        parallel = nil;
    });
    
    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMJoin joinWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws a `TBSMException` when source, region or target states are invalid.", ^{
            
            expect(^{
                TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
                [join setSourceStates:@[] inRegion:parallel target:c];
            }).to.raise(TBSMException);
        });
    });
    
    it(@"returns its name.", ^{
        TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
        expect(join.name).to.equal(@"Join");
    });
    
    describe(@"managing source states.", ^{
        
        it(@"returns YES if all source states have been joined and resets afterwards.", ^{
            TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
            [join setSourceStates:@[a, b] inRegion:parallel target:c];
            expect([join joinSourceState:a]).to.equal(NO);
            expect([join joinSourceState:a]).to.equal(NO);
            expect([join joinSourceState:b]).to.equal(YES);
            
            expect([join joinSourceState:a]).to.equal(NO);
            expect([join joinSourceState:a]).to.equal(NO);
            expect([join joinSourceState:b]).to.equal(YES);
        });
    });
});

SpecEnd
