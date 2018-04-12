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
        
        if ([item[@"type"] isEqualToString:@"simple"]) {
            [self configureSimpleTransition:item forStatemachine:stateMachine];
        } else if ([item[@"type"] isEqualToString:@"fork"]) {
            [self configureForkTransition:item forStatemachine:stateMachine];
        } else if ([item[@"type"] isEqualToString:@"join"]) {
            [self configureJoinTransition:item forStatemachine:stateMachine];
        }
    }];
}

+ (void)configureSimpleTransition:(NSDictionary *)data forStatemachine:(TBSMStateMachine *)stateMachine
{
    NSString *kindData = data[@"kind"];
    TBSMTransitionKind kind = TBSMTransitionExternal;
    if ([kindData isEqualToString:@"internal"]) {
        kind = TBSMTransitionInternal;
    }
    if ([kindData isEqualToString:@"local"]) {
        kind = TBSMTransitionLocal;
    }
    TBSMState *source = [stateMachine stateWithPath:data[@"source"]];
    TBSMState *target = [stateMachine stateWithPath:data[@"target"]];
    [source addHandlerForEvent:data[@"name"] target:target kind:kind];
}

+ (void)configureForkTransition:(NSDictionary *)data forStatemachine:(TBSMStateMachine *)stateMachine
{
    TBSMState *source = [stateMachine stateWithPath:data[@"source"]];
    NSArray *targetData = data[@"targets"];
    NSMutableArray *targets = [NSMutableArray new];
    [targetData enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        TBSMState *target = [stateMachine stateWithPath:path];
        [targets addObject:target];
    }];
    
    NSDictionary *forkData = data[@"fork"];
    TBSMParallelState *region = (TBSMParallelState *)[stateMachine stateWithPath:data[@"region"]];
    
    TBSMFork *fork = [TBSMFork forkWithName:forkData[@"name"]];
    [source addHandlerForEvent:data[@"name"] target:fork];
    [fork setTargetStates:targets inRegion:region];
}

+ (void)configureJoinTransition:(NSDictionary *)data forStatemachine:(TBSMStateMachine *)stateMachine
{
    NSArray *sourceData = data[@"sources"];
    NSMutableArray *sources = [NSMutableArray new];
    [sourceData enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        TBSMState *source = [stateMachine stateWithPath:path];
        [sources addObject:source];
    }];
    TBSMState *target = [stateMachine stateWithPath:data[@"target"]];
    
    NSDictionary *joinData = data[@"join"];
    TBSMParallelState *region = (TBSMParallelState *)[stateMachine stateWithPath:data[@"region"]];
    TBSMJoin *join = [TBSMJoin joinWithName:joinData[@"name"]];
    
    [sources enumerateObjectsUsingBlock:^(TBSMState * _Nonnull source, NSUInteger idx, BOOL * _Nonnull stop) {
        [source addHandlerForEvent:data[@"name"] target:join];
    }];
    [join setSourceStates:sources inRegion:region target:target];
}

@end
