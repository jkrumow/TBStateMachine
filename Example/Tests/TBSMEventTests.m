//
//  TBSMEventTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.14.
//  Copyright (c) 2014-2015 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>

SpecBegin(TBSMEvent)


describe(@"TBSMEvent", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMEvent eventWithName:nil data:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMEvent eventWithName:@"" data:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"returns its name.", ^{
            TBSMEvent *event = [TBSMEvent eventWithName:@"a" data:nil];
            expect(event.name).to.equal(@"a");
        });
        
    });
    
});

describe(@"TBSMEventHandler", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBSMException when name is nil.", ^{
            
            expect(^{
                [TBSMEventHandler eventHandlerWithName:nil target:nil kind:TBSMTransitionExternal action:nil guard:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"throws a TBSMException when name is an empty string.", ^{
            
            expect(^{
                [TBSMEventHandler eventHandlerWithName:@"" target:nil kind:TBSMTransitionExternal action:nil guard:nil];
            }).to.raise(TBSMException);
            
        });
        
        it (@"returns its name.", ^{
            TBSMEventHandler *eventHandler = [TBSMEventHandler eventHandlerWithName:@"a" target:nil kind:TBSMTransitionExternal action:nil guard:nil];
            expect(eventHandler.name).to.equal(@"a");
        });
    });
});

SpecEnd
