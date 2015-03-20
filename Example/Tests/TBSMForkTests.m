//
//  TBSMForkTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMFork)

describe(@"TBSMFork", ^{
    
    beforeEach(^{
        
    });
    
    afterEach(^{
        
    });

    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMFork forkWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMFork forkWithName:@""];
            }).to.raise(TBSMException);
            
        });
    });
    
    it(@"returns its name.", ^{
        TBSMFork *forkXYZ = [TBSMFork forkWithName:@"ForkXYZ"];
        expect(forkXYZ.name).to.equal(@"ForkXYZ");
    });
});

SpecEnd
