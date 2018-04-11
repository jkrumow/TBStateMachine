//
//  TBSMStateMachineBuilder.m
//  TBStateMachine
//
//  Created by Julian Krumow on 12.04.18.
//

#import "TBSMStateMachineBuilder.h"
#import "TBSMStateMachine.h"

@implementation TBSMStateMachineBuilder

+ (TBSMStateMachine *)buildFromFile:(NSString *)file
{
    NSDictionary *data = [self loadFile:file];
    NSString *name = data[@"name"];
    TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:name];
    stateMachine.states = [self configureStates:data];
    
    [self configureTransitions:data forStatemachine:stateMachine];
    return stateMachine;
}

+ (NSDictionary *)loadFile:(NSString *)file
{
    NSData *json = [NSData dataWithContentsOfFile:file];
    if (json == nil) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:&error];
    if (error) {
        return nil;
    }
    return data;
}

+ (NSArray *)configureStates:(NSDictionary *)data
{
    NSMutableArray *states = [NSMutableArray new];
    NSArray *stateConfigurations = data[@"states"];
    [stateConfigurations enumerateObjectsUsingBlock:^(NSDictionary   * _Nonnull entry, NSUInteger index, BOOL * _Nonnull stop) {
        TBSMState *state = [TBSMState stateWithName:entry[@"name"]];
        [states addObject:state];
    }];
    return states;
}

+ (void)configureTransitions:(NSDictionary *)data forStatemachine:(TBSMStateMachine *)stateMachine
{
    NSArray *transitionConfigurations = data[@"transitions"];
    [transitionConfigurations enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull item, NSUInteger index, BOOL * _Nonnull stop) {
        TBSMState *source = [stateMachine stateWithPath:item[@"source"]];
        TBSMState *target = [stateMachine stateWithPath:item[@"target"]];
        [source addHandlerForEvent:item[@"name"] target:target];
    }];
}

@end
