//
//  VoletSearchCellUtilisateur.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletSearchCellUtilisateur.h"
#import "Config.h"
#import "FacebookManager.h"
#import "UserClass+Server.h"

@implementation VoletSearchCellUtilisateur

@synthesize medallion = _medallion;
@synthesize nomLabel = _nomLabel;
@synthesize followButton = _followButton;

- (id)initWithUser:(UserClass*)user reuseIdentifier:(NSString*)reuseIdentifier;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        // Save
        self.user = user;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"VoletSearchCellUtilisateur" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Label
        self.nomLabel.text = [self.user formatedUsernameWithStyle:UsernameStyleCapitalized];
        self.nomLabel.font = [[Config sharedInstance] defaultFontWithSize:14];
        
        // Set image
        self.medallion.borderWidth = 0;
        self.medallion.defaultStyle = MedallionStyleProfile;
        //self.medallion.borderColor = [Config sharedInstance].orangeColor;
        if(self.user.uimage || self.user.imageString) {
            [self.medallion setImage:user.uimage imageString:user.imageString withSaveBlock:nil];
        }
        else if(self.user.facebookId) {
            [[FacebookManager sharedInstance] getFriendProfilePrictureURL:user.facebookId withEnded:^(NSString *url) {
                [self.medallion setImage:nil imageString:url withSaveBlock:^(UIImage *image) {
                    user.uimage = image;
                }];
            }];
        }
       
        // Bouton
        self.followButton.selected = self.user.is_followed.boolValue;
        
        // Background
        self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_volet"]];
        
    }
    return self;
}

- (IBAction)clicFollow {
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

@end
