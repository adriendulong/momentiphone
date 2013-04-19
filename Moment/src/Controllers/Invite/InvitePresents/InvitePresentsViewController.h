//
//  InvitePresentsViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCoreData+Model.h"

#import "InvitePresentsTableViewController.h"
#import "CustomSegmentedControl.h"

enum InvitePresentsOnglet {
    InvitePresentsOngletComing = 1,
    InvitePresentsOngletUnknown = 2,
    InvitePresentsOngletMaybe = 0
};

@interface InvitePresentsViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) UserClass *owner;
@property (nonatomic, weak) MomentClass *moment;
@property (nonatomic, strong) NSDictionary *invites;

@property (nonatomic) enum InvitePresentsOnglet selectedOnglet;
@property (nonatomic, strong)InvitePresentsTableViewController *comingTableViewController;
@property (nonatomic, strong)InvitePresentsTableViewController *unknownTableViewController;
@property (nonatomic, strong)InvitePresentsTableViewController *maybeTableViewController;

@property (nonatomic, strong) CustomSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

- (id)initWithOwner:(UserClass*)owner withMoment:(MomentClass*)moment;

@end
