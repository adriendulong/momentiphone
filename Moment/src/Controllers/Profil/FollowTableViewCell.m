//
//  FollowTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FollowTableViewCell.h"
#import "FacebookManager.h"
#import "Config.h"
#import "ProfilViewController.h"
#import "UserClass+Server.h"
#import "MTStatusBarOverlay.h"

@implementation FollowTableViewCell

@synthesize user = _user;
@synthesize index = _index;
@synthesize navigationController = _navigationController;
@synthesize buttonState = _buttonState;

@synthesize followButton = _followButton;
@synthesize nomLabel = _nomLabel;
@synthesize medallion = _medallion;
@synthesize backgroundImageView = _backgroundImageView;

- (id)initWithUser:(UserClass*)user
         withIndex:(NSInteger)index
   reuseIdentifier:(NSString*)reuseIdentifier
navigationController:(UINavigationController*)navController
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.navigationController = navController;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"FollowTableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.autoresizesSubviews = NO;
        
        // Save
        self.user = user;
        
        // Set Nom
        self.nomLabel.text = [user formatedUsernameWithStyle:UsernameStyleCapitalized];
        self.nomLabel.font = [[Config sharedInstance] defaultFontWithSize:14];
        
        // Set image
        self.medallion.borderWidth = 2.0;
        self.medallion.defaultStyle = MedallionStyleProfile;
        if(user.uimage || user.imageString) {
            [self.medallion setImage:user.uimage imageString:user.imageString withSaveBlock:nil];
        }
        else if(user.facebookId) {
            [[FacebookManager sharedInstance] getFriendProfilePrictureURL:user.facebookId withEnded:^(NSString *url) {
                [self.medallion setImage:self.medallion.image imageString:url withSaveBlock:^(UIImage *image) {
                    self.user.uimage = image;
                }];
            }];
        }
        [self.medallion addTarget:self action:@selector(clicProfile) forControlEvents:UIControlEventTouchUpInside];
        
        // Boutons
        // -> On ne peut pas se follow soi-même
        // -> On ne peut pas follow un user private
        UserClass *current = nil;
        if( ((self.user.state.intValue == UserStateCurrent) || ( (current = [UserCoreData getCurrentUser]) && [self.user.userId isEqualToNumber:current.userId])) || ((self.user.privacy == nil) || (self.user.privacy.intValue == UserPrivacyClosed)) ) {
            self.followButton.hidden = YES;
        }
        else {
            self.followButton.hidden = NO;
            [self.followButton setSelected:[self.user.is_followed boolValue]];
        }
        
        
        // Background
        UIColor *color = nil;
        if( index%2 == 0 )
            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
        self.backgroundImageView.backgroundColor = color;
        
        // Button State
        self.buttonState = self.user.request_follower.boolValue ? FollowButtonStateWaiting : (self.user.is_followed.boolValue? FollowButtonStateFollowed : FollowButtonStateNotFollowed);
        
    }
    return self;
}

- (IBAction)clicFollowButton
{
    if(self.buttonState != FollowButtonStateWaiting)
    {
        // Si on veut unfollow -> AlertView pour prévenir
        if(self.buttonState == FollowButtonStateFollowed) {
            [[[UIAlertView alloc]
              initWithTitle:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_Title", nil)
              message:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_Message", nil)
              delegate:self
              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
              otherButtonTitles:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_ConfirmButton", nil), nil]
             show];
        }
        else {
            [self sendToggleFollowRequest];
        }
        
    }
}

- (void)sendToggleFollowRequest {
    
    enum FollowButtonState previousState = self.buttonState;
    
    [self.followButton setSelected:!self.followButton.selected];
    
    // Follow / UnFollow user selectionné
    [self.user toggleFollowWithEnded:^(BOOL success, BOOL waitForResponse) {
        
        // Success
        if(success) {
            
            enum FollowButtonState newState = waitForResponse ? FollowButtonStateWaiting : ((previousState == FollowButtonStateFollowed)? FollowButtonStateNotFollowed : FollowButtonStateFollowed );
            
            self.buttonState = newState;
        }
        // Si il y a eu un erreur
        else {
            
            // On remet le bouton dans le bonne état
            [self.followButton setSelected:!self.followButton.selected];
            self.buttonState = previousState;
            
            // On informe l'utilisateur
            [[MTStatusBarOverlay sharedInstance] postImmediateErrorMessage:NSLocalizedString(@"FollowTableViewController_AddFollow_ErrorMessage", nil)
                                                                  duration:1
                                                                  animated:YES];
            
        }
    }];
}

- (void)clicProfile {
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:profil animated:YES];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Confirmation de la demande de unfollow
    if(buttonIndex == 1)
    {
        [self sendToggleFollowRequest];
    }
}

@end
