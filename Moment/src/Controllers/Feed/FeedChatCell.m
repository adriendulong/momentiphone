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
@synthesize nbMessagesLabel = _nbMessagesLabel;

- (id)initWithFeed:(FeedMessage*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate
{
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.feed = feed;
        self.delegate= delegate;
        
        // Small or Large View
        NSInteger taille = [self.feed.messages count];
        NSString *message = nil;
        if(taille > 0)
            message = ((ChatMessage*)self.feed.messages[0]).message;
        else
            message = @" ... ";
        BOOL isLargeView = feed.shouldUseLargeView;
        NSString *xib = isLargeView ? @"FeedChatCell_Large" : @"FeedChatCell_Small";
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:xib owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // User
        self.userLabel.text = self.feed.user.formatedUsername;
        self.userLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
        
        // Moment
        self.momentLabel.text = [self.feed.moment.titre uppercaseString];
        self.momentLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
        
        if(isLargeView) {
            
            if(taille>1) {
                // Info
                UIFont *font = [[Config sharedInstance] defaultFontWithSize:12];
                self.infoLabel.font = font;
                self.infoLabel.text = NSLocalizedString(@"FeedViewController_lire_messages_label1", nil);
                [self.infoLabel sizeToFit];
                
                self.nbMessagesLabel.font = font;
                self.nbMessagesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"FeedViewController_lire_messages_label2", nil), taille];
                [self.nbMessagesLabel sizeToFit];
                
                CGRect frame = self.nbMessagesLabel.frame;
                frame.origin.x = self.infoLabel.frame.origin.x + self.infoLabel.frame.size.width + 5;
                frame.size.width = 320 - (320 - self.nbMessagesLabel.frame.origin.x - self.nbMessagesLabel.frame.size.width) - frame.origin.x - frame.size.width;
                self.nbMessagesLabel.frame = frame;
            }
            else {
                self.nbMessagesLabel.hidden = YES;
                self.infoLabel.hidden = YES;
            }
            
        }
        else {
            
        }
        
        // Message
        self.messageLabel.font = [[Config sharedInstance] defaultFontWithSize:10];
        self.messageLabel.text = [NSString stringWithFormat:@"\"%@\"", message];
        
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
        if(isLargeView) {
            [self.dateLabel sizeToFit];
            CGRect frame = self.dateLabel.frame;
            frame.origin.y = self.iconeView.frame.origin.y + self.iconeView.frame.size.height - frame.size.height;
            frame.origin.x = self.iconeView.frame.origin.x - frame.size.width - 5;
            self.dateLabel.frame = frame;
        }
        
    }
    return self;
    
}

- (void)clicProfile {
    [self.delegate showProfile:self.feed.user];
}

/*
#pragma mark - Util

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.masksToBounds  = NO;
}
*/

@end
