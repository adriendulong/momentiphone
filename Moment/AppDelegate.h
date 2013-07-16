//
//  AppDelegate.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"
#import "TimeLineViewController.h"
#import "ChatViewController.h"
#import "GAI.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) UIViewController *actualViewController;
@property(nonatomic, retain) id<GAITracker> tracker; // Google Analytics Tracker

// In this sample the app delegate maintains a property for the current
// active session, and the view controllers reference the session via
// this property, as well as play a role in keeping the session object
// up to date; a more complicated application may choose to introduce
// a simple singleton that owns the active FBSession object as well
// as access to the object by the rest of the application
@property (strong, nonatomic) FBSession *session;

+ (UIViewController*)actualViewController;
+ (void)updateActualViewController:(UIViewController*)viewController ;

@end
