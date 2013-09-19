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
#import "RowIndexInVolet.h"
#import "RedirectionManager.h"
#import "RevivrePartagerViewController.h"

#import "MTStatusBarOverlay.h"

@implementation PushNotificationManager {
@private
    MomentClass *actualMoment;
    SEL chatNotifAction;
    SEL photoNotifAction;
    NSInteger chatNbNotifsUnread;
    UIApplicationState applicationState;
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
    
    [DeviceModel setDeviceToken:stringFormat];
}

- (void)receivePushNotification:(NSDictionary*)attributes withApplicationState:(UIApplicationState)state updateUI:(BOOL)updateUI
{
    applicationState = state;
    
    NSDictionary *aps = attributes[@"aps"];
    enum NotificationType pushType = [attributes[@"type_id"] intValue];
    NSNumber *momentId = attributes[@"id_moment"];
    
    // Update Badge Number
    RowIndexInVolet *rowIndexInVolet = [RowIndexInVolet sharedManager];
    [self setNbNotifcations:[aps[@"badge"] intValue]+rowIndexInVolet.indexNotifications.count];
    
    // Update volet
    [[VoletViewController volet] loadNotifications];
    
    switch (pushType) {
        case NotificationTypeNewChat: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewChat
                                                                object:@{
             @"momentId":momentId,
             @"message":aps[@"alert"],
             @"chatId":attributes[@"chat_id"]
             }
             ];
            
            [[RedirectionManager sharedInstance] sendRedirectionToMomentWithId:momentId withType:NotificationTypeNewChat andWithApplicationState:applicationState];
        }
            break;
            
        case NotificationTypeInvitation:
            [[MTStatusBarOverlay sharedInstance]
             postImmediateFinishMessage:NSLocalizedString(@"StatusBarOverlay_PushNotification_NewInvitation", nil)
             duration:1 animated:YES];
            break;
            
        case NotificationTypeModification:
            [[MTStatusBarOverlay sharedInstance]
             postImmediateFinishMessage:NSLocalizedString(@"StatusBarOverlay_PushNotification_NewModification", nil)
             duration:1 animated:YES];
            break;
            
        case NotificationTypeNewPhoto: {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewPhoto
                                                                object:@{
             @"momentId":momentId
             }
             ];
            
            [[RedirectionManager sharedInstance] sendRedirectionToMomentWithId:momentId withType:NotificationTypeNewPhoto andWithApplicationState:applicationState];
        } break;
            
        case NotificationTypeFollowRequest:
            [[MTStatusBarOverlay sharedInstance]
             postImmediateFinishMessage:NSLocalizedString(@"StatusBarOverlay_PushNotification_NewFollowRequest", nil)
             duration:1 animated:YES];
            break;
            
        case NotificationTypeNewFollower:
            [[MTStatusBarOverlay sharedInstance]
             postImmediateFinishMessage:NSLocalizedString(@"StatusBarOverlay_PushNotification_NewFollower", nil)
             duration:1 animated:YES];
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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nbNotifcations];
    
    // Notify
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChangeBadgeNumber object:@(nbNotifcations)];
}

#pragma mark - Local Notifications

- (void)addNotificationObservers {
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
            } else {
                
                if (alertView == self.chatAlertView) {
                    [self removeNotifInVoletWithMomentId:actualMoment.momentId andWithType:NotificationTypeNewChat];
                    [self sendRedirectionToMomentWithId:actualMoment.momentId withType:NotificationTypeNewChat];
                } else if (alertView == self.photoAlertView) {
                    [self removeNotifInVoletWithMomentId:actualMoment.momentId andWithType:NotificationTypeNewPhoto];
                    [self sendRedirectionToMomentWithId:actualMoment.momentId withType:NotificationTypeNewPhoto];
                }
                
            }
            
            *selector = nil;
        }
        
    }
}

