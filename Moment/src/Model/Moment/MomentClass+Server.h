//
//  MomentClass+Server.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "MomentClass.h"
#import "UserCoreData+Model.h"
#import "Photos.h"
#import "AFJSONRequestOperation.h"

@interface MomentClass (Server)

// Create
+ (void)createMomentWithAttributes:(NSDictionary*)attributes withEnded:( void (^) (MomentClass *moment) )block;
- (void)createMomentFromLocalToServerWithEnded:( void (^) (MomentClass *moment) )block;
+ (void)createMultipleMomentsWithAttributes:(NSArray*)array
                             withTransition:( void (^) (MomentClass *moment) )transitionBlock
                                  withEnded:(void (^) (void))endBlock;
+ (void)createMultipleMomentsFromLocalToServerWithMoments:(NSArray*)array
                                           withTransition:( void (^) (MomentClass *moment) )transitionBlock
                                                withEnded:(void (^) (void))endBlock;

// Get Moments
+ (void)getMomentsForUser:(UserClass*)user withEnded:(void (^) (NSArray* moments))block;
+ (void)getInfosMomentWithId:(NSInteger)momentId
                   withEnded:(void (^) (NSDictionary* attributes) )block
           waitUntilFinished:(BOOL)waitUntilFinished;
+ (void)getInfosMomentWithId:(NSInteger)momentId withEnded:(void (^) (NSDictionary* attributes) )block;
+ (void)getMomentsServerWithEnded:(void (^)(BOOL success))block waitUntilFinished:(BOOL)waitUntilFinished;
+ (void)getMomentsServerWithEnded:(void (^)(BOOL success))block;
+ (void)getMomentsServerAfterDateOfMoment:(MomentClass*)moment withEnded:(void (^) (NSArray* moments))block;

// Facebook Events
+ (void)identifyFacebookEventsOnMoment:(NSArray*)events withEnded:(void (^) (NSDictionary* results))block;
+ (void)importFacebookEventsWithEnded:(void (^) (NSArray *events, NSArray* moments))block;

// Update
- (void)updateCurrentUserState:(enum UserState)state withEnded:(void (^) (BOOL success) )block;
- (void)updateMomentFromServerWithEnded:(void (^) (BOOL success) )block
                      waitUntilFinished:(BOOL)waitUntilFinished;
- (void)updateMomentFromServerWithEnded:(void (^) (BOOL success) )block;
- (void)updateUserWithIdAsAdmin:(NSInteger)userId withEnded:(void (^) (BOOL success) )block;
- (void)updateMomentFromLocalToServerWithEnded:(void (^) (BOOL success))block;
- (void)togglePrivacyWithEnded:(void (^) (BOOL success))block;

// Photos
- (void)getPhotosWithEnded:( void (^) (NSArray* photos) )block;

- (void)sendPhoto:(UIImage*)photo
        withStart:(void (^) (UIImage *photo))startBlock
  withProgression:(void (^) (CGFloat progress))progressBlock
        withEnded:(void (^) (Photos *photo))endBlock;

- (void)sendArrayOfPhotos:(NSArray*)array
                withStart:(void (^) (UIImage *photo))startBlock
          withProgression:(void (^) (CGFloat progress))progressBlock
           withTransition:(void (^) (Photos *photo))transitionBlock
                withEnded:(void (^) (void))endBlock;

// Suppression
- (void)deleteWithEnded:(void (^) (BOOL success))block;

@end
