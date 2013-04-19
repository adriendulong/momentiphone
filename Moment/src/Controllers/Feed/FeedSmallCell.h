//
//  FeedSmallCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "FeedViewController.h"

@interface FeedSmallCell : UITableViewCell

@property (nonatomic, strong) Feed *feed;
@property (nonatomic, weak) FeedViewController *delegate;

@property (nonatomic, weak) IBOutlet CustomUIImageView *profileView;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UILabel *info2Label;
@property (nonatomic, weak) IBOutlet UILabel *momentLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconeView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UIView *backgroundLocationView;
@property (nonatomic, weak) IBOutlet CustomUIImageView *coverView;

- (id)initWithFeed:(Feed*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate;

@end
