//
//  LocalNotificationCoreData+Server.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 20/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "LocalNotificationCoreData.h"

@interface LocalNotificationCoreData (Server)

+ (void)getNotificationWithEnded:(void (^) (NSDictionary* notifications))block;
+ (void)resetNotificationsWithEnded:(void (^) (BOOL success))block;

@end
