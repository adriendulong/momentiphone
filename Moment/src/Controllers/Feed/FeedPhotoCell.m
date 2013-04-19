//
//  FeedBigCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedPhotoCell.h"
#import "Config.h"
#import "Photos.h"
#import "CropImageUtility.h"
#import "UILabel+BottomAlign.h"

@implementation FeedPhotoCell

@synthesize feed = _feed;
@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;
@synthesize userLabel = _userLabel;
@synthesize momentLabel = _momentLabel;
@synthesize infoLabel = _infoLabel;
@synthesize info2Label = _info2Label;
@synthesize profileView = _profileView;
@synthesize iconeView = _iconeView;
@synthesize dateLabel = _dateLabel;

- (id)initWithFeed:(FeedPhoto*)feed
   reuseIdentifier:(NSString*)reuseIdentifier
          delegate:(FeedViewController*)delegate
             index:(NSInteger)index
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.feed = feed;
        self.delegate= delegate;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"FeedPhotoCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // User
        if(self.feed.user.prenom && self.feed.user.nom)
            self.userLabel.text = [NSString stringWithFormat:@"%@ %@", [self.feed.user.prenom uppercaseString], [self.feed.user.nom uppercaseString]];
        else if(self.feed.user.prenom || self.feed.user.nom)
        {
            if(self.feed.user.prenom)
                self.userLabel.text = [self.feed.user.prenom uppercaseString];
            else
                self.userLabel.text = [self.feed.user.nom uppercaseString];
        }
        self.userLabel.font = [[Config sharedInstance] defaultFontWithSize:11];
        [self.userLabel sizeThatFits:self.userLabel.frame.size];
        
        // Moment
        self.momentLabel.text = [self.feed.moment.titre uppercaseString];
        self.momentLabel.font = [[Config sharedInstance] defaultFontWithSize:10];
        
        // Info
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:8];
        self.infoLabel.font = font;
        self.info2Label.font = font;
        
        // Info
        if([self.feed.photos count] > 1) {
            self.infoLabel.text = @"A POSTÉ DE NOUVELLES";
            self.info2Label.text = @"PHOTOS DANS";
        }
        else {
            self.infoLabel.text = @"A POSTÉ UNE NOUVELLE";
            self.info2Label.text = @"PHOTO DANS";
        }
        
        [self.info2Label sizeToFit];
        CGRect frame = self.info2Label.frame;
        frame.origin.y = [self.info2Label topAfterBottomAligningWithLabel:self.momentLabel];
        self.info2Label.frame = frame;
        frame = self.momentLabel.frame;
        frame.origin.x = self.info2Label.frame.origin.x + self.info2Label.frame.size.width + 5;
        frame.size.width = self.iconeView.frame.origin.x - 3 - frame.origin.x;
        self.momentLabel.frame = frame;
        
        // Scroll View
        self.scrollView.contentSize = CGSizeMake(2*BIGFEED_SCROLL_OFFSET + [self.feed.photos count]*(BIGFEED_SCROLL_OFFSET+BIGFEED_SCROLL_WIDTH+1), self.scrollView.frame.size.height);
        self.scrollView.delegate = self.delegate;
        self.scrollView.tag = [self.feed.photos count]-1;
        
        if([self.feed.photos count] == 1) {
            self.scrollView.scrollEnabled = NO;
        }

        int i = 0;
        for(Photos *p in self.feed.photos)
        {
            CustomUIImageView *imageView = [[CustomUIImageView alloc] initWithFrame:CGRectMake(2*BIGFEED_SCROLL_OFFSET + i*(BIGFEED_SCROLL_OFFSET+BIGFEED_SCROLL_WIDTH), 0, BIGFEED_SCROLL_WIDTH, self.scrollView.frame.size.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.scrollView addSubview:imageView];
            [imageView setImage:p.imageOriginal imageString:p.urlOriginal placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:^(UIImage *image) {
                p.imageOriginal = image;
            }];
            i++;
        }
        
        NSInteger startPhoto = rand()%([self.feed.photos count]);
        CGFloat startPosition = startPhoto*(BIGFEED_SCROLL_OFFSET+BIGFEED_SCROLL_WIDTH);
        self.scrollView.contentOffset = CGPointMake(startPosition , 0);
        
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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicProfile)];
        [self.profileView addGestureRecognizer:tap];
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPhotoView)];
        [self.scrollView addGestureRecognizer:tap];
        
        // Time Past
        self.dateLabel.font = [[Config sharedInstance] defaultFontWithSize:8];
        self.dateLabel.text = [self.delegate timePastSinceDate:self.feed.date];
        [self.dateLabel sizeToFit];
        frame = self.dateLabel.frame;
        frame.size.width = self.momentLabel.frame.origin.x + self.momentLabel.frame.size.width - self.iconeView.frame.origin.x;
        frame.origin.y = self.iconeView.frame.origin.y + self.iconeView.frame.size.height - frame.size.height;
        frame.origin.x = self.iconeView.frame.origin.x - frame.size.width - 5;
        self.dateLabel.frame = frame;
        
        
    }
    return self;
}

- (void)clicProfile {
    [self.delegate showProfile:self.feed.user];
}

- (void)showPhotoView {
    [self.delegate showPhotoView:self.feed.moment];
}

@end
