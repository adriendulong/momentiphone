//
//  LocalNotification.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "LocalNotification.h"

#import "MomentClass+Mapping.h"
#import "AFMomentAPIClient.h"
#import "PushNotificationManager.h"

@implementation LocalNotification

#pragma mark - Init

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes
{
    self = [super init];
    if(self) {
        
        if(attributes) {
            self.date = [NSDate dateWithTimeIntervalSince1970:[attributes[@"time"] doubleValue]];
            self.type = [attributes[@"type_id"] intValue];
            
            switch (self.type) {
                    
                case NotificationTypeNewFollower: {
                    self.follower = [[UserClass alloc] initWithAttributesFromWeb:attributes[@"follower"]];
                    
                } break;
                    
                case NotificationTypeFollowRequest: {
                    self.requestFollower = [[UserClass alloc] initWithAttributesFromWeb:attributes[@"request_follower"]];
                    
                } break;
                    
                default: {
                    self.moment = [MomentCoreData requestMomentWithAttributes:[MomentClass mappingToLocalWithAttributes:attributes[@"moment"]]];
                } break;
            }
            
            
        }
        
    }
    return self;
}

+ (NSArray*)arrayWithArrayOfAttributesFromWeb:(NSArray*)array
{
    NSMutableArray *notifications = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for( NSDictionary* attr in array ) {
        [notifications addObject:[[LocalNotification alloc] initWithAttributesFromWeb:attr]];
    }
    return notifications;
}

#pragma mark - Server


+ (void)getNotificationWithEnded:(void (^) (NSDictionary* notifications))block
{
    NSString *path = @"notifications";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        //NSLog(@"\n\n-----------\nreponse = \n%@\n\n---------\n", JSON);
        
        NSArray *localNotifications = [self arrayWithArrayOfAttributesFromWeb:JSON[@"notifications"]];
        NSNumber *total = JSON[@"total_notifs"] ?: @(0);
        NSNumber *newNotifs = JSON[@"nb_new_notifs"] ?: @(0);
        
        
        if(block) {
            block(@{
                  @"nb_new_notifs" : newNotifs,
                  @"total_notifs" : total,
                  @"notifications" : localNotifications
                  });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
}

+ (void)getInvitationsWithEnded:(void (^) (NSDictionary* notifications))block
{
    NSString *path = @"invitations";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        //NSLog(@"\n\n-----------\nreponse = \n%@\n\n---------\n", JSON);
        
        NSArray *localInvitations = [self arrayWithArrayOfAttributesFromWeb:JSON[@"invitations"]];
        NSNumber *total = JSON[@"total_notifs"] ?: @(0);
        NSNumber *newNotifs = JSON[@"nb_new_notifs"] ?: @(0);
        
        if(block) {
            block(@{
                  @"nb_new_notifs" : newNotifs,
                  @"total_notifs" : total,
                  @"invitations" : localInvitations
                  });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
}

#pragma mark - Debug

- (NSString*)description {
    
    NSString *type = nil;
    switch (self.type) {
        case NotificationTypeInvitation:
            type = @"NotificationTypeInvitation";
            break;
            
        case NotificationTypeModification:
            type = @"NotificationTypeModification";
            break;
            
        case NotificationTypeNewChat:
            type = @"NotificationTypeNewChat";
            break;
            
        case NotificationTypeNewPhoto:
            type = @"NotificationTypeNewPhoto";
            break;
            
        case NotificationTypeNewFollower:
            type = @"NotificationTypeNewFollower";
            break;
            
        case NotificationTypeFollowRequest:
            type = @"NotificationTypeFollowRequest";
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"type = %@\nmoment = %@\ndate = %@", type, self.moment, self.date];
}

@end
