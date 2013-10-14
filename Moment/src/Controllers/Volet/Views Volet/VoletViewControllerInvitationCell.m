//
//  VoletViewControllerInvitationCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletViewControllerInvitationCell.h"
#import "Config.h"
#import "UILabel+BottomAlign.h"

static NSDateFormatter *dateFormatter = nil;

@implementation VoletViewControllerInvitationCell

@synthesize medallion = _medallion;
@synthesize momentLabel = _momentLabel;
@synthesize dateLabel = _dateLabel;
@synthesize nbInvitesLabel = _nbInvitesLabel;
@synthesize heureLabel = _heureLabel;

- (id)initWithNotification:(LocalNotification*)notification
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoletViewControllerInvitationCell"];
    if(self) {
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"VoletViewControllerInvitationCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_volet.png"]];
        
        // Set image
        self.medallion.borderWidth = 1.5;
        //self.medallion.borderColor = [Config sharedInstance].orangeColor;
        if(notification.moment.imageString || notification.moment.dataImage) {
            [self.medallion setImage:notification.moment.uimage imageString:notification.moment.imageString withSaveBlock:^(UIImage *image) {
                notification.moment.uimage = image;
            }];
        }
        
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:12];
        
        // Nom moment
        self.momentLabel.text = notification.moment.titre;
        self.momentLabel.font = font;
        CGPoint origin = self.momentLabel.frame.origin;
        NSInteger marge = 60;
        NSInteger max = 270 - marge - origin.x;
        [self.momentLabel sizeToFit];
        CGRect frame = self.momentLabel.frame;
        frame.origin = origin;
        frame.size.width = MIN(frame.size.width, max);
        self.momentLabel.frame = frame;
        
        // Date Formatter
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale currentLocale];
            dateFormatter.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.calendar = [NSCalendar currentCalendar];
        }
        
        // Heure
        dateFormatter.dateFormat = @"HH:mm";
        self.heureLabel.text = [dateFormatter stringFromDate:notification.moment.dateDebut];
        self.heureLabel.font = font;
        
        // Jour
        dateFormatter.dateFormat = @"d MMMM";
        self.dateLabel.text = [dateFormatter stringFromDate:notification.moment.dateDebut];
        self.dateLabel.font = font;
        frame = self.dateLabel.frame;
        NSInteger end = frame.origin.x + frame.size.width - 5;
        frame.origin.x = self.momentLabel.frame.origin.x + self.momentLabel.frame.size.width + 5;
        frame.size.width = end - frame.origin.x;
        frame.size.height = self.momentLabel.frame.size.height;
        self.dateLabel.frame = frame;
        frame.origin.y = [self.dateLabel topAfterBottomAligningWithLabel:self.momentLabel];
        self.dateLabel.frame = frame;
        
        // Nb Invités
        self.nbInvitesLabel.text = [NSString stringWithFormat:@"%@", notification.moment.guests_number];
        self.nbInvitesLabel.font = font;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
