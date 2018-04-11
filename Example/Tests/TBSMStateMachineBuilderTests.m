//
//  TBSMStateMachineBuilderTests.m
//  TBStateMachineTests
//
//  Created by Julian Krumow on 12.04.18.
//  Copyright © 2018 Julian Krumow. All rights reserved.
//

#import <TBStateMachine/TBSMStateMachine.h>
#import <TBStateMachine/TBSMDebugger.h>

SpecBegin(TBSMStateMachineBuilderTests)

__block NSString *file;
__block TBSMStateMachine *stateMachine;

describe(@"TBSMStateMachineBuilder", ^{
    
    beforeEach(^{
        file = [[NSBundle bundleForClass:[self class]] pathForResource:@"simple" ofType:@"json"];
    });
    
    afterEach(^{
        [stateMachine tearDown:nil];
    });
    
    it(@"loads a simple setup", ^{
        
        stateMachine = [TBSMStateMachine buildFromFile:file];
        expect(stateMachine.name).to.equal(@"main");
        expect(stateMachine.states.count).to.equal(3);
        
        TBSMState *a = stateMachine.states[0];
        TBSMState *b = stateMachine.states[1];
        TBSMState *c = stateMachine.states[2];
        expect(a.name).to.equal(@"a");
        expect(b.name).to.equal(@"b");
        expect(c.name).to.equal(@"c");
        
        [[TBSMDebugger sharedInstance] debugStateMachine:stateMachine];
        
        waitUntil(^(DoneCallback done) {
            [stateMachine setUp:nil];
            [stateMachine scheduleEventNamed:@"aTOb" data:nil];
            [stateMachine scheduleEventNamed:@"bTOc" data:nil];
            [stateMachine scheduleEvent:[TBSMEvent eventWithName:@"cTOa" data:nil] withCompletion:^{
                done();
            }];
        });
        
        expect(stateMachine.currentState).to.equal(a);
    });
});
SpecEnd
