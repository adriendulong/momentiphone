//
//  FeedMessage.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedMessage.h"

@implementation FeedMessage

@synthesize messages = _messages;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass *)user
      withMoment:(MomentClass *)moment
     withMessage:(NSArray*)messages
        withDate:(NSDate*)date
{
    self = [super initWithId:feedId withUser:user withMoment:moment withType:FeedTypeChat withDate:date];
    if(self) {
        self.messages = messages;
    }
    return self;
}

@end
