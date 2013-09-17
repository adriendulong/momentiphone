//
//  VoletViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDMenuController.h"
#import "TTTAttributedLabel.h"
#import "CustomSearchVolletTextField.h"

@class VoletSearchViewController;

@interface VoletViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DDMenuControllerDelegate>

@property (nonatomic, weak) DDMenuController *delegate;
@property (nonatomic, weak) RootTimeLineViewController *rootTimeLine;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableArray *invitations;
@property (weak, nonatomic) IBOutlet UIButton *mesActualites;
@property (weak, nonatomic) IBOutlet UIButton *mesMoments;
@property (weak, nonatomic) IBOutlet UIButton *parametresButton;
@property (weak, nonatomic) IBOutlet UIButton *eventMissingButton;
@property (weak, nonatomic) IBOutlet UIButton *revivreMomentButton;

@property (weak, nonatomic) IBOutlet UIButton *nomUserButton;
@property (weak, nonatomic) IBOutlet UIView *sectionView;
@property (weak, nonatomic) IBOutlet CustomLabel *sectionTitleLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttSectionTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (weak, nonatomic) IBOutlet UIButton *invitationsButton;
@property (weak, nonatomic) IBOutlet UIImageView *segementShadow;
// Nb Notifications
@property (strong, nonatomic) IBOutlet UIView *nbNotificationsView;
@property (weak, nonatomic) IBOutlet UILabel *nbNotificationsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nbNotificationsBackground;

// Nb Invitations
@property (strong, nonatomic) IBOutlet UIView *nbInvitationsView;
@property (weak, nonatomic) IBOutlet UILabel *nbInvitationsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nbInvitationsBackground;

// Search
@property (weak, nonatomic) IBOutlet CustomSearchVolletTextField *searchTextField;
@property (nonatomic, strong) VoletSearchViewController *searchViewController;
@property (nonatomic) BOOL *alreadyPushSearchView;

// ----
+ (VoletViewController*)volet;

- (id)initWithDDMenuDelegate:(DDMenuController*)delegate withRootTimeLine:(RootTimeLineViewController*)rootTimeLine;

//- (IBAction)clicLogout;
- (IBAction)clicInvitations;
- (IBAction)clicNotifications;
- (IBAction)clicUser;
- (IBAction)clicParametres;
- (IBAction)clicEventMissing;
- (IBAction)clicRevivreMoment;

// Load
- (void)loadNotifications;
- (void)loadInvitations;

// Change TimeLine / Feed
//- (void)selectActualitesButton;
- (void)selectMesMomentsButton;
- (IBAction)clicChangeTimeLine:(UIButton*)sender;

// VoletViewCotroller Delegate
- (void)showUserProfileFromVoletSearch:(UserClass*)user;
- (void)showInfoMomentFromSearch:(MomentClass*)moment;

@end

#import "VoletSearchViewController.h"



