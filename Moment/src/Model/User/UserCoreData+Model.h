//
//  UUserCoreData+Model.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 04/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "UserCoreData.h"
#import "UserClass.h"

enum UserState {
    UserStateCurrent = -5,
    UserStateOwner = 0,
    UserStateAdmin = 1,
    UserStateValid = 2,
    UserStateRefused = 3,
    UserStateUnknown = 4,
    UserStateWaiting = 5,
    UserStateNoInvited = 6
};

enum UserPrivacy {
    UserPrivacyClosed = 0,
    UserPrivacyPrivate = 1,
    UserPrivacyOpen = 2
    };

#define USERS_NO_LIMIT -1

@interface UserCoreData (Model)

// Init
- (void)setupWithUser:(UserClass*)user;

// Persist
+ (UserCoreData*)insertWithMemoryReleaseNewUser:(UserClass*)user;
+ (UserClass*)newUserWithAttributes:(NSDictionary*)attributes;
//+ (void)updateUser:(UserClass*)user;

// Count
+ (NSInteger)count;
+ (NSArray*)getUsersAsCoreDataWithLimit:(NSInteger)limit;

// Local Gestion
- (UserClass*)localCopy;
+ (NSArray*)localCopyOfArray:(NSArray*)stored;

// Request
+ (UserCoreData*)requestUserAsCoreDataWithAttributes:(NSDictionary*)attributes;
+ (UserClass*)requestUserWithAttributes:(NSDictionary*)attributes;
+ (UserCoreData*)requestUserAsCoreDataWithUser:(UserClass *)user;
+ (NSArray*)getUsersAsCoreData;
+ (NSArray*)getUsers;

// Getters & Setters
- (UIImage*)uimage;
- (void)setDataImageWithUIImage:(UIImage *)image;

// Current User
+ (void)currentUserNeedsUpdate;
+ (UserCoreData*)getCurrentUserAsCoreData:(BOOL)localOnly;
+ (UserClass*)getCurrentUser:(BOOL)localOnly;
+ (UserClass*)getCurrentUser;
+ (void)updateCurrentUserWithAttributes:(NSDictionary*)attributes;

// Release
+ (void)releaseUsersAfterIndex:(NSInteger)max;
+ (void)resetUsersLocal;

// Util
- (NSString*)formatedUsername;
- (NSString*)formatedUsernameWithStyle:(enum UsernameStyle)style;

@end
