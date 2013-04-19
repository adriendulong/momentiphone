//
//  FeedViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootOngletsViewController.h"

#define BIGFEED_SCROLL_OFFSET 7
#define BIGFEED_SCROLL_WIDTH 294

@interface FeedViewController : UITableViewController <UIScrollViewDelegate>

@property (nonatomic, weak) RootTimeLineViewController *rootViewController;
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, strong) RootOngletsViewController *ongletsViewController;

- (id)initWithRootViewController:(RootTimeLineViewController*)rootViewController;

- (void)reloadData;
- (void)showProfile:(UserClass*)user;
- (NSString*)timePastSinceDate:(NSDate*)date;

// Redirection Onglets
- (void)showInfoMomentView:(MomentClass*)moment;
- (void)showPhotoView:(MomentClass*)moment;
- (void)showTchatView:(MomentClass*)moment;

// Redirection Profonde
- (void)showInviteViewControllerWithMoment:(MomentClass*)moment;

@end
