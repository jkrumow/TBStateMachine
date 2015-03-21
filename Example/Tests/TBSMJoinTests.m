//
//  TBSMJoinTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 20.03.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMJoin)

describe(@"TBSMJoin", ^{

    beforeEach(^{
        
    });
    
    afterEach(^{
        
    });
    
    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMJoin joinWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMJoin joinWithName:@""];
            }).to.raise(TBSMException);
            
        });
    });
    
    it(@"returns its name.", ^{
        TBSMJoin *join = [TBSMJoin joinWithName:@"Join"];
        expect(join.name).to.equal(@"Join");
    });
});

SpecEnd
