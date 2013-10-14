//
//  FeedFollowCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedFollowCell.h"
#import "Config.h"
#import "CropImageUtility.h"

@implementation FeedFollowCell

@synthesize feed = _feed;
@synthesize delegate = _delegate;
@synthesize userLabel1 = _userLabel1, userLabel2 = _userLabel2;
@synthesize profileView1 = _profileView1, profileView2 = _profileView2;
@synthesize iconeView = _iconeView;
@synthesize dateLabel = _dateLabel;
@synthesize nowFollowLabel = _nowFollowLabel;

- (id)initWithFeed:(FeedFollow*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.feed = feed;
        self.delegate= delegate;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"FeedFollowCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // User
        [self setUserLabel:self.userLabel1 textForUser:self.feed.user];
        [self setUserLabel:self.userLabel2 textForUser:self.feed.follows[0]];
                
        // Profile Picture
        [self setProfileView:self.profileView1 imageForUser:self.feed.user];
        [self setProfileView:self.profileView2 imageForUser:self.feed.follows[0]];
        // Profile Clic
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicProfile1)];
        [self.profileView1 addGestureRecognizer:tap];
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicProfile2)];
        [self.profileView2 addGestureRecognizer:tap];
        
        // Time Past
        self.dateLabel.font = [[Config sharedInstance] defaultFontWithSize:8];
        self.dateLabel.text = [self.delegate timePastSinceDate:self.feed.date];
        [self.dateLabel sizeToFit];
        CGRect frame = self.dateLabel.frame;
        frame.origin.y = self.iconeView.frame.origin.y + self.iconeView.frame.size.height - frame.size.height;
        frame.origin.x = self.iconeView.frame.origin.x - frame.size.width - 5;
        self.dateLabel.frame = frame;
        
    }
    return self;
}

- (void)clicProfile1 {
    [self.delegate showProfile:self.feed.user];
}

- (void)clicProfile2 {
    [self.delegate showProfile:self.feed.follows[0]];
}

#pragma mark - Util

- (void)setUserLabel:(UILabel*)label textForUser:(UserClass*)user
{
    // User
    label.text = user.formatedUsername;
    label.font = [[Config sharedInstance] defaultFontWithSize:11];
}

- (void)setProfileView:(CustomUIImageView*)profileView imageForUser:(UserClass*)user
{
    UIImage *picture = user.uimage ?: [UIImage imageNamed:@"profil_defaut"];
    UIImage *cropped = [CropImageUtility cropImage:picture intoCircle:CircleSizeFeed];
    
    __weak CustomUIImageView *view = profileView;
    
    if(!user.uimage) {
        [profileView setImage:nil imageString:user.imageString placeHolder:cropped withSaveBlock:^(UIImage *image) {
            
            //self.user.uimage = image;
            UIImage *cropped = [CropImageUtility cropImage:image intoCircle:CircleSizeFeed];
            view.image = cropped;
            
        }];
    }
    else
        profileView.image = cropped;
}

@end
