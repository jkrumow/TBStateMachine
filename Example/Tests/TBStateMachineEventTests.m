//
//  TBStateMachineEventTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(StateMachineEvent)


describe(@"TBSMEvent", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMEvent eventWithName:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMEvent eventWithName:@""];
            }).to.raise(TBSMException);
            
        });
        
        it (@"returns its name.", ^{
            TBSMEvent *event = [TBSMEvent eventWithName:@"a"];
            expect(event.name).to.equal(@"a");
        });
        
    });
    
});

describe(@"TBSMEventHandler", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMEventHandler eventHandlerWithName:nil target:nil action:nil guard:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMEventHandler eventHandlerWithName:@"" target:nil action:nil guard:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"returns its name.", ^{
            TBSMEventHandler *eventHandler = [TBSMEventHandler eventHandlerWithName:@"a" target:nil action:nil guard:nil];
            expect(eventHandler.name).to.equal(@"a");
        });
        
    });
    
});

SpecEnd
