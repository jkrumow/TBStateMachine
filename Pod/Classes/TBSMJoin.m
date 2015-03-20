//
//  TBSMJoin.m
//  Pods
//
//  Created by Julian Krumow on 20.03.15.
//
//

#import "TBSMJoin.h"
#import "NSException+TBStateMachine.h"

@interface TBSMJoin ()

@end

@implementation TBSMJoin

+ (TBSMJoin *)joinWithName:(NSString *)name
{
    return [[TBSMJoin alloc] initWithName:name];
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
