//
//  Cagnotte3TableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Cagnotte3TableViewCell.h"
#import "Config.h"
#import "FacebookManager.h"

@implementation Cagnotte3TableViewCell

- (id)initWithUser:(NSMutableDictionary*)user
          delegate:(Cagnotte3ViewController*)delegate
             index:(NSInteger)index
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Save
        self.user = user[@"user"];
        self.delegate = delegate;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"Cagnotte3TableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Nom
        NSString *titre = nil;
        if(self.user.prenom && self.user.nom) {
            titre = [NSString stringWithFormat:@"%@ %@", self.user.prenom, self.user.nom];
        }
        else if(self.user.prenom || self.user.nom) {
            if(self.user.prenom)
                titre = self.user.prenom;
            else
                titre = self.user.nom;
        }
        self.nomLabel.text = titre;
        self.nomLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
        
        // Medaillon
        self.medallion.borderWidth = 2.0;
        __weak Cagnotte3TableViewCell *dp = self;
        if(self.user.uimage || self.user.imageString) {
            [self.medallion setImage:self.user.uimage imageString:self.user.imageString withSaveBlock:^(UIImage *image) {
                [dp.user setUimage:image];
            }];
        }
        else if(self.user.facebookId) {
            [[FacebookManager sharedInstance] getFriendProfilePrictureURL:self.user.facebookId withEnded:^(NSString *url) {
                [self.medallion setImage:self.medallion.image imageString:url withSaveBlock:^(UIImage *image) {
                    [dp.user setUimage:image];
                }];
            }];
        }
        [self.medallion addTarget:self action:@selector(clicProfile) forControlEvents:UIControlEventTouchUpInside];
        
        // Switch
        [self.switchButton setChangeHandler:^(BOOL on) {
            [self.delegate toggleSwitch:on user:self.user];
        }];
        
        // Current user
        UserClass *current = nil;
        if( (self.user.state.intValue == UserStateCurrent) || ((current = [UserCoreData getCurrentUser]) && ([current.userId isEqualToNumber:self.user.userId]) )) {
            [self.switchButton setOn:YES animated:NO];
            self.switchButton.hidden = YES;
        }
        else {
            if(user[@"switch"]) {
                [self.switchButton setOn:[user[@"switch"] boolValue] animated:NO];
            }
        }
        
        // Background
        if(index%2) {
            // White
            self.backgroundImageView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
            self.switchButton.overlayImage = [UIImage imageNamed:@"switch_overlay_lightgrey"];
        }
        else {
            // Grey
            self.backgroundImageView.backgroundColor = [UIColor colorWithHex:0xeeeeef];
            self.switchButton.overlayImage = [UIImage imageNamed:@"switch_overlay_grey"];
        }
        
    }
    return self;
}

- (void)clicProfile {
    [self.delegate clicProfile:self.user];
}

@end
