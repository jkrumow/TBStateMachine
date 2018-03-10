//
//  TBSMState+Notifications.h
//  TBStateMachine
//
//  Created by Julian Krumow on 10.03.18.
//

#import "TBSMState.h"

FOUNDATION_EXPORT NSString * const TBSMStateDidEnterNotification;
FOUNDATION_EXPORT NSString * const TBSMStateDidExitNotification;
FOUNDATION_EXPORT NSString * const TBSMDataUserInfo;

@interface TBSMState (Notifications)

- (void)tbsm_postNotificationWithName:(NSString *)name data:(id)data;
@end
