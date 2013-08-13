//
//  PushNotificationManager.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationManager : NSObject <UIAlertViewDelegate>

// AlertViews
@property (nonatomic, strong) UIAlertView *chatAlertView;
@property (nonatomic, strong) UIAlertView *photoAlertView;
@property (nonatomic) NSInteger nbNotifcations;

// Sigleton
+ (PushNotificationManager*)sharedInstance;

// Push Notifications
- (BOOL)pushNotificationEnabled;
- (void)pushNotificationDisabledAlertView;
- (void)saveDeviceToken:(NSData*)deviceToken;
- (void)receivePushNotification:(NSDictionary*)attributes withApplicationState:(UIApplicationState)state updateUI:(BOOL)updateUI;
- (void)failToReceiveNotification:(NSError*)error;

// Notifcation number
- (void)resetNotificationNumber;

// Local Notifications
- (void)addNotificationObservers;
- (void)removeNotifications;

- (void)alertViewWithChatMessage:(NSString*)message;


@end
