//
//  FeedMessage.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Feed.h"

@interface FeedMessage : Feed

@property (nonatomic, strong) ChatMessage *message;
@property (nonatomic) NSInteger nbChats;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass *)user
      withMoment:(MomentClass *)moment
     withMessage:(ChatMessage*)message
     withNbChats:(NSInteger)nbChats
        withDate:(NSDate*)date;

- (BOOL)shouldUseLargeView;

@end
