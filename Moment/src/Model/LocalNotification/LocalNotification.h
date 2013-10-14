//
//  LocalNotification.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

enum NotificationType {
    NotificationTypeInvitation = 0,
    NotificationTypeModification = 1,
    NotificationTypeNewPhoto = 2,
    NotificationTypeNewChat = 3,
    NotificationTypeNewFollower = 4,
    NotificationTypeFollowRequest = 5
};

@interface LocalNotification : NSObject

@property (nonatomic, strong) NSDate * date;
@property (nonatomic) enum NotificationType type;
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, strong) UserClass *follower;
@property (nonatomic, strong) UserClass *requestFollower;
@property (nonatomic, strong) NSNumber *id_notif;

// ----- Init -----
- (id)initWithAttributesFromWeb:(NSDictionary*)attributes;
+ (NSArray*)arrayWithArrayOfAttributesFromWeb:(NSArray*)array;

// ----- Server -----
// Récupères les notifications depuis le server
+ (void)getNotificationWithEnded:(void (^) (NSDictionary* notifications))block;
// Récupères les invitations depuis le server
+ (void)getInvitationsWithEnded:(void (^) (NSDictionary* notifications))block;

@end
