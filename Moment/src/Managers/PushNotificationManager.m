//
//  PushNotificationManager.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PushNotificationManager.h"
#import "DeviceModel.h"
#import "LocalNotification.h"
#import "VoletViewController.h"
#import "Config.h"

#import "MTStatusBarOverlay.h"

@implementation PushNotificationManager {
    @private
    MomentClass *actualMoment;
    SEL chatNotifAction;
    NSInteger chatNbNotifsUnread;
}

@synthesize chatAlertView = _chatAlertView;
@synthesize nbNotifcations = _nbNotifcations;

#pragma mark - Singleton

static PushNotificationManager *sharedInstance = nil;

+ (PushNotificationManager*)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        chatNbNotifsUnread = 0;
    }
    return self;
}

#pragma mark - Push Notification

- (void)saveDeviceToken:(NSData*)deviceToken {
    NSString *stringFormat = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    stringFormat = [stringFormat stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //NSLog(@"%@",stringFormat);
    
    [DeviceModel setDeviceToken:stringFormat];
}

- (void)receivePushNotification:(NSDictionary*)attributes updateUI:(BOOL)updateUI
{
    NSLog(@"Push Notification : %@", attributes);
    
    NSDictionary *aps = attributes[@"aps"];
    enum NotificationType pushType = [attributes[@"type_id"] intValue];
    NSNumber *momentId = attributes[@"id_moment"];
        
    // Update Badge Number
    [[PushNotificationManager sharedInstance] setNbNotifcations:[aps[@"badge"] intValue]];
    
    // Update volet
    [[VoletViewController volet] loadNotifications];
     
    switch (pushType) {
        case NotificationTypeNewChat:
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewChat
                                                                object:@{
                                                                        @"momentId":momentId,
                                                                        @"message":aps[@"alert"],
                                                                        @"chatId":attributes[@"chat_id"]
                                                                        }
             ];
            break;
            
        case NotificationTypeInvitation:
            [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:@"Nouvelle invitation" duration:1 animated:YES];
            break;
            
        case NotificationTypeModification:
            [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:@"Nouvelle modification" duration:1 animated:YES];
            break;
            
        case NotificationTypeNewPhoto:
            [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:@"Nouvelle Photo" duration:1 animated:YES];
            break;
        
        default:
            [[[UIAlertView alloc] initWithTitle:@"Moment"
                                        message:aps[@"alert"]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
            break;
    }
}

- (void)failToReceiveNotification:(NSError*)error {
    [[[UIAlertView alloc] initWithTitle:@"Push Notification Error"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

#pragma mark - Nombre Notifications

- (void)resetNotificationNumber {
    self.nbNotifcations = 0;
}

- (void)setNbNotifcations:(NSInteger)nbNotifcations {
    // Force positif
    if(nbNotifcations < 0)
        nbNotifcations = 0;
    
    // Update
    _nbNotifcations = nbNotifcations;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.nbNotifcations];
    
    // Notify
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChangeBadgeNumber object:@(nbNotifcations)];
}

#pragma mark - Local Notifications

- (void)addNotificationObservers {
    //NSLog(@"add notifs");
    // New Chat
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifNewChat:)
                                                 name:kNotificationNewChat
                                               object:nil];
}

- (void)removeNotifications {
    //NSLog(@"remove notifs");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNewChat object:nil];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Nouveau message chat
    if(alertView == self.chatAlertView) {
        
        // Bouton OK
        if (buttonIndex == 1) {
            if(chatNotifAction && [self respondsToSelector:chatNotifAction]) {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:chatNotifAction];
                #pragma clang diagnostic pop
            }
            chatNotifAction = nil;
        }
        
    }
}

#pragma mark - Chat

- (void)alertViewWithChatMessage:(NSString*)message {
    
    self.chatAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PushNotification_NewChat_AlertView_Title", nil)
                                message:message
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                    otherButtonTitles:NSLocalizedString(@"AlertView_Button_OK", nil), nil];
    
    [self.chatAlertView show];
}

- (void)notifNewChat:(NSNotification*)notification
{
    // Récupérer moment
    NSNumber *momentId = (NSNumber*)notification.object[@"momentId"];
    NSString *message = (NSString*)notification.object[@"message"];
    actualMoment = [MomentCoreData requestMomentWithAttributes:@{@"momentId":momentId}];
    
    // Actual View Controller
    UIViewController *actualViewController = [AppDelegate actualViewController];
    
    // Status Bar Message
    [[MTStatusBarOverlay sharedInstance]
     postImmediateFinishMessage:NSLocalizedString(@"StatusBarOverlay_PushNotification_NewMessage", nil)
     duration:1
     animated:YES];
    
    // On est sur le Chat
    if([actualViewController isMemberOfClass:[ChatViewController class]]) {
        
        ChatViewController *chatViewController = (ChatViewController*)actualViewController;
        [chatViewController loadMessagesForPage:1 atPosition:ChatViewControllerMessagePositionBottom
                                      withEnded:^{
            // Bloc nécessaire pour ne pas afficher le loader de rechargement
        }];
        
    }
    // On est dans un moment
    else if([actualViewController isMemberOfClass:[PhotoViewController class]] || [actualViewController isMemberOfClass:[InfoMomentViewController class]]) {
        
        UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)actualViewController;
        
        // Si c'est le même moment
        if(actualMoment.momentId == momentViewController.moment.momentId) {
            chatNotifAction = @selector(chatActionScrollToChat);
        }
        // C'est un autre moment
        else {
            chatNotifAction = @selector(chatActionPopToTimeLineAndOpenNewMoment);
        }
        
        [self alertViewWithChatMessage:message];
    }
    // On est sur la timeLine
    else if([actualViewController isMemberOfClass:[TimeLineViewController class]]) {
        chatNotifAction = @selector(chatActionOpenNewMoment);
        [self alertViewWithChatMessage:message];
    }
    
}

- (void)chatActionScrollToChat {
    // Récupérer view controller
    UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)[AppDelegate actualViewController];
    
    RootOngletsViewController *rootViewController = (RootOngletsViewController*)momentViewController.rootViewController;
    [rootViewController addAndScrollToOnglet:OngletChat];
}

- (void)chatActionOpenNewMoment {
    TimeLineViewController *timeLine = (TimeLineViewController*)[AppDelegate actualViewController];
    [timeLine showTchatView:actualMoment];
}

- (void)chatActionPopToTimeLineAndOpenNewMoment {
    UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)[AppDelegate actualViewController];
    
    RootOngletsViewController *rootViewController = (RootOngletsViewController*)momentViewController.rootViewController;
    
    [AppDelegate updateActualViewController:rootViewController.timeLine];
    [rootViewController.navigationController popViewControllerAnimated:NO];
    [self chatActionOpenNewMoment];
}


#pragma mark - Invitation

#pragma mark - Photo

#pragma mark - Modification


@end
