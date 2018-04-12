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
    
    [self configureTransitions:data forStateMachine:stateMachine];
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

+ (void)configureTransitions:(NSDictionary *)data forStateMachine:(TBSMStateMachine *)stateMachine
{
    NSArray *transitionConfigurations = data[@"transitions"];
    [transitionConfigurations enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull item, NSUInteger index, BOOL * _Nonnull stop) {
        if ([item[@"type"] isEqualToString:@"simple"]) {
            [self configureSimpleTransition:item forStateMachine:stateMachine];
        }
        if ([item[@"type"] isEqualToString:@"compound"]) {
            [self configureCompoundTransition:item forStateMachine:stateMachine];
        }
    }];
}

+ (void)configureSimpleTransition:(NSDictionary *)data forStateMachine:(TBSMStateMachine *)stateMachine
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

+ (void)configureCompoundTransition:(NSDictionary *)data forStateMachine:(TBSMStateMachine *)stateMachine
{
    NSDictionary *pseudoState = data[@"pseudo_state"];
    if ([pseudoState[@"type"] isEqualToString:@"fork"]) {
        [self configureForkTransition:data forStateMachine:stateMachine];
    }
    if ([pseudoState[@"type"] isEqualToString:@"join"]) {
        [self configureJoinTransition:data forStateMachine:stateMachine];
    }
}

+ (void)configureForkTransition:(NSDictionary *)data forStateMachine:(TBSMStateMachine *)stateMachine
{
    
    NSString *name = data[@"name"];
    NSArray *vertices = data[@"vertices"];
    NSDictionary *pseudoState = data[@"pseudo_state"];
    NSString *regionPath = pseudoState[@"region"];
    
    TBSMFork *fork = [TBSMFork forkWithName:pseudoState[@"name"]];
    TBSMParallelState *region = (TBSMParallelState *)[stateMachine stateWithPath:regionPath];
    
    __block NSString *sourcePath;
    NSMutableArray *targets = [NSMutableArray new];
    [vertices enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
        sourcePath = entry[@"source"];
        NSString *path = entry[@"target"];
        TBSMState *target = [stateMachine stateWithPath:path];
        [targets addObject:target];
    }];
    
    TBSMState *source = [stateMachine stateWithPath:sourcePath];
    [source addHandlerForEvent:name target:fork];
    [fork setTargetStates:targets inRegion:region];
}

+ (void)configureJoinTransition:(NSDictionary *)data forStateMachine:(TBSMStateMachine *)stateMachine
{
    NSDictionary *pseudoState = data[@"pseudo_state"];
    NSArray *vertices = data[@"vertices"];
    NSString *regionPath = pseudoState[@"region"];
    
    TBSMJoin *join = [TBSMJoin joinWithName:pseudoState[@"name"]];
    TBSMParallelState *region = (TBSMParallelState *)[stateMachine stateWithPath:regionPath];
    
    __block NSString *targetPath;
    NSMutableArray *sources = [NSMutableArray new];
    [vertices enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *vertexName = entry[@"name"];
        targetPath = entry[@"target"];
        NSString *path = entry[@"source"];
        TBSMState *source = [stateMachine stateWithPath:path];
        [source addHandlerForEvent:vertexName target:join];
        [sources addObject:source];
    }];
    
    TBSMState *target = [stateMachine stateWithPath:targetPath];
    [join setSourceStates:sources inRegion:region target:target];
}

@end
