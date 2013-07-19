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
#import "Photos.h"
#import "UserCoreData+Model.h"
#import "FacebookTokenCachingStrategy.h"

enum FacebookPermissionType {
    FacebookPermissionReadType = 1,
    FacebookPermissionPublishType = 2
    };

// Facebook connecté
#define kFacebookConnected @"FacebookConnected"

@interface FacebookManager : NSObject

@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *defaultReadPermissions, *defaultPublishPermissions;
@property (nonatomic, strong) FacebookTokenCachingStrategy *tokenCachingStrategy;

// Singleton
+ (FacebookManager*)sharedInstance;

// Facebook Connected : Compte facebook associé
- (BOOL)facebookIsConnected;

// Login / Logout
- (void)loginReadPermissionsWithEnded:( void (^) (BOOL success) )block;
- (void)loginPublishPermissionsWithEnded:( void (^) (BOOL success) )block;
- (void)logout;
- (BOOL)isLogged;

// Permissions
- (void)askForPermissions:(NSArray*)permisions
                     type:(enum FacebookPermissionType)type
                withEnded:( void (^) (BOOL success) )block;

// FB ID
- (void)getCurrentUserInformationsWithEnded:(void (^) (UserClass* user))block;
- (void)getCurrentUserFacebookIdWithEnded:(void (^) (NSString *fbId))block;
- (void)updateCurrentUserFacebookIdOnServer:(void (^) (BOOL success))block;
- (void)getUserInformationsWithId:(NSString*)facebookId withEnded:(void (^) (UserClass* user))block;

// Friends
- (void)getFriendsWithEnded:(void (^) (NSArray* friends) )block;
- (void)getFriendProfilePrictureURL:(NSString*)facebookId withEnded:(void (^) (NSString* url) )block;

// Events
- (void)getEventsWithEnded:(void (^) (NSArray* events) )block;

// RSVP
- (void)updateRSVP:(enum UserState)rsvp
            moment:(MomentClass*)moment
         withEnded:(void (^) (BOOL success))block;
- (void)getRSVP:(MomentClass*)moment withEnded:(void (^) (enum UserState rsvp))block;
- (void)getRSVP:(MomentClass*)moment fromUser:(UserClass *)user withEnded:(void (^) (enum UserState rsvp))block;
- (void)createUsersFromFacebookInvited:(NSArray *)invited withEnded:( void (^) (NSArray *users) )block;
- (void)getCoverEventWithID:(NSString *)facebookId withEnded:( void (^) (NSString *pic_url) )block;

// Publish
- (void)getPublishPermissions;
- (void)postMessageOnEventWall:(MomentClass*)moment
                       message:(NSString*)message
                     withEnded:(void (^) (BOOL success))block;
- (void)postMessageOnEventWall:(MomentClass *)moment
                         photo:(Photos*)photo
                     withEnded:(void (^)(BOOL success))block;
- (void)postMessageOnEventWall:(MomentClass *)moment
                          chat:(ChatMessage*)chat
                     withEnded:(void (^)(BOOL success))block;

// --
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error;
+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;

@end
