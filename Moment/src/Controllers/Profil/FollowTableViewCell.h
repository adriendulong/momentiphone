//
//  FollowTableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAGMedallionView.h"

@interface FollowTableViewCell : UITableViewCell

@property (nonatomic, strong) UserClass *user;
@property (nonatomic) NSInteger index;
@property (nonatomic, weak) UINavigationController *navigationController;

@property (nonatomic, weak) IBOutlet UILabel *nomLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

- (id)initWithUser:(UserClass*)user
         withIndex:(NSInteger)index
   reuseIdentifier:(NSString*)reuseIdentifier
navigationController:(UINavigationController*)navController;

@end
