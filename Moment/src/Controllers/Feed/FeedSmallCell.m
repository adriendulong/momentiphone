//
//  FeedSmallCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedSmallCell.h"
#import "Config.h"
#import "CropImageUtility.h"
#import "UILabel+BottomAlign.h"

@implementation FeedSmallCell

@synthesize feed = _feed;
@synthesize delegate = _delegate;
@synthesize userLabel = _userLabel;
@synthesize momentLabel = _momentLabel;
@synthesize infoLabel = _infoLabel;
@synthesize info2Label = _info2Label;
@synthesize profileView = _profileView;
@synthesize iconeView = _iconeView;
@synthesize backgroundLocationView = _backgroundLocationView;
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
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"FeedSmallCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // User
        self.userLabel.text = self.feed.user.formatedUsername;
        self.userLabel.font = [[Config sharedInstance] defaultFontWithSize:11];
                
        // Moment
        self.momentLabel.text = [self.feed.moment.titre uppercaseString];
        self.momentLabel.font = [[Config sharedInstance] defaultFontWithSize:10];
        
        // Info
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:8];
        self.infoLabel.font = font;
        self.info2Label.font = font;
        switch (self.feed.type) {
                            
            case FeedTypeGoing: {
                self.infoLabel.text = @"VIENT AU";
                self.info2Label.text = @"MOMENT";
                self.iconeView.image = [UIImage imageNamed:@"picto_feed_bulle"];
            } break;
                
            case FeedTypeInvited: {
                self.infoLabel.text = @"A ÉTÉ INVITÉ";
                self.info2Label.text = @"AU MOMENT";
                self.iconeView.image = [UIImage imageNamed:@"picto_feed_user"];
            } break;
            
            default:
                break;
        }
        [self.info2Label sizeToFit];
        CGRect frame = self.info2Label.frame;
        frame.origin.y = [self.info2Label topAfterBottomAligningWithLabel:self.momentLabel];
        self.info2Label.frame = frame;
        frame = self.momentLabel.frame;
        frame.origin.x = self.info2Label.frame.origin.x + self.info2Label.frame.size.width + 5;
        frame.size.width = self.iconeView.frame.origin.x - 3 - frame.origin.x;
        self.momentLabel.frame = frame;
        
        // Cover
        [self.coverView setImage:self.feed.moment.uimage imageString:self.feed.moment.imageString placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:^(UIImage *image) {
            self.feed.moment.uimage = image;
        }];
        
        // Moment
        if(self.feed.moment.adresse) {
            self.locationLabel.text = self.feed.moment.adresse;
            self.locationLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
        }
        else {
            self.locationLabel.alpha = 0;
            self.backgroundLocationView.alpha = 0;
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
        [self.dateLabel sizeToFit];
        frame = self.dateLabel.frame;
        frame.origin.y = self.iconeView.frame.origin.y + self.iconeView.frame.size.height - frame.size.height;
        frame.origin.x = self.iconeView.frame.origin.x - frame.size.width - 5;
        self.dateLabel.frame = frame;
        
    }
    return self;
}

- (void)clicProfile {    
    [self.delegate showProfile:self.feed.user];
}

@end
