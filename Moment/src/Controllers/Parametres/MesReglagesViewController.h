//
//  MesReglagesViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GAITrackedViewController.h"

@interface MesReglagesViewController : GAITrackedViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

// --- Properties ---

@property (weak, nonatomic) DDMenuController *delegate;
@property (strong, nonatomic) IBOutlet UIScrollView *contentView;

// Labels
@property (weak, nonatomic) IBOutlet UILabel *followUsLabel;
@property (weak, nonatomic) IBOutlet UILabel *madeWithLoveLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

// Labels Titres
@property (weak, nonatomic) IBOutlet UILabel *titreNotificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *titreProfilLabel;
@property (weak, nonatomic) IBOutlet UILabel *titreAproposLabel;

// Notifications Labels
@property (weak, nonatomic) IBOutlet UILabel *notifInvitLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifPhotoLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifModifLabel;

// Notifications Boutons
@property (weak, nonatomic) IBOutlet UIButton *notifInviteButtonPush;
@property (weak, nonatomic) IBOutlet UIButton *notifInviteButtonEmail;
@property (weak, nonatomic) IBOutlet UIButton *notifPhotoButtonPush;
@property (weak, nonatomic) IBOutlet UIButton *notifPhotoButtonEmail;
@property (weak, nonatomic) IBOutlet UIButton *notifMessageButtonPush;
@property (weak, nonatomic) IBOutlet UIButton *notifMessageButtonEmail;
@property (weak, nonatomic) IBOutlet UIButton *notifModifButtonPush;
@property (weak, nonatomic) IBOutlet UIButton *notifModifButtonEmail;

// Like Button
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

// --- Methodes ---

- (id)initWithDDMenuDelegate:(DDMenuController*)delegate;

- (IBAction)clicFollowFacebook;
- (IBAction)clicFollowTwitter;
- (IBAction)clicLikeBadge;
- (IBAction)clicTutoriel;
- (IBAction)clicEditProfil;
- (IBAction)clicCGU;
- (IBAction)clicContactUs;
- (IBAction)clicLogout;

- (IBAction)clicButton:(UIButton*)sender ;

@end
