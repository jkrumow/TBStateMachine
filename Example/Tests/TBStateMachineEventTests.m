//
//  TBStateMachineEventTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 14.09.14.
//  Copyright (c) 2014 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBStateMachine.h>

SpecBegin(StateMachineEvent)


describe(@"TBStateMachineEvent", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                [TBStateMachineEvent eventWithName:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                [TBStateMachineEvent eventWithName:@""];
            }).to.raise(TBStateMachineException);
            
        });
        
    });
    
});

describe(@"TBStateMachineEventHandler", ^{
    
    describe(@"Exception handling on setup.", ^{
        
        it (@"throws a TBStateMachineException when name is nil.", ^{
            
            expect(^{
                [TBStateMachineEventHandler eventHandlerWithName:nil target:nil action:nil guard:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
        it (@"throws a TBStateMachineException when name is an empty string.", ^{
            
            expect(^{
                [TBStateMachineEventHandler eventHandlerWithName:@"" target:nil action:nil guard:nil];
            }).to.raise(TBStateMachineException);
            
        });
        
    });
    
});

SpecEnd
