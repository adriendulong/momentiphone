//
//  LocalNotificationCoreData+Model.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 20/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "LocalNotificationCoreData+Model.h"
#import "Config.h"
#import "MomentClass+Mapping.h"

@implementation LocalNotificationCoreData (Model)

- (void)setupWithAttributesFromWeb:(NSDictionary*)attributes
{
    if(attributes) {
        self.date = [NSDate dateWithTimeIntervalSince1970:[attributes[@"time"] doubleValue]];
        self.moment = [MomentCoreData requestMomentAsCoreDataWithAttributes:[MomentClass mappingToLocalWithAttributes:attributes[@"moment"]]];
        self.type = attributes[@"type_id"];
    }
}

+ (NSArray*)arrayWithArrayOfAttributesFromWeb:(NSArray*)array
{
    NSMutableArray *notifications = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for( NSDictionary* attr in array ) {
        [notifications addObject:[LocalNotificationCoreData requestLocalNotificationWithAttributes:attr]];
    }
    return notifications;
}


+ (LocalNotificationCoreData*)newLocalNotificationWithAttributes:(NSDictionary*)attributes
{
    LocalNotificationCoreData* localNotification = [NSEntityDescription insertNewObjectForEntityForName:@"LocalNotificationCoreData" inManagedObjectContext:[Config sharedInstance].managedObjectContext];
    
    [localNotification setupWithAttributesFromWeb:attributes];
    [[Config sharedInstance] saveContext];
    
    return localNotification;
}

#pragma mark - Requests

+ (LocalNotificationCoreData*)requestLocalNotificationWithAttributes:(NSDictionary*)attributes
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalNotificationCoreData"];
    //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"momentId" ascending:YES];
    //request.sortDescriptors = @[sort];
    request.predicate = [NSPredicate predicateWithFormat:@"(date = %@) AND (type = %@) AND (moment.momentId = %@)",
                         [NSDate dateWithTimeIntervalSince1970:[attributes[@"time"] doubleValue]],
                         attributes[@"type_id"],
                         attributes[@"moment"][@"id"] ];
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestLocalNotificationWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    else if ([matches count] == 0) {
        return [LocalNotificationCoreData newLocalNotificationWithAttributes:attributes];
    }
    
    return matches[0];
}

+ (NSArray*)requestLocalNotificationsWithType:(enum NotificationType)type
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalNotificationCoreData"];
    request.predicate = [NSPredicate predicateWithFormat:@"type = %@", @(type)];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestLocalNotificationWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    
    return matches;
}

+ (NSArray*)requestAllLocalNotifications
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalNotificationCoreData"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestLocalNotificationWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    
    return matches;
}

+ (NSArray*)requestLocalNotificationsWithTypeDifferentFromType:(enum NotificationType)type
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalNotificationCoreData"];
    request.predicate = [NSPredicate predicateWithFormat:@"type != %@", @(type)];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestLocalNotificationWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    
    return matches;
}

#pragma mark - Release

+ (void)deleteNotification:(LocalNotificationCoreData*)notif
{
    [[Config sharedInstance].managedObjectContext deleteObject:notif];
    [[Config sharedInstance] saveContext];
}

+ (void)resetNotifcationsLocal
{
    NSArray *notifs = [self requestAllLocalNotifications];
    for(LocalNotificationCoreData *n in notifs) {
        [[Config sharedInstance].managedObjectContext deleteObject:n];
    }
    [[Config sharedInstance] saveContext];
}

#pragma mark - Debug

- (NSString*)description {
    
    NSString *type = nil;
    switch (self.type.intValue) {
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
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"type = %@\nmoment = %@\ndate = %@", type, self.moment, self.date];
}

@end
