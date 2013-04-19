//
//  FeedFollowCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedFollow.h"

@interface FeedFollowCell : UITableViewCell

@property (nonatomic, strong) FeedFollow *feed;
@property (nonatomic, weak) FeedViewController *delegate;

@property (nonatomic, weak) IBOutlet CustomUIImageView *profileView1, *profileView2;
@property (nonatomic, weak) IBOutlet UILabel *userLabel1, *userLabel2;
@property (nonatomic, weak) IBOutlet UILabel *nowFollowLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconeView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

- (id)initWithFeed:(FeedFollow*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate;

@end
