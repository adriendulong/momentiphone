//
//  FeedFollow.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedFollow.h"

@implementation FeedFollow

@synthesize follows = _follows;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass*)user
     withFollows:(NSArray *)follows
        withDate:(NSDate*)date
{
    self = [super initWithId:feedId withUser:user withMoment:nil withType:FeedTypeFollow withDate:date];
    if(self) {
        self.follows = follows;
    }
    return self;
}

@end
