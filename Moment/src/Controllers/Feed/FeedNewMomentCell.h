//
//  FeedNewMomentCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 01/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface FeedNewMomentCell : UITableViewCell

@property (nonatomic, strong) Feed *feed;
@property (nonatomic, weak) FeedViewController *delegate;

@property (nonatomic, weak) IBOutlet CustomUIImageView *profileView;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *backgroundTitleView;
@property (nonatomic, weak) IBOutlet CustomUIImageView *coverView;

- (id)initWithFeed:(Feed*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate;


@end
