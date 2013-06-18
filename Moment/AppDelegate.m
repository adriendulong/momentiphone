//
//  AppDelegate.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "AppDelegate.h"

//#import "SDURLCache.h"
#import "Config.h"
#import "HomeViewController.h"
#import "MomentCoreData+Model.h"
#import "HTAutocompleteTextField.h"
#import "TextFieldAutocompletionManager.h"
#import "FacebookManager.h"
#import "DeviceModel.h"
#import "PushNotificationManager.h"
#import "Three20/Three20.h"
#import "FullScreenPhotoViewController.h"
#import "Harpy.h"
#import "iRate.h"

@implementation AppDelegate

@synthesize HUD = _HUD;
@synthesize session = _session;
@synthesize actualViewController = _actualViewController;
@synthesize tracker = _tracker;

#pragma mark - Global View

+ (UIViewController*)actualViewController {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.actualViewController;
}

+ (void)updateActualViewController:(UIViewController*)viewController {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.actualViewController = viewController;
}

#pragma mark - Facebook

// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of a session object
// the session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [[FBSession activeSession] handleOpenURL:url];
}

#pragma mark - AppDelegate

+ (void)initialize
{
    [super initialize];
    
    /* ------------------ iRate ------------------- */
    /*          ---> Noter l'application <--        */
    /* -------------------------------------------- */
    //configure iRate
    iRate *config = [iRate sharedInstance];
    [config setAppStoreCountry:@"FR"];
#warning A enlever pour la prod !!
    [config setAppStoreID:361186462];
    [config setApplicationBundleID:@"com.c4mprod.beezik"];
    //config.daysUntilPrompt = 5; //5
    //config.usesUntilPrompt = 15; //15
#ifdef DEBUG
    config.verboseLogging = YES;
    config.previewMode = YES;
#else
    config.verboseLogging = NO;
#endif
    [iRate load];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ------------ Test Flight API -------------
    // !!!: Use the next line only during beta
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#pragma clang diagnostic pop
    [TestFlight takeOff:@"85ba03e5-22dc-45c5-9810-be2274ed75d1"];
    // ------------------------------------------
    
    // ---------------- Initialisation -----------------    
    HomeViewController *homeViewController = [[HomeViewController alloc] initWithXib];
    CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:homeViewController];
    [navigationController.navigationBar setHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    
    // -------------- Init Autocompletion ----------------
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[TextFieldAutocompletionManager sharedInstance]];
    
    
    // -------------- Default Background -----------------
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.window.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.window.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.window makeKeyAndVisible];
    
    // ----------------- SDURLCache ----------------------
    //getsion du cache pour les images
    /*
    SDURLCache *URLCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*2 diskCapacity:1024*1024*20 diskPath:[SDURLCache defaultCachePath]];
    [URLCache setIgnoreMemoryOnlyStoragePolicy:YES];
    [NSURLCache setSharedURLCache:URLCache];
    */
        
    // --------------- Push Notifications ----------------
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Application launched from Push Notification
    if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
            [[PushNotificationManager sharedInstance] receivePushNotification:dictionary updateUI:NO];
        }
	}
    
    // Restore Notification Badge Number
    [[PushNotificationManager sharedInstance] setNbNotifcations:[[UIApplication sharedApplication] applicationIconBadgeNumber]];
    
    // -------------------- Facebook ---------------------
    
    // FBSample logic
    // See if we have a valid token for the current state.
    [FBSession openActiveSessionWithReadPermissions:[FacebookManager sharedInstance].defaultReadPermissions
                                       allowLoginUI:NO
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      [[FacebookManager sharedInstance] sessionStateChanged:session state:status error:error];
                                  }];
    /*
    if (![FBSession openActiveSessionWithReadPermissions:[FacebookManager sharedInstance].defaultReadPermissions
                                            allowLoginUI:NO
                                       completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [[FacebookManager sharedInstance] sessionStateChanged:session state:status error:error];
    }])
    {
        // No? Display the login page.
        NSLog(@"Login fail");
    }*/
    
    // -------------------- Three20 ----------------------
    //            ----> Full Screnn Plugin <----
    // ---------------------------------------------------
    // -> FullScreen (TTPhotoViewController) URL Mapping
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    
    
    // ------------------ Harpy Alert --------------------
    //    ----> Vérifier version de l'application <----
    // ---------------------------------------------------
    
    // Set the App ID for your app
    [[Harpy sharedInstance] setAppID:@"662761817"];
    
    /* (Optional) Set the Alert Type for your app
     By default, the Singleton is initialized to HarpyAlertTypeOption */
    //[[Harpy sharedInstance] setAlertType:HarpyAlertTypeOption];
    
    // --------------- Google Analytics ------------------
    //         ----> Initialisation du Tracker <----
    // ---------------------------------------------------
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    //[GAI sharedInstance].dispatchInterval = 20; // Default = 2 min
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-36147731-1"];
    // Si on reste plus d'1 min inactif, les évenements sont envoyés sur une nouvelle session
    [self.tracker setSessionTimeout:60];
    
    // -------------------- Suppression du CoreData ----------------------
    //    ----> Vérification que la suppression s'est bien passée <----
    // -------------------------------------------------------------------
    /*
    if([[NSUserDefaults standardUserDefaults] boolForKey:kMomentsDeleteTry]) {
        
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:kMomentsDeleteFail]) {
        
    }
    */
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Supprimer Moments inutiles
    [MomentCoreData deleteMomentsWhileEnteringBackground];
    // Supprimer Users inutiles
    [UserCoreData deleteUsersWhileEnteringBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // --------
    // Mettre à jour TimeLine
    if([self.actualViewController isKindOfClass:[TimeLineViewController class]]) {
        TimeLineViewController *timeline = (TimeLineViewController*)self.actualViewController;
        [timeline reloadData];
    }
    // Mettre à jour Feed
    else if([self.actualViewController isKindOfClass:[FeedViewController class]]) {
        FeedViewController *feed = (FeedViewController*)self.actualViewController;
        [feed reloadData];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // ------------------ Push Notifications -----------------
    // Restore Number Notification Badge Number
    [[PushNotificationManager sharedInstance] setNbNotifcations:[[UIApplication sharedApplication] applicationIconBadgeNumber]];
    
    // ----------------------- Facebook ----------------------
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
    // ------------------ Harpy Alert --------------------
    //    ----> Vérifier version de l'application <----
    // ---------------------------------------------------
    /*
     Perform weekly check for new version of your app
     Useful if user returns to you app from background after extended period of time
     Place in applicationDidBecomeActive:
     
     Also, performs version check on first launch.
     */
    [[Harpy sharedInstance] checkVersionWeekly];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Supprimer Moments inutiles
    [MomentCoreData deleteMomentsWhileEnteringBackground];
    // Supprimer Users inutiles
    [UserCoreData deleteUsersWhileEnteringBackground];
    //[[Config sharedInstance] saveContext];
    
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    // Prvenir d'un changement de frame
    // ------> Utilisé pour détecter l'apparition de la barre d'appel
    // ------> Il faut gérer le changement de Frame pour adapter l'écran en conséquence et éviter les bugs graphiques
   NSDictionary *dict = @{@"oldFrame":[NSValue valueWithCGRect:oldStatusBarFrame],
                           @"newFrame":[NSValue valueWithCGRect:[[UIApplication sharedApplication] statusBarFrame]]
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStatusBarFrameChanged
                                                        object:self
                                                      userInfo:dict];
}

#pragma mark - Push Notification

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    [[PushNotificationManager sharedInstance] receivePushNotification:userInfo updateUI:YES];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager sharedInstance] saveDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager sharedInstance] failToReceiveNotification:error];
}


@end
