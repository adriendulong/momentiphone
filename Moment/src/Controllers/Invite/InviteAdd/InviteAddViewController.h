//
//  InviteAddViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InviteAddViewControllerDelegate <NSObject>

@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
- (void)addNewSelectedFriend:(UserClass*)friend notif:(BOOL)notif;
- (void)removeSelectedFriend:(UserClass*)friend;
- (BOOL)selectedFriendsEmpty;

@end

#import "UserCoreData+Model.h"
#import "CustomLabel.h"
#import "InfoMomentSeparateurView.h"
#import "InviteAddTableViewController.h"
#import "TTTAttributedLabel.h"
#import <MessageUI/MessageUI.h>
#import "CMPopTipView.h"

@class InviteAddTableViewController;
@interface InviteAddViewController : UIViewController <UITextFieldDelegate, InviteAddViewControllerDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate, CMPopTipViewDelegate>

@property (nonatomic, strong) UserClass *owner;
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, strong) NSMutableArray *selectedFriends;
@property (nonatomic, strong) NSMutableArray *notifSelectedFriends;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSInteger selectedOnglet;

@property (nonatomic, weak) IBOutlet UITextField *searchTextField;

@property (nonatomic, weak) IBOutlet UIView *navBarRigthButtonsView;
@property (nonatomic, weak) IBOutlet UIButton *contactButton;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *favorisButton;

@property (nonatomic, weak) IBOutlet UIButton *bandeauButton;

@property (nonatomic, weak) InviteAddTableViewController *actualTableViewController;
@property (nonatomic, strong) InviteAddTableViewController *contactTableViewController;
@property (nonatomic, strong) InviteAddTableViewController *facebookTableViewController;
@property (nonatomic, strong) InviteAddTableViewController *favorisTableViewController;
@property (nonatomic) BOOL contactLoaded, facebookLoaded, favorisLoaded;

@property (nonatomic, strong) CMPopTipView *roundRectButtonPopTipView;

@property (nonatomic) BOOL poptipFacebook;

// Constant Header
@property (nonatomic, weak) IBOutlet CustomLabel *validerLabel;
@property (nonatomic, weak) IBOutlet UILabel *nbInvitesLabel;
@property (nonatomic, weak) IBOutlet UILabel *phraseLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttValiderLabel;

- (id)initWithOwner:(UserClass*)owner withMoment:(MomentClass*)moment;
- (IBAction)clicValider;

- (IBAction)clicNavigationBarButtonFavoris;
- (IBAction)clicNavigationBarButtonFacebook;
- (IBAction)clicNavigationBarButtonContact;

@end
