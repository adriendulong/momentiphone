//
//  FeedChatCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedMessage.h"

@interface FeedChatCell : UITableViewCell

@property (nonatomic, strong) FeedMessage *feed;
@property (nonatomic, weak) FeedViewController *delegate;

@property (nonatomic, weak) IBOutlet CustomUIImageView *profileView;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UILabel *nbMessagesLabel;
@property (nonatomic, weak) IBOutlet UILabel *momentLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconeView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

- (id)initWithFeed:(FeedMessage*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate;

@end
