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
    stateMachine.states = [self buildStates:data[@"states"]];
    
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

+ (NSArray *)buildStates:(NSArray *)data
{
    NSMutableArray *states = [NSMutableArray new];
    [data enumerateObjectsUsingBlock:^(NSDictionary   * _Nonnull entry, NSUInteger index, BOOL * _Nonnull stop) {
        TBSMState *state = [self buildState:entry];
        [states addObject:state];
    }];
    return states;
}

+ (TBSMState *)buildState:(NSDictionary *)data
{
    NSString *type = data[@"type"];
    if ([type isEqualToString:@"state"]) {
        return [TBSMState stateWithName:data[@"name"]];
    }
    if ([type isEqualToString:@"sub"]) {
        return [self buildSub:data];
    }
    if ([type isEqualToString:@"parallel"]) {
        return [self buildParallel:data];
    }
    return nil;
}

+ (TBSMSubState *)buildSub:(NSDictionary *)data
{
    TBSMSubState *state = [TBSMSubState subStateWithName:data[@"name"]];
    state.states = [self buildStates:data[@"states"]];
    return state;
}

+ (TBSMParallelState *)buildParallel:(NSDictionary *)data
{
    TBSMParallelState *state = [TBSMParallelState parallelStateWithName:data[@"name"]];
    NSArray *regionData = data[@"regions"];
    NSMutableArray *regions = [NSMutableArray new];
    [regionData enumerateObjectsUsingBlock:^(NSArray * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *states = [self buildStates:entry];
        [regions addObject:states];
    }];
    [state setStates:regions];
    return state;
}

+ (void)configureTransitions:(NSDictionary *)data forStatemachine:(TBSMStateMachine *)stateMachine
{
    NSArray *transitionConfigurations = data[@"transitions"];
    [transitionConfigurations enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull item, NSUInteger index, BOOL * _Nonnull stop) {
        NSString *kindData = data[@"kind"];
        TBSMTransitionKind kind = TBSMTransitionExternal;
        if ([kindData isEqualToString:@"internal"]) {
            kind = TBSMTransitionInternal;
        }
        if ([kindData isEqualToString:@"local"]) {
            kind = TBSMTransitionLocal;
        }
        TBSMState *source = [stateMachine stateWithPath:item[@"source"]];
        TBSMState *target = [stateMachine stateWithPath:item[@"target"]];
        [source addHandlerForEvent:item[@"name"] target:target kind:kind];
    }];
}

@end
