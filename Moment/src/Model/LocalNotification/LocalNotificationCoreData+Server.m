//
//  LocalNotificationCoreData+Server.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 20/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "LocalNotificationCoreData+Server.h"
#import "LocalNotificationCoreData+Model.h"
#import "AFMomentAPIClient.h"
#import "MomentClass+Server.h"
#import "PushNotificationManager.h"

@implementation LocalNotificationCoreData (Server)


+ (void)getNotificationWithEnded:(void (^) (NSDictionary* notifications))block
{
    NSString *path = @"notifications";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        //NSLog(@"\n\n-----------\nreponse = \n%@\n\n---------\n", JSON);
        
        // Web notifications -> Ajouté en local
        [self arrayWithArrayOfAttributesFromWeb:JSON[@"new_photos"]];
        [self arrayWithArrayOfAttributesFromWeb:JSON[@"invitations"]];
        [self arrayWithArrayOfAttributesFromWeb:JSON[@"modif_moment"]];
        [self arrayWithArrayOfAttributesFromWeb:JSON[@"new_chats"]];
        
        // Local Invitations
        NSArray *localInvitations = [self requestLocalNotificationsWithType:NotificationTypeInvitation];
        
        // Local Notifications
        NSArray *localNotifications = [self requestLocalNotificationsWithTypeDifferentFromType:NotificationTypeInvitation];
        
        if(block) {
            block(@{
                  @"invitations" : localInvitations,
                  @"notifications" : localNotifications,
                  });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
}

+ (void)resetNotificationsWithEnded:(void (^) (BOOL success))block
{
    NSString *path = @"resetnotifications";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        // Reset Badge
        [[PushNotificationManager sharedInstance] resetNotificationNumber];
        
        if(block) {
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
        
    }];
}

@end
