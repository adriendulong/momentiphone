//
//  FeedPhoto.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedPhoto.h"

@implementation FeedPhoto

@synthesize photos = _photos;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass *)user
      withMoment:(MomentClass *)moment
      withPhotos:(NSArray*)photos
        withDate:(NSDate*)date
{
    self = [super initWithId:feedId withUser:user withMoment:moment withType:FeedTypePhoto withDate:date];
    if(self) {
        self.photos = photos;
    }
    return self;
}

@end
