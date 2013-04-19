//
//  VoletViewControllerInvitationCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletViewControllerInvitationCell.h"
#import "Config.h"

static NSDateFormatter *dateFormatter = nil;

@implementation VoletViewControllerInvitationCell

@synthesize medallion = _medallion;
@synthesize momentLabel = _momentLabel;
@synthesize dateLabel = _dateLabel;
@synthesize nbInvitesLabel = _nbInvitesLabel;
@synthesize heureLabel = _heureLabel;

- (id)initWithNotification:(LocalNotificationCoreData*)notification
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoletViewControllerInvitationCell"];
    if(self) {
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"VoletViewControllerInvitationCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Set image
        self.medallion.borderWidth = 1.5;
        //self.medallion.borderColor = [Config sharedInstance].orangeColor;
        if(notification.moment.imageString || notification.moment.dataImage) {
            [self.medallion setImage:notification.moment.uimage imageString:notification.moment.imageString withSaveBlock:^(UIImage *image) {
                [notification.moment setDataImageWithUIImage:image];
            }];
        }
        
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:12];
        
        // Nom moment
        self.momentLabel.text = notification.moment.titre;
        self.momentLabel.font = font;
        
        // Date Formatter
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale currentLocale];
            dateFormatter.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.calendar = [NSCalendar currentCalendar];
        }
        
        // Heure
        dateFormatter.dateFormat = @"hh:mm";
        self.heureLabel.text = [dateFormatter stringFromDate:notification.date];
        self.heureLabel.font = font;
        
        // Jour
        dateFormatter.dateFormat = @"dd MMMM";
        self.dateLabel.text = [dateFormatter stringFromDate:notification.date];
        self.dateLabel.font = font;
        
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
