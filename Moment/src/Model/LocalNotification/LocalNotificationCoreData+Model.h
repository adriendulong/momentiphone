//
//  LocalNotificationCoreData+Model.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 20/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "LocalNotificationCoreData.h"

@interface LocalNotificationCoreData (Model)

enum NotificationType {
    NotificationTypeInvitation = 0,
    NotificationTypeModification = 1,
    NotificationTypeNewPhoto = 2,
    NotificationTypeNewChat = 3,
    NotificationTypeNewFollower = 4,
    NotificationTypeFollowRequest = 5
};

// Init
- (void)setupWithAttributesFromWeb:(NSDictionary*)attributes;
+ (NSArray*)arrayWithArrayOfAttributesFromWeb:(NSArray*)array;

// Requests
+ (LocalNotificationCoreData*)requestLocalNotificationWithAttributes:(NSDictionary*)attributes;
+ (NSArray*)requestLocalNotificationsWithType:(enum NotificationType)type;
+ (NSArray*)requestAllLocalNotifications;
+ (NSArray*)requestLocalNotificationsWithTypeDifferentFromType:(enum NotificationType)type;

// Release
+ (void)deleteNotification:(LocalNotificationCoreData*)notif;
+ (void)resetNotifcationsLocal;

@end