- (void)removeNotifInVoletWithMomentId:(NSNumber *)momentId andWithType:(enum NotificationType)type
{
    
    // Passera l'icône en gris après le clic.
    RowIndexInVolet *rowIndexInVolet = [RowIndexInVolet sharedManager];
    
    NSMutableArray *tempsNotifs = [NSMutableArray array];
    
    for (LocalNotification *notif_save in rowIndexInVolet.indexNotifications) {
        
        if (![notif_save.moment.momentId isEqualToNumber:momentId]) {
            [tempsNotifs addObject:notif_save];
        } else {
            if (notif_save.type != type) {
                [tempsNotifs addObject:notif_save];
            } /*else {
                NSLog(@"Je grise id_notif = %@",notif_save.id_notif);
            }*/
        }
    }
    
    [rowIndexInVolet setIndexNotifications:tempsNotifs];
    
    
    // Update Badge Number
    [self setNbNotifcations:rowIndexInVolet.indexNotifications.count];
    
    // Update volet
    [[VoletViewController volet] loadNotifications];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ([alertView isEqual:self.chatAlertView]) {
        // Nouveau message chat
        [self performSelector:(&chatNotifAction)
                    alertView:alertView
            targetedAlertView:self.chatAlertView
                  buttonIndex:buttonIndex];
        
    } else if ([alertView isEqual:self.photoAlertView]) {
        // Nouvelle Photo
        [self performSelector:(&photoNotifAction)
                    alertView:alertView
            targetedAlertView:self.photoAlertView
                  buttonIndex:buttonIndex];
    }
}


#pragma mark - Généric

- (void)actionScrollToOnglet:(enum OngletRank)onglet {
    // Récupérer view controller
    UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)[AppDelegate actualViewController];
    
    RootOngletsViewController *rootViewController = (RootOngletsViewController*)momentViewController.rootViewController;
    [rootViewController addAndScrollToOnglet:onglet];
}

