//
//  VoletSearchCellMoment.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletSearchCellMoment.h"
#import "Config.h"
#import "UserClass+Server.h"

@implementation VoletSearchCellMoment

@synthesize moment = _moment;
@synthesize nomLabel = _nomLabel;
@synthesize pictureView = _pictureView;

- (id)initWithMoment:(MomentClass*)moment
     reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Save
        self.moment= moment;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"VoletSearchCellMoment" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Label
        self.nomLabel.text = moment.titre;
        self.nomLabel.font = [[Config sharedInstance] defaultFontWithSize:14];
        
        // Picture
        [self.pictureView setImage:self.moment.uimage imageString:self.moment.imageString placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:^(UIImage *image) {
            self.moment.uimage = image;
        }];
        
        // Background
        self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_volet"]];
        
        // Follow Button
        if(self.moment.privacy.intValue != MomentPrivacyOpen) {
            self.followButton.hidden = YES;
        }
    }
    return self;
}

- (IBAction)clicFollowMoment {
    
    UserClass *user = [UserCoreData getCurrentUser];
    [user followPublicMoment:self.moment withEnded:^(BOOL success) {
        
        if(success) {
            self.followButton.selected = !self.followButton.selected;
        }
        
    }];
    
}

@end
