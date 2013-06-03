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

- (id)initWithNotification:(LocalNotification*)notification
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoletViewControllerNotificationCell"];
    if(self) {
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"VoletViewControllerNotificationCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Label init
        self.texteLabel.font = [[Config sharedInstance] defaultFontWithSize:11];
        
        switch (notification.type) {
            
            case NotificationTypeModification:
                self.pictoView.image = [UIImage imageNamed:@"picto_bulle"];
                self.texteLabel.text = [NSString stringWithFormat:@"Modification sur le moment : %@", notification.moment.titre.uppercaseString];
                break;
                
            case NotificationTypeNewChat:
                self.pictoView.image = [UIImage imageNamed:@"picto_message"];
                self.texteLabel.text = [NSString stringWithFormat:@"Nouveau message sur le moment : %@", notification.moment.titre.uppercaseString];
                break;
                
            case NotificationTypeNewPhoto:
                self.pictoView.image = [UIImage imageNamed:@"picto_photo"];
                self.texteLabel.text = [NSString stringWithFormat:@"Nouvelle photo sur le moment : %@", notification.moment.titre.uppercaseString];
                break;
                
            case NotificationTypeNewFollower:
                self.pictoView.image = [UIImage imageNamed:@"picto_invite"];
                self.texteLabel.text = [NSString stringWithFormat:@"%@ vous suit maintenant", notification.follower.formatedUsername];
                break;
                
            case NotificationTypeFollowRequest:
                self.pictoView.image = [UIImage imageNamed:@"picto_invite"];
                self.texteLabel.text = [NSString stringWithFormat:@"Demande de suivi de %@", notification.requestFollower.formatedUsername];
                break;
                
            default:
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
