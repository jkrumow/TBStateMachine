//
//  TBSMJunctionTests.m
//  TBStateMachine
//
//  Created by Julian Krumow on 23.04.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMJunction)

__block TBSMState *a;
__block TBSMState *b;
__block TBSMStateMachine *stateMachine;

describe(@"TBSMJunction", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        stateMachine.states = @[a, b];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        stateMachine = nil;
    });
    
    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMJunction junctionWithName:@""];
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when guard is nil.", ^{
            
            TBSMJunction *junction = [TBSMJunction junctionWithName:@"junction"];
            
            expect(^{
                [junction addOutgoingPathWithTarget:a action:nil guard:nil];
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when no outgoing path could be determined.", ^{
            
            TBSMJunction *junction = [TBSMJunction junctionWithName:@"junction"];
            [junction addOutgoingPathWithTarget:a action:nil guard:^BOOL(id data) {
                return NO;
            }];
            
            expect(^{
                [junction outgoingPathForTransition:b data:nil];
            }).to.raise(TBSMException);
        });
    });
    
    it(@"returns its name.", ^{
        TBSMJunction *junction = [TBSMJunction junctionWithName:@"Junction"];
        expect(junction.name).to.equal(@"Junction");
    });
});

SpecEnd
