//
//  Feed.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

enum FeedType {
    FeedTypePhoto = 0,
    FeedTypeChat = 1,
    FeedTypeNewEvent = 2,
    FeedTypeInvited= 3,
    FeedTypeGoing = 4,
    FeedTypeFollow = 5
    };

@interface Feed : NSObject

@property (nonatomic, readonly) NSInteger feedId;
@property (nonatomic, readonly) enum FeedType type;
@property (nonatomic, strong) UserClass *user;
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, strong) NSDate *date;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass*)user
      withMoment:(MomentClass*)moment
        withType:(enum FeedType)type
        withDate:(NSDate*)date;

+ (Feed*)feedWithAttributesFromWeb:(NSDictionary*)attributes;
+ (NSArray*)arrayWithArrayFromWeb:(NSArray*)array;

+ (void)getFeedsAtPage:(NSInteger)page withEnded:(void (^) (NSDictionary *feeds))block;

@end
