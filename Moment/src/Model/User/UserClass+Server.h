//
//  UserClass+Server.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UserClass.h"

@interface UserClass (Server)

// Register
+ (void)registerUserWithAttributes:(NSDictionary*)attributes withEnded:(void (^)(NSInteger status))block;

// User Informations
+ (void)getUserFromServerWithId:(NSInteger)userId withEnded:(void (^) (UserClass *user))block;
+ (void)updateCurrentUserInformationsOnServerWithAttributes:(NSDictionary *)modifications
                                                  withEnded:(void (^) (BOOL success))block;

// Login
+ (void)getLoggedUserFromServerWithEnded:( void (^) (UserClass *user) )block waitUntilFinished:(BOOL)waitUntilFinished;
+ (void)getLoggedUserFromServerWithEnded:( void (^) (UserClass *user) )block;
+ (void)loginUserWithUsername:(NSString *)username withPassword:(NSString *)password withEnded:(void (^)(NSInteger status))block;

// Lost Password
+ (void)requestNewPasswordAtEmail:(NSString*)email withEnded:(void (^) (BOOL success))block;

// Invites
+ (void)inviteNewGuest:(NSArray*)users toMoment:(MomentClass*)moment withEnded:( void (^) (BOOL success) )block;
+ (void)getInvitedUsersToMoment:(MomentClass*)moment
         withAdminEncapsulation:(BOOL)adminEncapsulation
                      withEnded:( void (^) (NSDictionary* invites) )block;
+ (void)getInvitedUsersToMoment:(MomentClass*)moment withEnded:( void (^) (NSDictionary* invites) )block;
+ (void)getFavorisUsersWithEnded:( void (^) (NSArray* favoris) )block;

// Users on moment
+ (void)getUsersWhoAreOnMoment:(NSArray *)users withEnded:(void (^) (NSArray *usersOnMoment))block;

// Follows/Followers
- (void)getFollowsWithEnded:(void (^) (NSArray *follows))block;
- (void)getFollowersWithEnded:(void (^) (NSArray *followers))block;
- (void)toggleFollowWithEnded:(void (^) (BOOL success))block;

// Photos
- (void)getPhotosWithEnded:(void (^) (NSArray *photos))block;

// Recherche
+ (void)search:(NSString*)query
     withEnded:(void (^) (NSArray *users, NSArray *moments, NSInteger nbPrivateMoments))block;

@end
