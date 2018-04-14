//
//  TBSMForkTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2014-2016 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMFork)

__block TBSMState *a;
__block TBSMState *b;
__block TBSMParallelState *parallel;

describe(@"TBSMFork", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        parallel = [TBSMParallelState parallelStateWithName:@"parallel"];
        parallel.states = @[@[a], @[b]];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        parallel = nil;
    });

    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMFork forkWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it(@"throws a `TBSMException` when source, region or target states are invalid.", ^{
            
            expect(^{
                TBSMFork *fork = [TBSMFork forkWithName:@"Fork"];
                [fork setTargetStates:@[] inRegion:parallel];
            }).to.raise(TBSMException);
        });
    });
    
    it(@"returns its name.", ^{
        TBSMFork *fork = [TBSMFork forkWithName:@"Fork"];
        expect(fork.name).to.equal(@"Fork");
    });
});

SpecEnd
