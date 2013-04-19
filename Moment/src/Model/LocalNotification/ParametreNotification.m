//
//  ParametreNotification.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 16/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ParametreNotification.h"
#import "AFMomentAPIClient.h"

@implementation ParametreNotification

// Stockage préférences en local
#define kParametreNotificationDefaultKey @"ParametresNotificationsDefaultKey"
#define kParametreNotificationInvitationPush @"ParametreNotificationInvitation_Push"
#define kParametreNotificationInvitationEmail @"ParametreNotificationInvitation_Email"
#define kParametreNotificationPhotoPush @"ParametreNotificationPhoto_Push"
#define kParametreNotificationPhotoEmail @"ParametreNotificationPhoto_Email"
#define kParametreNotificationMessagePush @"ParametreNotificationMessage_Push"
#define kParametreNotificationMessageEmail @"ParametreNotificationMessage_Email"
#define kParametreNotificationModificationPush @"ParametreNotificationModification_Push"
#define kParametreNotificationModificationEmail @"ParametreNotificationModification_Email"

#pragma mark - Server

+ (void)getParametres:(void (^) (NSArray* parametres))block
{
    NSString *path = @"paramsnotifs";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(block)
            block(JSON[@"params_notifs"]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block) {
            block(nil);
        }
        
    }];
}

+ (void)changeParametres:(enum ParametreNotificationType)paramType
                    mode:(enum ParametreNotificationMode)mode
               withEnded:(void (^) (BOOL success))block
{
    NSString *path = [NSString stringWithFormat:@"paramsnotifs/%d/%d", mode, paramType];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(block)
            block(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
        
    }];
}

#pragma mark - Stockage Local

+ (BOOL)settingsStoredLocally {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kParametreNotificationDefaultKey];
}

+ (BOOL)localValueForType:(enum ParametreNotificationType)type
                     mode:(enum ParametreNotificationMode)mode
{
    NSUserDefaults *userDefauts = [NSUserDefaults standardUserDefaults];
    
    switch (type) {
            
        case ParametreNotificationTypeInvitation:
            if(mode == ParametreNotificationModePush)
                return [userDefauts boolForKey:kParametreNotificationInvitationPush];
            return [userDefauts boolForKey:kParametreNotificationInvitationEmail];
            break;
            
        case ParametreNotificationTypeNewPhoto:
            if(mode == ParametreNotificationModePush)
                return [userDefauts boolForKey:kParametreNotificationPhotoPush];
            return [userDefauts boolForKey:kParametreNotificationPhotoEmail];
            break;
            
        case ParametreNotificationTypeNewChat:
            if(mode == ParametreNotificationModePush)
                return [userDefauts boolForKey:kParametreNotificationMessagePush];
            return [userDefauts boolForKey:kParametreNotificationMessageEmail];
            break;
            
        case ParametreNotificationTypeModification:
            if(mode == ParametreNotificationModePush)
                return [userDefauts boolForKey:kParametreNotificationModificationPush];
            return [userDefauts boolForKey:kParametreNotificationModificationEmail];
            break;
            
        default:
            return NO;
            break;
    }
}

+ (void)clearSettingsLocal {
    if([self settingsStoredLocally])
    {
        NSUserDefaults *userDefauts = [NSUserDefaults standardUserDefaults];
        [userDefauts removeObjectForKey:kParametreNotificationDefaultKey];
        [userDefauts removeObjectForKey:kParametreNotificationInvitationPush];
        [userDefauts removeObjectForKey:kParametreNotificationInvitationEmail];
        [userDefauts removeObjectForKey:kParametreNotificationMessagePush];
        [userDefauts removeObjectForKey:kParametreNotificationMessageEmail];
        [userDefauts removeObjectForKey:kParametreNotificationModificationPush];
        [userDefauts removeObjectForKey:kParametreNotificationModificationEmail];
        [userDefauts removeObjectForKey:kParametreNotificationPhotoPush];
        [userDefauts removeObjectForKey:kParametreNotificationPhotoEmail];
        [userDefauts synchronize];
    }
}

+ (void)store:(BOOL)value
         type:(enum ParametreNotificationType)type
         mode:(enum ParametreNotificationMode)mode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(![self settingsStoredLocally])
        [userDefaults setBool:YES forKey:kParametreNotificationDefaultKey];
    
    switch (type) {
            
        case ParametreNotificationTypeInvitation:
            if(mode == ParametreNotificationModePush)
                [userDefaults setBool:value forKey:kParametreNotificationInvitationPush];
            else
                [userDefaults setBool:value forKey:kParametreNotificationInvitationEmail];
            break;
            
        case ParametreNotificationTypeNewPhoto:
            if(mode == ParametreNotificationModePush)
                [userDefaults setBool:value forKey:kParametreNotificationPhotoPush];
            else
                [userDefaults setBool:value forKey:kParametreNotificationPhotoEmail];
            break;
            
        case ParametreNotificationTypeNewChat:
            if(mode == ParametreNotificationModePush)
                [userDefaults setBool:value forKey:kParametreNotificationMessagePush];
            else
                [userDefaults setBool:value forKey:kParametreNotificationMessageEmail];
            break;
            
        case ParametreNotificationTypeModification:
            if(mode == ParametreNotificationModePush)
                [userDefaults setBool:value forKey:kParametreNotificationModificationPush];
            else
                [userDefaults setBool:value forKey:kParametreNotificationModificationEmail];
            break;
            
        default:
            break;
    }
    
    [userDefaults synchronize];
}

@end
