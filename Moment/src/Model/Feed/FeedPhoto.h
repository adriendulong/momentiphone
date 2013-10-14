//
//  FeedPhoto.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Feed.h"

@interface FeedPhoto : Feed

@property (nonatomic, strong) NSArray *photos;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass *)user
      withMoment:(MomentClass *)moment
      withPhotos:(NSArray*)photos
        withDate:(NSDate*)date;

@end
