//
//  TBSMFork.m
//  Pods
//
//  Created by Julian Krumow on 20.03.15.
//
//

#import "TBSMFork.h"
#import "NSException+TBStateMachine.h"

@interface TBSMFork ()
@property (nonatomic, copy) NSString *name;
@end

@implementation TBSMFork

+ (TBSMFork *)forkWithName:(NSString *)name
{
    return [[TBSMFork alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        @throw [NSException tb_noNameForPseudoStateException];
    }
    self = [super init];
    if (self) {
        _name = name.copy;
    }
    return self;
}

@end
