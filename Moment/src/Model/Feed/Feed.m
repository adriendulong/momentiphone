//
//  Feed.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Feed.h"
#import "AFMomentAPIClient.h"
#import "Photos.h"
#import "ChatMessage.h"
#import "FeedMessage.h"
#import "FeedPhoto.h"
#import "FeedFollow.h"

@implementation Feed

@synthesize type = _type;
@synthesize user = _user;
@synthesize moment = _moment;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass*)user
      withMoment:(MomentClass*)moment
        withType:(enum FeedType)type
        withDate:(NSDate*)date
{
    self = [super init];
    if(self) {
        self.user = user;
        self.moment = moment;
        _type = type;
        _feedId = feedId;
        self.date = date;
    }
    return self;
}

+ (Feed*)feedWithAttributesFromWeb:(NSDictionary*)attributes
{
    enum FeedType type = [attributes[@"type_action"] intValue];
    NSInteger feedId = [attributes[@"id"] intValue];
    UserClass *user = [[UserClass alloc] initWithAttributesFromWeb:attributes[@"user"]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[attributes[@"time"] doubleValue]];
    
    switch (type) {
        case FeedTypePhoto: {
            MomentClass *moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes[@"moment"]];
            NSArray *photos = [Photos arrayWithArrayFromWeb:attributes[@"photos"]];
            return [[FeedPhoto alloc] initWithId:feedId
                                        withUser:user
                                      withMoment:moment
                                      withPhotos:photos
                                        withDate:date];
            
        } break;
            
        case FeedTypeChat: {
            MomentClass *moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes[@"moment"]];
            ChatMessage *message = [[ChatMessage alloc] initWithAttributesFromWeb:attributes[@"chats"][0]];
            NSInteger nbChats = [attributes[@"nb_chats"] intValue];
            return [[FeedMessage alloc] initWithId:feedId
                                          withUser:user
                                        withMoment:moment
                                       withMessage:message
                                       withNbChats:nbChats
                                          withDate:date];
        } break;
            
        case FeedTypeFollow: {
            
            NSArray *follows = [UserClass arrayOfUsersWithArrayOfAttributesFromWeb:attributes[@"follows"]];
            return [[FeedFollow alloc] initWithId:feedId
                                         withUser:user
                                      withFollows:follows
                                         withDate:date];
            
        } break;
            
        default: {
            MomentClass *moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes[@"moment"]];
            return [[Feed alloc] initWithId:feedId
                                   withUser:user
                                 withMoment:moment
                                   withType:type
                                   withDate:date];
            
        } break;
    }
}

+ (NSArray*)arrayWithArrayFromWeb:(NSArray*)array
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for( NSDictionary* attributes in array ) {
        [newArray addObject:[Feed feedWithAttributesFromWeb:attributes]];
    }
    return newArray;
}

+ (void)getFeedsAtPage:(NSInteger)page withEnded:(void (^) (NSDictionary *feeds))block
{
    NSString *path = (page > 0) ? [NSString stringWithFormat:@"feed/%d", page] : @"feed";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *feeds = [Feed arrayWithArrayFromWeb:JSON[@"feeds"]];        
        NSNumber *nextPage = JSON[@"next_page"] ?: @(page);
    
        if(block) {
            block(@{@"feeds":feeds,
                  @"next_page":nextPage});
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
}

- (BOOL)isEqual:(id)object {
    if([object respondsToSelector:@selector(feedId)]) {
        return (self.feedId == [object feedId]);
    }
    return NO;
}

@end
