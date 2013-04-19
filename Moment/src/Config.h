//
//  Config.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 01/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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

@interface Config : NSObject

#pragma mark - Singleton
+ (Config*)sharedInstance;

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

#pragma mark - Regex Validation
- (BOOL)isNumeric:(NSString*)s;
- (NSString*)formatedPhoneNumber:(NSString*)phoneNumber;
- (BOOL)isValidEmail:(NSString*)email;
- (BOOL)isValidPhoneNumber:(NSString*)phoneNumber;

#pragma mark - Cover Image
- (void)saveNewCoverImage:(UIImage *)image;
- (UIImage*)coverImage;
- (void)deleteCoverImage;

@end
