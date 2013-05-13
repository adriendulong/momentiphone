//
//  FeedChatCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedChatCell.h"
#import "Config.h"
#import "CropImageUtility.h"
#import "UILabel+BottomAlign.h"

@implementation FeedChatCell

@synthesize feed = _feed;
@synthesize delegate = _delegate;
@synthesize userLabel = _userLabel;
@synthesize profileView = _profileView;
@synthesize iconeView = _iconeView;
@synthesize dateLabel = _dateLabel;
@synthesize infoLabel = _infoLabel;
@synthesize messageLabel = _messageLabel;
@synthesize momentLabel = _momentLabel;
@synthesize coverView = _coverView;

- (id)initWithFeed:(FeedMessage*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate
{
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.feed = feed;
        self.delegate= delegate;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"FeedChatCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // User
        self.userLabel.text = self.feed.user.formatedUsername;
        self.userLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
        [self addShadowToView:self.userLabel];
        
        // Moment
        self.momentLabel.text = [self.feed.moment.titre uppercaseString];
        self.momentLabel.font = [[Config sharedInstance] defaultFontWithSize:10];
        
        // Info
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:8];
        self.infoLabel.font = font;
        self.infoLabel.text = NSLocalizedString(@"FeedViewController_aboutMoment_label", nil);
        
        [self.infoLabel sizeToFit];
        CGRect frame = self.infoLabel.frame;
        frame.origin.y = [self.infoLabel topAfterBottomAligningWithLabel:self.momentLabel];
        self.infoLabel.frame = frame;
        frame = self.momentLabel.frame;
        frame.origin.x = self.infoLabel.frame.origin.x + self.infoLabel.frame.size.width + 5;
        frame.size.width = self.iconeView.frame.origin.x - 3 - frame.origin.x;
        self.momentLabel.frame = frame;
        
        // Message
        self.messageLabel.font = [[Config sharedInstance] defaultFontWithSize:10];
        NSString *message = nil;
        if([self.feed.messages count] > 0) {
            message = ((ChatMessage*)self.feed.messages[0]).message;
        }
        self.messageLabel.text = [NSString stringWithFormat:@"\"%@\"", message  ?: @" ... "];
        
        // Cover
        [self.coverView setImage:self.feed.moment.uimage imageString:self.feed.moment.imageString placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:^(UIImage *image) {
            self.feed.moment.uimage = image;
        }];
        
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
        
        // Profile Clic
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

#pragma mark - Util

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.masksToBounds  = NO;
}

@end
