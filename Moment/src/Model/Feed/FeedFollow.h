//
//  FeedFollow.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Feed.h"

@interface FeedFollow : Feed

@property (nonatomic, strong) NSArray *follows;

- (id)initWithId:(NSInteger)feedId
        withUser:(UserClass*)user
     withFollows:(NSArray *)follows
        withDate:(NSDate*)date;

@end
