//
//  Cagnotte4TableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 16/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Cagnotte4TableViewCell.h"
#import "Config.h"
#import "FacebookManager.h"

@implementation Cagnotte4TableViewCell

- (id)initWithUser:(UserClass*)user
          delegate:(Cagnotte4ViewController*)delegate
             index:(NSInteger)index
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Save
        self.user = user;
        self.delegate = delegate;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"Cagnotte4TableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Nom
        self.nomLabel.text = self.user.formatedUsername;
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:13];
        self.nomLabel.font = font;
        
        // Montant
        self.montantLabel.font = font;
        NSInteger min = (rand()%(100 - 50 + 1)+50);
        self.montantLabel.text = [NSString stringWithFormat:@"%d€", (rand()%( 400 - min + 1 ) + min)];
        
        // Medaillon
        self.medallion.borderWidth = 2.0;
        __weak Cagnotte4TableViewCell *dp = self;
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
                        
        // Background
        if(index%2) {
            // White
            self.backgroundImageView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
        }
        else {
            // Grey
            self.backgroundImageView.backgroundColor = [UIColor colorWithHex:0xeeeeef];
        }

        
    }
    return self;
}


- (void)clicProfile {
    [self.delegate clicProfile:self.user];
}

@end
