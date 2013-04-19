//
//  ParametreNotification.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 16/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ParametreNotificationType {
    ParametreNotificationTypeInvitation = 0,
    ParametreNotificationTypeModification = 1,
    ParametreNotificationTypeNewPhoto = 2,
    ParametreNotificationTypeNewChat = 3,
    ParametreNotificationTypeNewFollower = 4
    };

enum ParametreNotificationMode {
    ParametreNotificationModeEmail = 0,
    ParametreNotificationModePush = 1
    };

@interface ParametreNotification : NSObject

// Server
+ (void)getParametres:(void (^) (NSArray* parametres))block;

+ (void)changeParametres:(enum ParametreNotificationType)paramType
                    mode:(enum ParametreNotificationMode)mode
               withEnded:(void (^) (BOOL success))block;

// Local
+ (BOOL)settingsStoredLocally;
+ (void)store:(BOOL)value
         type:(enum ParametreNotificationType)type
         mode:(enum ParametreNotificationMode)mode;
+ (BOOL)localValueForType:(enum ParametreNotificationType)type
                     mode:(enum ParametreNotificationMode)mode;
+ (void)clearSettingsLocal;

@end
