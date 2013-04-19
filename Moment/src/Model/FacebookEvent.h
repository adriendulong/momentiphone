//
//  FacebookEvent.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCoreData.h"
#import "UserClass.h"

@interface FacebookEvent : NSObject

@property (strong, nonatomic, readonly) NSString *eventId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *descriptionString;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSString *location;
@property (nonatomic) BOOL isPrivate;
@property (strong, nonatomic) NSDictionary *venue;
@property (nonatomic) enum UserState rsvp_status;
@property (strong, nonatomic) UIImage *picture;
@property (strong, nonatomic) NSString *pictureString;
@property (strong, nonatomic) NSDictionary *ownerAttributes;
@property (strong, nonatomic) UserClass *owner;
@property (nonatomic) BOOL isAlreadyOnMoment;

- (id)initWithAttributes:(NSDictionary *)attributes;

// Init With Facebook
- (void)setupOwner:(NSString*)ownerId withEnded:(void (^) (FacebookEvent *event))block;
+ (void)arrayWithArrayOfEvents:(NSArray*)eventsArray
            withArrayOfOwnerId:(NSArray*)ownerIdsArray
                     withEnded:(void (^) (NSArray *events))block;

@end
