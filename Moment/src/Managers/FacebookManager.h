//
//  FacebookManager.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFHTTPClient.h"

enum FacebookPermissionType {
    FacebookPermissionReadType = 1,
    FacebookPermissionPublishType = 2
    };

@interface FacebookManager : NSObject

@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *defaultReadPermissions, *defaultPublishPermissions;

// Singleton
+ (FacebookManager*)sharedInstance;

// Login / Logout
- (void)loginReadPermissionsWithEnded:( void (^) (BOOL success) )block;
- (void)loginPublishPermissionsWithEnded:( void (^) (BOOL success) )block;
- (void)logout;
- (BOOL)isLogged;

// Permissions
- (void)askForPermissions:(NSArray*)permisions type:(enum FacebookPermissionType)type withEnded:( void (^) (BOOL success) )block;

// FB ID
- (void)getCurrentUserInformationsWithEnded:(void (^) (UserClass* user))block;
- (void)getCurrentUserFacebookIdWithEnded:(void (^) (NSString *fbId))block;
- (void)getUserInformationsWithId:(NSString*)facebookId withEnded:(void (^) (UserClass* user))block;

// Friends
- (void)getFriendsWithEnded:(void (^) (NSArray* friends) )block;
- (void)getFriendProfilePrictureURL:(NSString*)facebookId withEnded:(void (^) (NSString* url) )block;

// Events
- (void)getEventsWithEnded:(void (^) (NSArray* events) )block;

// Publish
- (void)getPublishPermissions;

// 
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error;
+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;

@end
