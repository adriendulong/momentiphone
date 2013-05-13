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
        UserClass *current = nil;
        if( (self.user.state.intValue == UserStateCurrent) || ( (current = [UserCoreData getCurrentUser]) && [self.user.userId isEqualToNumber:current.userId]) ) {
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
        
    }
    return self;
}

- (IBAction)clicFollowButton
{
    [self.followButton setSelected:!self.followButton.selected];
    
    // Follow / UnFollow user selectionné
    [self.user toggleFollowWithEnded:^(BOOL success) {
        
        // Si il y a eu un erreur
        if(!success) {
            
            // On remet le bouton dans le bonne état
            [self.followButton setSelected:!self.followButton.selected];
            
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

@end
