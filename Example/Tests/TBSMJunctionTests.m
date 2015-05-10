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
__block TBSMState *c;
__block TBSMState *d;
__block TBSMStateMachine *stateMachine;

describe(@"TBSMJunction", ^{
    
    beforeEach(^{
        a = [TBSMState stateWithName:@"a"];
        b = [TBSMState stateWithName:@"b"];
        c = [TBSMState stateWithName:@"c"];
        d = [TBSMState stateWithName:@"d"];
        stateMachine = [TBSMStateMachine stateMachineWithName:@"stateMachine"];
        stateMachine.states = @[a, b, c, d];
    });
    
    afterEach(^{
        a = nil;
        b = nil;
        c = nil;
        d = nil;
        stateMachine = nil;
    });
    
    describe(@"Exception handling.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMJunction junctionWithName:nil];
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMJunction junctionWithName:@""];
            }).to.raise(TBSMException);
        });
        
        it (@"throws a TBSMException when target is nil.", ^{
            
            TBSMJunction *junction = [TBSMJunction junctionWithName:@"junction"];
            
            expect(^{
                [junction addOutgoingPathWithTarget:nil action:nil guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                    return YES;
                }];
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
            [junction addOutgoingPathWithTarget:b action:nil guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
                return NO;
            }];
            
            expect(^{
                [junction outgoingPathForTransition:a data:nil];
            }).to.raise(TBSMException);
        });
    });
    
    it(@"returns its name.", ^{
        TBSMJunction *junction = [TBSMJunction junctionWithName:@"Junction"];
        expect(junction.name).to.equal(@"Junction");
    });
});

SpecEnd
