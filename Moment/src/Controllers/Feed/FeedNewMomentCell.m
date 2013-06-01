//
//  FeedNewMomentCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 01/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedNewMomentCell.h"
#import "Config.h"
#import "CropImageUtility.h"
#import "UILabel+BottomAlign.h"

@implementation FeedNewMomentCell

@synthesize feed = _feed;
@synthesize delegate = _delegate;
@synthesize userLabel = _userLabel;
@synthesize infoLabel = _infoLabel;
@synthesize profileView = _profileView;
@synthesize coverView = _coverView;
@synthesize dateLabel = _dateLabel;

- (id)initWithFeed:(Feed*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.feed = feed;
        self.delegate= delegate;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"FeedNewMomentCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // User
        self.userLabel.text = self.feed.user.formatedUsername;
        self.userLabel.font = [[Config sharedInstance] defaultFontWithSize:11];
        
        // Info
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:8];
        self.infoLabel.font = font;
        
        self.infoLabel.text = @"VIENT DE CRÉER UN MOMENT";
            
        // Cover
        [self.coverView setImage:self.feed.moment.uimage imageString:self.feed.moment.imageString placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:^(UIImage *image) {
            self.feed.moment.uimage = image;
        }];
        
        // Titre
        if(self.feed.moment.titre) {
            self.titleLabel.text = self.feed.moment.adresse;
            self.titleLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
        }
        else {
            self.titleLabel.alpha = 0;
            self.backgroundTitleView.alpha = 0;
        }
        
        // Profile Picture
        UIImage *picture = self.feed.user.uimage?self.feed.user.uimage : [UIImage imageNamed:@"profil_defaut"];
        UIImage *cropped = [CropImageUtility cropImage:picture intoCircle:CircleSizeFeed];
        if(!self.feed.user.uimage) {
            [self.profileView setImage:nil imageString:self.feed.user.imageString placeHolder:cropped withSaveBlock:^(UIImage *image) {
                
                //self.user.uimage = image;
                UIImage *cropped = [CropImageUtility cropImage:image intoCircle:CircleSizeFeed];
                self.profileView.image = cropped;
                
            }];
        }
        else
            self.profileView.image = cropped;
        
        
        // Profile
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicProfile)];
        [self.profileView addGestureRecognizer:tap];
        
        // Time Past
        self.dateLabel.font = [[Config sharedInstance] defaultFontWithSize:8];
        self.dateLabel.text = [self.delegate timePastSinceDate:self.feed.date];
        
    }
    return self;
}

- (void)clicProfile {
    [self.delegate showProfile:self.feed.user];
}

@end
