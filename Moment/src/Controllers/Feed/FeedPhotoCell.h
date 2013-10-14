//
//  FeedBigCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedPhoto.h"
#import "FeedViewController.h"

@interface FeedPhotoCell : UITableViewCell

@property (nonatomic, strong) FeedPhoto *feed;
@property (nonatomic, weak) FeedViewController *delegate;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet CustomUIImageView *profileView;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UILabel *info2Label;
@property (nonatomic, weak) IBOutlet UILabel *momentLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconeView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

- (id)initWithFeed:(FeedPhoto*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate
             index:(NSInteger)index;

@end
