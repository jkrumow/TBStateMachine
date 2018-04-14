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
    TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:data[@"name"]];
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
    NSDictionary *pseudoState = data[@"pseudo_state"];
    NSString *forkName = pseudoState[@"name"];
    NSString *regionPath = pseudoState[@"region"];
    
    NSDictionary *vertices = data[@"vertices"];
    NSArray *incoming = vertices[@"incoming"];
    NSArray *outgoing = vertices[@"outgoing"];
 
    NSDictionary *incomingFirst = incoming.firstObject;
    NSString *sourceName = incomingFirst[@"name"];
    NSString *sourcePath = incomingFirst[@"source"];
    
    NSMutableArray *targets = [NSMutableArray new];
    [outgoing enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *targetPath = entry[@"target"];
        TBSMState *target = [stateMachine stateWithPath:targetPath];
        [targets addObject:target];
    }];
    
    TBSMFork *fork = [TBSMFork forkWithName:forkName];
    TBSMState *source = [stateMachine stateWithPath:sourcePath];
    [source addHandlerForEvent:sourceName target:fork];
    
    TBSMParallelState *region = (TBSMParallelState *)[stateMachine stateWithPath:regionPath];
    [fork setTargetStates:targets inRegion:region];
}

+ (void)configureJoinTransition:(NSDictionary *)data forStateMachine:(TBSMStateMachine *)stateMachine
{
    NSDictionary *pseudoState = data[@"pseudo_state"];
    NSString *joinName = pseudoState[@"name"];
    NSString *regionPath = pseudoState[@"region"];
    
    NSDictionary *vertices = data[@"vertices"];
    NSArray *incoming = vertices[@"incoming"];
    NSArray *outgoing = vertices[@"outgoing"];
    
    NSDictionary *outgoingFirst = outgoing.firstObject;
    NSString *targetPath = outgoingFirst[@"target"];
    
    TBSMJoin *join = [TBSMJoin joinWithName:joinName];
    TBSMState *target = [stateMachine stateWithPath:targetPath];
    TBSMParallelState *region = (TBSMParallelState *)[stateMachine stateWithPath:regionPath];
    
    NSMutableArray *sources = [NSMutableArray new];
    [incoming enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *sourceName = entry[@"name"];
        NSString *sourcePath = entry[@"source"];
        TBSMState *source = [stateMachine stateWithPath:sourcePath];
        [source addHandlerForEvent:sourceName target:join];
        [sources addObject:source];
    }];
    
    [join setSourceStates:sources inRegion:region target:target];
}

@end
