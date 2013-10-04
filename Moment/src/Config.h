//
//  Config.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 01/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Activer Hashtag dans l'application
//#define HASHTAG_ENABLE

// NSNotificationCenter
#define kNotificationNewChat @"NotificationNewChat"
#define kNotificationNewPhoto @"NotificationNewPhoto"
#define kNotificationNewInvitation @"NotificationNewInvitation"
#define kNotificationModification @"NotificationModificationMoment"
#define kNotificationChangeBadgeNumber @"NotificationChangeBadgeNumber"
#define kNotificationTimeLineNeedsUpdate @"NotificationTimeLineNeedsUpdate"
#define kNotificationCurrentUserNeedsUpdate @"NotificationCurrentUserNeedsUpdate"
#define kNotificationCurrentUserDidUpdate @"NotificationCurrentUserDidUpdate"
#define kNotificationChangeCover @"ChangeCoverNotification"
#define kNotificationStatusBarFrameChanged @"NotificationStatusBarFrameChanged"

// Google Account API Key
#define kGoogleAPIKey @"AIzaSyBOpJuAT7dEsXCxPbd_6m89wJPUbEIEM80"//@"AIzaSyBLhi9BP6Lmcr8NM2UeK8t9PYwOzJOnEBU"

// Links
#define kAppMomentCGU @"http://appmoment.fr/cgu"
#define kParameterFacebookPageID @"277911125648059"
#define kParameterFacebookPageName @"appmoment"
#define kParameterTwitterPageName @"appmoment"
#define kParameterContactMail @"hello@appmoment.fr"

// Clé UserDefaults
// -> Vérification que la suppression du coredata c'est bien passée
#define kMomentsDeleteTry @"MomentsDeleteTry"
#define kMomentsDeleteFail @"MomentsDeleteFail"
#define kUsersDeleteTry @"MomentsDeleteTry"
#define kUsersDeleteFail @"MomentsDeleteFail"

@interface Config : NSObject

#pragma mark - Singleton
+ (Config*)sharedInstance;

#pragma mark - Switch Dev/Prod
@property (strong, nonatomic) NSString *kAFBaseURLString;
@property (strong, nonatomic) NSString *FBSessionStateChangedNotification;
@property (strong, nonatomic) NSString *TestFlightAppToken;
@property (strong, nonatomic) NSString *appFBNamespace;

#pragma mark - CoreData
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

#pragma mark - Font
- (UIFont*)defaultFontWithSize:(CGFloat)size;
- (void)updateTTTAttributedString:(NSMutableAttributedString*)mutableString withFontSize:(CGFloat)size onRange:(NSRange)range;
- (void)updateTTTAttributedString:(NSMutableAttributedString*)mutableString withColor:(UIColor*)color onRange:(NSRange)range;

#pragma mark - Colors
- (UIColor*)orangeColor;
- (UIColor*)textColor;

#pragma mark - Image Cropping
- (UIImage*)scaleAndCropImage:(UIImage*)sourceImage forSize:(CGSize)targetSize;
- (UIImage*)imageWithMaxSize:(UIImage*)image maxSize:(CGFloat)maxImageSize;
- (float)getScaleFromImageMetadata:(NSDictionary *)metadata maxSize:(CGFloat)maxImageSize;

#pragma mark - Create UIImage programmatically
- (UIImage *)imageFromText:(NSString *)text withColor:(UIColor *)color andFont:(UIFont *)font;

#pragma mark - Upload Photos
- (void)getUIImageFromAssetURL:(NSURL *)assetUrl toPath:(NSString *)path withEnded:(void (^) (NSString *fullPathToPhoto) )block;

#pragma mark - Dates manipulation
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

#pragma mark - Create NSString directly with font
- (NSString *)createStylizedStringFromString:(NSString *)string withFont:(UIFont *)font andColor:(UIColor *)color fromRect:(CGRect)rect;
- (UIFont *)boldFontFromFont:(UIFont *)font;

#pragma mark - Regex Validation
- (BOOL)isNumeric:(NSString*)s;
- (NSString*)formatedPhoneNumber:(NSString*)phoneNumber;
- (BOOL)isValidEmail:(NSString*)email;
- (BOOL)isValidPhoneNumber:(NSString*)phoneNumber;
- (BOOL)isMobilePhoneNumber:(NSString*)phoneNumber forceValidation:(BOOL)force;

#pragma mark - Cover Image
- (void)saveNewCoverImage:(UIImage *)image;
- (UIImage*)coverImage;
- (void)deleteCoverImage;

/*
#pragma mark - Texte Formatage
- (NSString*)twitterShareTextForMoment:(MomentClass*)moment nbMaxCaracters:(NSInteger)nbMaxCarac;
*/
 
#pragma mark - FeedBack
- (void)feedBackMailComposerWithDelegate:(id<MFMailComposeViewControllerDelegate>)delegate
                                    root:(UIViewController*)rootViewController;
- (void)feedBackRatingMailComposerWithDelegate:(id<MFMailComposeViewControllerDelegate>)delegate
                                          root:(UIViewController*)rootViewController;

#pragma mark - Switch DEV or PROD
- (void)setDeveloppementVersion:(BOOL)activated;

@end