- (void)actionOpenNewMoment:(enum OngletRank)onglet {
    UIViewController *actualViewController = [AppDelegate actualViewController];
    TimeLineViewController *timeLine = (TimeLineViewController *)actualViewController;
    
    switch (onglet) {
        case OngletPhoto: {
            [timeLine showPhotoView:actualMoment];
            
            if([actualViewController isMemberOfClass:[PhotoCollectionViewController class]]) {
                PhotoCollectionViewController *photoViewController = (PhotoCollectionViewController*)actualViewController;
                
                if([photoViewController.moment.momentId isEqualToNumber:actualMoment.momentId]) {
                    // Reload Photos
                    [photoViewController loadPhotosFromPage:1];
                }
            }
        }
            break;
            
        case OngletChat: {
            [timeLine showTchatView:actualMoment];
            
            if ([actualViewController isKindOfClass:[ChatViewController class]]) {
                ChatViewController *chatViewController = (ChatViewController *)actualViewController;
                
                if([chatViewController.moment.momentId isEqualToNumber:actualMoment.momentId]) {
                    // Reload Chat
                    [chatViewController loadMessagesForPage:1
                                                 atPosition:ChatViewControllerMessagePositionBottom
                                                  withEnded:^{
                                                      // Bloc nécessaire pour ne pas afficher le loader de rechargement
                                                  }];
                }
            }
        }
            break;
            
        case OngletInfoMoment: {
            [timeLine showInfoMomentView:actualMoment];
            
            if([actualViewController isMemberOfClass:[InfoMomentViewController class]]) {
                InfoMomentViewController *infoMomentViewController = (InfoMomentViewController*)actualViewController;
                
                if([infoMomentViewController.moment.momentId isEqualToNumber:actualMoment.momentId]) {
                    // Reload Moment Infos
                    [infoMomentViewController reloadData];
                }
            }
        }
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

- (void)alertViewChatWithMessage:(NSString*)message {
    
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
        // Si c'est le même Moment
        if([chatViewController.moment.momentId isEqualToNumber:actualMoment.momentId]) {
            // Reload Chat
            [chatViewController loadMessagesForPage:1
                                         atPosition:ChatViewControllerMessagePositionBottom
                                          withEnded:^{
                                              // Bloc nécessaire pour ne pas afficher le loader de rechargement
                                          }];
        } else {
            chatNotifAction = @selector(chatActionPopToTimeLineAndOpenNewMoment);
            [self alertViewChatWithMessage:message];
        }
        
    }
    // On est dans un moment
    else if([actualViewController isMemberOfClass:[PhotoCollectionViewController class]] || [actualViewController isMemberOfClass:[InfoMomentViewController class]]) {
        
        UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)actualViewController;
        
        chatNotifAction = nil;
        
        // Si c'est le même moment
        if([actualMoment.momentId isEqualToNumber:momentViewController.moment.momentId]) {
            chatNotifAction = @selector(chatActionScrollToChat);
        } else {
            chatNotifAction = @selector(chatActionPopToTimeLineAndOpenNewMoment);
        }
        [self alertViewChatWithMessage:message];
        
        /*
         // C'est un autre moment
         else {
         chatNotifAction = @selector(chatActionPopToTimeLineAndOpenNewMoment);
         }
         
         [self alertViewWithChatMessage:message];
         */
    } else {
        
        if (applicationState == UIApplicationStateActive) {
            chatNotifAction = nil;
            [self alertViewChatWithMessage:message];
        } else {
            chatNotifAction = nil;
        }
    }
    /*
     // On est sur la timeLine
     else if([actualViewController isMemberOfClass:[TimeLineViewController class]]) {
     chatNotifAction = @selector(chatActionOpenNewMoment);
     [self alertViewWithChatMessage:message];
     }
     // On est sur le feed
     else if([actualViewController isMemberOfClass:[FeedViewController class]]) {
     FeedViewController *feed = (FeedViewController*)actualViewController;
     [feed.rootViewController clicChangeTimeLine];
     photoNotifAction = @selector(chatActionOpenNewMoment);
     [self alertViewWithChatMessage:message];
     }
     */
    
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

- (void)sendRedirectionToMomentWithId:(NSNumber *)momentId withType:(int)type
{
    [[RedirectionManager sharedInstance] sendRedirectionToMomentWithId:momentId withType:type andWithApplicationState:-1];
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
     postImmediateFinishMessage:NSLocalizedString(@"StatusBarOverlay_PushNotification_NewPhoto", nil)
     duration:1
     animated:YES];
    
    // On est sur les Photos
    if([actualViewController isMemberOfClass:[PhotoCollectionViewController class]]) {
        
        PhotoCollectionViewController *photoViewController = (PhotoCollectionViewController*)actualViewController;
        // C'est le même Moment
        if([photoViewController.moment.momentId isEqualToNumber:actualMoment.momentId]) {
            // Reload Photos
            [photoViewController loadPhotosFromPage:1];
        } else {
            photoNotifAction = @selector(photoActionPopToTimeLineAndOpenNewMoment);
            [self alertViewPhotoWithMessage:message];
        }
        
    }
    // On est dans un moment
    else if([actualViewController isMemberOfClass:[ChatViewController class]] || [actualViewController isMemberOfClass:[InfoMomentViewController class]]) {
        
        UIViewController <OngletViewController> *momentViewController = (UIViewController <OngletViewController> *)actualViewController;
        
        photoNotifAction = nil;
        
        // Si c'est le même moment
        if([actualMoment.momentId isEqualToNumber:momentViewController.moment.momentId]) {
            photoNotifAction = @selector(photoActionScrollToPhoto);
        } else {
            photoNotifAction = @selector(photoActionPopToTimeLineAndOpenNewMoment);
        }
        [self alertViewPhotoWithMessage:message];
        
        // C'est un autre moment
        /*
         else {
         photoNotifAction = @selector(photoActionPopToTimeLineAndOpenNewMoment);
         }
         */
        
        //[self alertViewPhotoWithMessage:message];
    } else {
        if (applicationState == UIApplicationStateActive) {
            photoNotifAction = nil;
            
            if( ![actualViewController isMemberOfClass:[RevivrePartagerViewController class]] ) {
                [self alertViewPhotoWithMessage:message];
            }
        } else {
            photoNotifAction = nil;
        }
    }
    /*
     // On est sur la timeLine
     else if([actualViewController isMemberOfClass:[TimeLineViewController class]]) {
     photoNotifAction = @selector(photoActionOpenNewMoment);
     [self alertViewPhotoWithMessage:message];
     }
     // On est sur le feed
     else if([actualViewController isMemberOfClass:[FeedViewController class]]) {
     FeedViewController *feed = (FeedViewController*)actualViewController;
     [feed.rootViewController clicChangeTimeLine];
     photoNotifAction = @selector(photoActionOpenNewMoment);
     [self alertViewPhotoWithMessage:message];
     }
     */
    
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
