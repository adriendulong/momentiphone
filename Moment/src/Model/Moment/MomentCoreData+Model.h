//
//  MomentCoreData+Model.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 04/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "MomentCoreData.h"
#import "UserCoreData+Model.h"
#import "FacebookEvent.h"

#define MOMENTS_NO_LIMIT -1

enum MomentPrivacy {
    MomentPrivacyPrivate = 0,
    MomentPrivacyOpen = 1,
    MomentPrivacyPublic = 2
    };

@interface MomentCoreData (Model)

// Setup
- (void)setupWithMoment:(MomentClass*)moment;

// Persist
+ (MomentCoreData*)insertWithMemoryReleaseNewMoment:(MomentClass*)moment;
+ (MomentClass*)newMomentWithAttributesFromLocal:(NSDictionary*)attributes;
+ (MomentClass*)newMomentWithAttributesFromWeb:(NSDictionary*)attributes;
+ (MomentClass*)newMomentWithFacebookEvent:(FacebookEvent*)event;

// Local Gestion
- (MomentClass*)localCopy;
+ (NSArray*)localCopyOfArray:(NSArray*)stored;

// Count
+ (NSInteger)count;
+ (NSArray*)getMomentsAsCoreDataWithLimit:(NSInteger)limit;

// Request
+ (NSArray*)getMomentsAsCoreData;
+ (NSArray*)getMoments;
+ (MomentCoreData*)requestMomentAsCoreDataWithAttributes:(NSDictionary*)attributes;
+ (MomentClass*)requestMomentWithAttributes:(NSDictionary*)attributes;
+ (MomentCoreData*)requestMomentAsCoreDataWithFacebookEvent:(FacebookEvent*)event;
+ (MomentClass*)requestMomentWithFacebookEvent:(FacebookEvent*)event;
+ (MomentCoreData*)requestMomentAsCoreDataWithMoment:(MomentClass *)moment;

// Update
+ (void)updateMoment:(MomentClass*)moment; // Met à jour la base de donnée avec les infos du moment
+ (void)updateMomentsWithArray:(NSArray*)array;

// Release
+ (void)releaseMomentsAfterIndex:(NSInteger)max;
+ (void)resetMomentsLocal;
+ (void)deleteMoment:(MomentClass*)moment;

// Setters & Getters
- (UIImage*)uimage;
- (void)setDataImageWithUIImage:(UIImage *)image;

@end
