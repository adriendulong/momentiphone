//
//  FollowTableViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

enum FollowTableViewStyle {
    FollowTableViewStyleFollow = 0,
    FollowTableViewStyleFollower = 1
    };

@interface FollowTableViewController : UITableViewController

@property (nonatomic, strong) UserClass *owner;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic) enum FollowTableViewStyle style;
@property (nonatomic, weak) UINavigationController *navController;

- (id)initWithOwner:(UserClass*)owner
         withFrame:(CGRect)frame
         withStyle:(enum FollowTableViewStyle)style
navigationController:(UINavigationController*)navController;

- (void)loadUsersList;
- (void)loadUsersListWithEnded:(void (^) (void))block;

@end
