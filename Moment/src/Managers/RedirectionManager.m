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

@implementation RedirectionManager

#pragma mark - Singleton

static RedirectionManager *sharedInstance = nil;

+ (RedirectionManager *)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
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
    
    NSLog(@"pushToCorrectControllerFrom | actualViewController = %@",actualView);
    
    if ([actualView isKindOfClass:[RootTimeLineViewController class]]) {
        
        RootTimeLineViewController *rootTimeline = (RootTimeLineViewController*)actualView;
        TimeLineViewController *timeline = [rootTimeline timeLineForMoment:moment];
        
        switch (type) {
                
            case NotificationTypeNewPhoto:
            case SchemeTypePhoto:
                [timeline showPhotoView:moment];
                break;
                
            case NotificationTypeModification:
            case SchemeTypeInfo:
                [timeline showInfoMomentView:moment];
                break;
                
            case NotificationTypeNewChat:
            case SchemeTypeChat:
                [timeline showTchatView:moment];
                break;
                
            default:
                [timeline showInfoMomentView:moment];
                break;
        }
    } else {
        NSLog(@"actualViewController = %@",actualView);
    }
}

@end
