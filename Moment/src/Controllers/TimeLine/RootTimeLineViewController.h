//
//  RootTimeLineViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDMenuController.h"
#import "TimeLineViewController.h"
#import "FeedViewController.h"

@interface RootTimeLineViewController : UIViewController

@property (nonatomic, strong) UserClass *user;

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, weak) DDMenuController *ddMenuViewController;
@property (nonatomic) CGSize size;
@property (nonatomic) enum TimeLineStyle timeLineStyle;

@property (nonatomic, strong) FeedViewController *publicFeedList;
@property (nonatomic, strong) TimeLineViewController *privateTimeLine;
@property (nonatomic) BOOL isShowingPrivateTimeLine;

@property (weak, nonatomic) IBOutlet UIButton *changeTimeLineButton;

- (id)initWithUser:(UserClass*)user
          withSize:(CGSize)size withStyle:(enum TimeLineStyle)style
withNavigationController:(UINavigationController*)navController
shouldReloadMoments:(BOOL)reloadMoments
  shouldLoadEventsFromFacebook:(BOOL)loadEvents;

- (IBAction)clicChangeTimeLine;
- (void)showAddEvent;
- (TimeLineViewController*)timeLineForMoment:(MomentClass*)moment;
- (void)updateVolet;

@end
