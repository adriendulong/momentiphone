//
//  FeedMessage.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Feed.h"

@interface FeedMessage : Feed

@property (nonatomic, strong) NSArray *messages;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass *)user
      withMoment:(MomentClass *)moment
     withMessage:(NSArray*)messages
        withDate:(NSDate*)date;

@end
