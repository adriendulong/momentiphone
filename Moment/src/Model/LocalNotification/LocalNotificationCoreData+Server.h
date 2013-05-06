//
//  LocalNotificationCoreData+Server.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 20/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "LocalNotificationCoreData.h"

@interface LocalNotificationCoreData (Server)

// Récupères les notifications depuis le server
+ (void)getNotificationWithEnded:(void (^) (NSDictionary* notifications))block;
// Récupères les invitations depuis le server
+ (void)getInvitationsWithEnded:(void (^) (NSDictionary* notifications))block;

// Vide les notifications sur le server
// --> Deprecated
+ (void)resetNotificationsWithEnded:(void (^) (BOOL success))block;

@end
