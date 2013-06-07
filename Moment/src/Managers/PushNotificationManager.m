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
    SEL photoNotifAction;
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

- (BOOL)pushNotificationEnabled {
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] & UIRemoteNotificationTypeAlert;
}

- (void)pushNotificationDisabledAlertView {
    [[[UIAlertView alloc]
      initWithTitle:NSLocalizedString(@"PushNotification_Disabled_AlertView_Title", nil)
      message:NSLocalizedString(@"PushNotification_Disabled_AlertView_Message", nil)
      delegate:nil
      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
      otherButtonTitles:nil]
     show];
}

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
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewPhoto
                                                                object:@{
                                                                         @"momentId":momentId
                                                                         }
             ];
            
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
    // New Photo
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifNewPhoto:)
                                                 name:kNotificationNewPhoto
                                               object:nil];
}

- (void)removeNotifications {
    //NSLog(@"remove notifs");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNewChat object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNewPhoto object:nil];
}

/****************************************************************
 *              GESTION PUSH NOTIFICATIONS
 ****************************************************************/


#pragma mark - UIAlertView Delegate

- (void)performSelector:(SEL*)selector
              alertView:(UIAlertView*)alertView
      targetedAlertView:(UIAlertView*)targetedAlertView
            buttonIndex:(NSInteger)buttonIndex
{
    // Nouveau message chat
    if(alertView == targetedAlertView) {
        
        // Bouton OK
        if (buttonIndex == 1) {
            if(  (selector && *selector) && [self respondsToSelector:(*selector)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:(*selector)];
#pragma clang diagnostic pop
            }
            *selector = nil;
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Nouveau message chat
    [self performSelector:(&chatNotifAction)
                alertView:alertView
        targetedAlertView:self.chatAlertView
              buttonIndex:buttonIndex];
    
    // Nouvelle Photo
    [self performSelector:(&photoNotifAction)
                alertView:alertView
        targetedAlertView:self.photoAlertView
              buttonIndex:buttonIndex];
}


#pragma mark - Généric

- (void)actionScrollToOnglet:(enum OngletRank)onglet {
    // Récupérer view controller
    UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)[AppDelegate actualViewController];
    
    RootOngletsViewController *rootViewController = (RootOngletsViewController*)momentViewController.rootViewController;
    [rootViewController addAndScrollToOnglet:onglet];
}

- (void)actionOpenNewMoment:(enum OngletRank)onglet {
    TimeLineViewController *timeLine = (TimeLineViewController*)[AppDelegate actualViewController];
    switch (onglet) {
        case OngletPhoto:
            [timeLine showPhotoView:actualMoment];
            break;
        
        case OngletChat:
            [timeLine showTchatView:actualMoment];
            break;
            
        case OngletInfoMoment:
            [timeLine showInfoMomentView:actualMoment];
            break;
            
        default:
            break;
    }
    
}

- (void)actionPopToTimeLineAndOpenNewMoment:(enum OngletRank)onglet {
    UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)[AppDelegate actualViewController];
    
    RootOngletsViewController *rootViewController = (RootOngletsViewController*)momentViewController.rootViewController;
    
    [AppDelegate updateActualViewController:rootViewController.timeLine];
    [rootViewController.navigationController popViewControllerAnimated:NO];
    [self actionOpenNewMoment:onglet];
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
    [self actionScrollToOnglet:OngletChat];
}

- (void)chatActionOpenNewMoment {
    [self actionOpenNewMoment:OngletChat];
}

- (void)chatActionPopToTimeLineAndOpenNewMoment {
    [self actionPopToTimeLineAndOpenNewMoment:OngletChat];
}

#pragma mark - Photo

- (void)alertViewPhotoWithMessage:(NSString*)message {
    
    self.photoAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PushNotification_NewPhoto_AlertView_Title", nil)
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"AlertView_Button_OK", nil), nil];
    
    [self.photoAlertView show];
}

- (void)notifNewPhoto:(NSNotification*)notification
{
    // Récupérer moment
    NSNumber *momentId = (NSNumber*)notification.object[@"momentId"];
    actualMoment = [MomentCoreData requestMomentWithAttributes:@{@"momentId":momentId}];
    NSString *message = [NSString stringWithFormat:@"Nouvelle Photo sur %@", actualMoment.titre];
    
    // Actual View Controller
    UIViewController *actualViewController = [AppDelegate actualViewController];
    
    // Status Bar Message
    [[MTStatusBarOverlay sharedInstance]
     postImmediateFinishMessage:NSLocalizedString(@"StatusBarOverlay_PushNotification_NewMessage", nil)
     duration:1
     animated:YES];
    
    // On est sur les Photos
    if([actualViewController isMemberOfClass:[PhotoViewController class]]) {
        
        PhotoViewController *photoViewController = (PhotoViewController*)actualViewController;
        [photoViewController loadPhotos];
        
    }
    // On est dans un moment
    else if([actualViewController isMemberOfClass:[ChatViewController class]] || [actualViewController isMemberOfClass:[InfoMomentViewController class]]) {
        
        UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)actualViewController;
        
        // Si c'est le même moment
        if(actualMoment.momentId == momentViewController.moment.momentId) {
            photoNotifAction = @selector(photoActionScrollToPhoto);
        }
        // C'est un autre moment
        else {
            photoNotifAction = @selector(photoActionPopToTimeLineAndOpenNewMoment);
        }
        
        [self alertViewPhotoWithMessage:message];
    }
    // On est sur la timeLine
    else if([actualViewController isMemberOfClass:[TimeLineViewController class]]) {
        photoNotifAction = @selector(photoActionOpenNewMoment);
        [self alertViewPhotoWithMessage:message];
    }
    
}
- (void)photoActionScrollToPhoto {
    [self actionScrollToOnglet:OngletPhoto];
}

- (void)photoActionOpenNewMoment {
    [self actionOpenNewMoment:OngletPhoto];
}

- (void)photoActionPopToTimeLineAndOpenNewMoment {
    [self actionPopToTimeLineAndOpenNewMoment:OngletPhoto];
}

#pragma mark - Invitation

#pragma mark - Modification


@end
