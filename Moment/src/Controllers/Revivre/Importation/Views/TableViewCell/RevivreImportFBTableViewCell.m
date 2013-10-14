//
//  RevivreImportFBTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RevivreImportFBTableViewCell.h"
#import "Config.h"

static NSDateFormatter *dateFormatter = nil;

@implementation RevivreImportFBTableViewCell

@synthesize coverView = _coverView, backgroundColorView = _backgroundColorView;
@synthesize titreLabel = _titreLabel, dateLabel = _dateLabel;
@synthesize creeParLabel = _creeParLabel, ownerLabel = _ownerLabel;
@synthesize alreadyOnMomentLabel = _alreadyOnMomentLabel;

- (id)initWithFacebookEvent:(FacebookEvent*)event withIndex:(NSInteger)index reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"RevivreImportFBTableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        if (event.rsvp_status == UserStateWaiting) {
            [self setAccessoryType:UITableViewCellAccessoryNone];
        } else {
            
            if ([event.numberInvited integerValue] > 200) {
                [self setAccessoryType:UITableViewCellAccessoryNone];
            } else {
                [self setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
        
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

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    // Check for the checkmark
    if (accessoryType == UITableViewCellAccessoryNone)
    {
        // Add the image
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picto_uncheck.png"]];
    }
    else if (accessoryType == UITableViewCellAccessoryCheckmark)
    {
        // Add the image
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picto_check.png"]];
    }
    // We don't have to modify the accessory
    else
    {
        [super setAccessoryType:accessoryType];
    }
}

@end
