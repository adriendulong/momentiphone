//
//  ParametreNotification.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 16/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

/*
 * Gestion des paramètres de notifications
 * -> Choix de Réception des paramètres par Email/Push Notification
 */

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

// ----------- Server --------------
// Récupère les préférences depuis le server
+ (void)getParametres:(void (^) (NSArray* parametres))block;

// Update les préférences sur le server
+ (void)changeParametres:(enum ParametreNotificationType)paramType
                    mode:(enum ParametreNotificationMode)mode
               withEnded:(void (^) (BOOL success))block;

// ----------- Local ---------------
// Retourne YES si des préférences sont stockées en local, NO sinon
+ (BOOL)settingsStoredLocally;

// Enregistre la préférence en local
+ (void)store:(BOOL)value
         type:(enum ParametreNotificationType)type
         mode:(enum ParametreNotificationMode)mode;

// Retourne la préférence stockée en local
+ (BOOL)localValueForType:(enum ParametreNotificationType)type
                     mode:(enum ParametreNotificationMode)mode;

// Vide les préférences stockées en local
+ (void)clearSettingsLocal;

@end
