//
//  InviteAddTableViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCoreData+Model.h"
#import "InviteAddViewController.h"

enum InviteAddTableViewControllerStyle {
    InviteAddTableViewControllerContactStyle = 0,
    InviteAddTableViewControllerFacebookStyle = 1,
    InviteAddTableViewControllerFavorisStyle = 2
    };

@interface InviteAddTableViewController : UITableViewController

@property (nonatomic, weak) UserClass *owner;
@property (nonatomic, weak) UIViewController <InviteAddViewControllerDelegate> * delegate;

@property (nonatomic) enum InviteAddTableViewControllerStyle inviteTableViewStyle;
@property (nonatomic, strong) NSString *notificationName;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *visibleFriends;

- (id)initWithOwner:(UserClass*)owner withDelegate:(UIViewController <InviteAddViewControllerDelegate> *)delegate withStyle:(enum InviteAddTableViewControllerStyle)style;
- (void)loadFriendsList;

- (void)updateVisibleFriends:(NSArray*)updatedArray;

@end
