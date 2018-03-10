//
//  TBSMState+Notifications.m
//  TBStateMachine
//
//  Created by Julian Krumow on 10.03.18.
//

#import "TBSMState+Notifications.h"

NSString * const TBSMStateDidEnterNotification = @"TBSMStateDidEnterNotification";
NSString * const TBSMStateDidExitNotification = @"TBSMStateDidExitNotification";
NSString * const TBSMDataUserInfo = @"data";

@implementation TBSMState (Notifications)

- (void)tbsm_postNotificationWithName:(NSString *)name data:(id)data
{
    NSMutableDictionary *userInfo = NSMutableDictionary.new;
    if (data) {
        userInfo[TBSMDataUserInfo] = data;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:userInfo];
}

@end
