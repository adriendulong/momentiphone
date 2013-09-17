//
//  RedirectionManager.m
//  Moment
//
//  Created by SkeletonGamer on 06/08/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RedirectionManager.h"
#import "RootOngletsViewController.h"
#import "MomentClass+Server.h"
#import "HomeViewController.h"

@implementation RedirectionManager

#pragma mark - Singleton
static RedirectionManager *sharedInstance = nil;

+ (RedirectionManager *)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

#pragma mark - Parse URL
- (BOOL)handleOpenURL:(NSURL *)url withApplicationState:(UIApplicationState)state
{
    
    if (url && url.absoluteString.length > 0 && url.pathComponents[1]) {
        
        NSString *momentString = url.host;
        NSString *onglet = url.pathComponents[1];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *momentId = [numberFormatter numberFromString:momentString];
        
        
        if (momentId) {
            enum SchemeType type;
            
            if ([onglet isEqual:@"p"]) {
                type = SchemeTypePhoto;
            } else if ([onglet isEqual:@"c"]) {
                type = SchemeTypeChat;
            } else if ([onglet isEqual:@"i"]) {
                type = SchemeTypeInfo;
            } else {
                type = nil;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Redirection inconnue" message:@"Le scheme est incorrect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                return NO;
            }
            
            if (type) {
                [self sendRedirectionToMomentWithId:momentId withType:type andWithApplicationState:state];
                
                return YES;
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Problème de redirection" message:@"Le premier attribut n'est pas un nombre." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            return NO;
        }
    } else {
        return NO;
    }
    
    return nil;
}

#pragma mark Receive Redirection
- (void)sendRedirectionToMomentWithId:(NSNumber *)momentId withType:(int)type andWithApplicationState:(UIApplicationState)state
{
    
    if (state != UIApplicationStateActive || state == -1) {
        UIViewController *actualView = [AppDelegate actualViewController];
        
        [MomentClass getInfosMomentWithId:momentId.integerValue withEnded:^(NSDictionary *attributes) {
            if (attributes) {
                MomentClass *moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes];
                
                if ([actualView isKindOfClass:[InfoMomentViewController class]] ||
                    [actualView isKindOfClass:[PhotoViewController class]] ||
                    [actualView isKindOfClass:[ChatViewController class]] ) {
                    
                    InfoMomentViewController *infoMoment = (InfoMomentViewController *)actualView;
                    
                    if ([infoMoment.moment isEqual:moment]) {
                        switch (type) {
                                
                            case NotificationTypeNewPhoto:
                            case SchemeTypePhoto:
                                [infoMoment.rootViewController addAndScrollToOnglet:OngletPhoto];
                                break;
                                
                            case NotificationTypeModification:
                            case SchemeTypeInfo:
                                [infoMoment.rootViewController addAndScrollToOnglet:OngletInfoMoment];
                                break;
                                
                            case NotificationTypeNewChat:
                            case SchemeTypeChat:
                                [infoMoment.rootViewController addAndScrollToOnglet:OngletChat];
                                break;
                                
                            default:
                                [infoMoment.rootViewController addAndScrollToOnglet:OngletInfoMoment];
                                break;
                        }
                    }
                } else {
                    [self pushToCorrectControllerFrom:actualView withType:type andMoment:moment];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Problème de redirection" message:@"Cet évènement n'existe pas." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        } waitUntilFinished:YES];
    }
}

#pragma mark Perform Redirection
- (void)simpleRedirectionFromActualView:(UIViewController *)actualView withType:(int)type andMoment:(MomentClass *)moment
{
    if (actualView.modalViewController != nil) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [actualView dismissViewControllerAnimated:NO completion:nil];
    }
    
    NSArray *viewControllers = actualView.navigationController.viewControllers;
    
    [self pushToCorrectControllerFrom:viewControllers[0] withType:type andMoment:moment];
}

- (void)pushToCorrectControllerFrom:(UIViewController *)actualView withType:(int)type andMoment:(MomentClass *)moment
{
    [actualView.navigationController popToRootViewControllerAnimated:NO];
    
    if ([actualView isKindOfClass:[RootTimeLineViewController class]]) {
        [self pushFromRootTimeLineControllerWithActualView:actualView withType:type andMoment:moment];
    } else if ([actualView isKindOfClass:[HomeViewController class]]) {
        
        actualView = [AppDelegate actualViewController];
        
        if ([actualView isKindOfClass:[RootTimeLineViewController class]]) {            
            [self pushFromRootTimeLineControllerWithActualView:actualView withType:type andMoment:moment];
        }
    }
}

- (void)pushFromRootTimeLineControllerWithActualView:(UIViewController *)actualView withType:(int)type andMoment:(MomentClass *)moment
{
    RootTimeLineViewController *rootTimeline = (RootTimeLineViewController *)actualView;
    
    switch (type) {
            
        case NotificationTypeNewPhoto:
        case SchemeTypePhoto:
            [[rootTimeline timeLineForMoment:moment] showPhotoView:moment];
            break;
            
        case NotificationTypeModification:
        case SchemeTypeInfo:
            [[rootTimeline timeLineForMoment:moment] showInfoMomentView:moment];
            break;
            
        case NotificationTypeNewChat:
        case SchemeTypeChat:
            [[rootTimeline timeLineForMoment:moment] showTchatView:moment];
            break;
            
        default:
            [[rootTimeline timeLineForMoment:moment] showInfoMomentView:moment];
            break;
    }
}

@end
