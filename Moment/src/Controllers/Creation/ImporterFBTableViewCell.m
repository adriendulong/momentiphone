//
//  ImporterFBTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ImporterFBTableViewCell.h"
#import "Config.h"

static NSDateFormatter *dateFormatter = nil;

@implementation ImporterFBTableViewCell

@synthesize coverView = _coverView, buttonView = _buttonView, backgroundColorView = _backgroundColorView;
@synthesize titreLabel = _titreLabel, dateLabel = _dateLabel;
@synthesize creeParLabel = _creeParLabel, ownerLabel = _ownerLabel;
@synthesize alreadyOnMomentLabel = _alreadyOnMomentLabel;

- (id)initWithFacebookEvent:(FacebookEvent*)event withIndex:(NSInteger)index reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"ImporterFBTableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.autoresizesSubviews = NO;
        
        // Font
        UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:13];
        UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:10];
        
        // Titre
        self.titreLabel.text = event.name;
        self.titreLabel.font = bigFont;;
        
        // Date
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale currentLocale];
            dateFormatter.calendar = [NSCalendar currentCalendar];
            dateFormatter.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.dateFormat = @"d MMMM yyyy À H";
        }
        self.dateLabel.text = [[dateFormatter stringFromDate:event.startTime] stringByAppendingString:@"h"];
        self.dateLabel.font = smallFont;
        
        // Owner
        if(event.rsvp_status == UserStateOwner) {
            self.ownerLabel.text = @"VOUS";
        }
        else if(event.owner && (event.owner.prenom || event.owner.nom) ) {
            self.ownerLabel.text = event.owner.formatedUsername;
        }
        else {
            self.ownerLabel.text = [event.ownerAttributes[@"name"] uppercaseString];
        }
        self.ownerLabel.font = bigFont;
        self.creeParLabel.font = smallFont;
        
        // Admin
        if(event.rsvp_status == UserStateOwner || event.rsvp_status == UserStateAdmin) {
            self.buttonView.image = [UIImage imageNamed:@"importFB_bouton_edit"];
        }
        else
            self.buttonView.image = [UIImage imageNamed:@"importFB_bouton_fleche"];
        
        // Already on Moment
        if(!event.isAlreadyOnMoment)
        {
            self.alreadyOnMomentLabel.hidden = YES;
            CGRect frame = self.ownerLabel.frame;
            frame.size.width = self.alreadyOnMomentLabel.frame.origin.x + self.alreadyOnMomentLabel.frame.size.width - frame.origin.x;
            self.ownerLabel.frame = frame;
        }
        else
            self.alreadyOnMomentLabel.font = smallFont;
        
        // Cover
        [self.coverView setImage:nil imageString:event.pictureString placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:nil];
        
        // Background
        UIColor *color = nil;
        if( index%2 == 0 )
            color = [UIColor colorWithHex:0xf3f3f4];
        else
            color = [UIColor clearColor];
        self.backgroundColorView.backgroundColor = color;
        
    }
    return self;
}

@end
