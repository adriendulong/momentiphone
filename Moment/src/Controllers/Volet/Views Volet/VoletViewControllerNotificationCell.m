//
//  VoletViewControllerNotificationCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 23/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletViewControllerNotificationCell.h"
#import "Config.h"

@implementation VoletViewControllerNotificationCell

@synthesize pictoView = _pictoView;
@synthesize texteLabel = _texteLabel;

- (id)initWithNotification:(LocalNotificationCoreData*)notification
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoletViewControllerNotificationCell"];
    if(self) {
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"VoletViewControllerNotificationCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Label init
        self.texteLabel.font = [[Config sharedInstance] defaultFontWithSize:11];
        
        switch (notification.type.intValue) {
            
            case NotificationTypeModification:
                self.pictoView.image = [UIImage imageNamed:@"picto_bulle"];
                self.texteLabel.text = [[NSString stringWithFormat:@"Modification sur le moment : %@", notification.moment.titre] uppercaseString];
                break;
                
            case NotificationTypeNewChat:
                self.pictoView.image = [UIImage imageNamed:@"picto_message"];
                self.texteLabel.text = [[NSString stringWithFormat:@"Nouveau message sur le moment : %@", notification.moment.titre] uppercaseString];
                break;
                
            case NotificationTypeNewPhoto:
                self.pictoView.image = [UIImage imageNamed:@"picto_photo"];
                self.texteLabel.text = [[NSString stringWithFormat:@"Nouvelle photo sur le moment : %@", notification.moment.titre] uppercaseString];
                break;
        }
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
