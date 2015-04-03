//
//  TBSMPseudoStateTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 21.03.15.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMPseudoState)

describe(@"TBSMPseudoState", ^{
    
    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                TBSMPseudoState *pseudoState = [[TBSMPseudoState alloc] initWithName:nil];
                pseudoState = nil;
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                TBSMPseudoState *pseudoState = [[TBSMPseudoState alloc] initWithName:@""];
                pseudoState = nil;
            }).to.raise(TBSMException);
            
        });
    });
    
    it(@"returns its name.", ^{
        TBSMPseudoState *pseudoState = [[TBSMPseudoState alloc] initWithName:@"name"];
        expect(pseudoState.name).to.equal(@"name");
    });
});

SpecEnd
