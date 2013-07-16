//
//  FeedMessage.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedMessage.h"

@implementation FeedMessage

@synthesize message = _message;
@synthesize nbChats = _nbChats;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass *)user
      withMoment:(MomentClass *)moment
     withMessage:(ChatMessage*)message
     withNbChats:(NSInteger)nbChats
        withDate:(NSDate*)date
{
    self = [super initWithId:feedId withUser:user withMoment:moment withType:FeedTypeChat withDate:date];
    if(self) {
        self.message = message;
        self.nbChats = nbChats;
    }
    return self;
}

- (BOOL)shouldUseLargeView {
    return ( (self.nbChats > 1) || (self.message.message.length > 60) );
}

@end
