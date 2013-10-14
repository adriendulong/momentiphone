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
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_volet.png"]];
        
        switch (notification.type) {
            
            case NotificationTypeModification:
                self.pictoView.image = [UIImage imageNamed:@"picto_bulle_past"];
                self.texteLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VoletViewControllerNotificationCell_ModifMoment", nil), notification.moment.titre.uppercaseString];
                break;
                
            case NotificationTypeNewChat:
                self.pictoView.image = [UIImage imageNamed:@"picto_message_past"];
                self.texteLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VoletViewControllerNotificationCell_NewMessage", nil), notification.moment.titre.uppercaseString];
                break;
                
            case NotificationTypeNewPhoto:
                self.pictoView.image = [UIImage imageNamed:@"picto_photo_past"];
                self.texteLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VoletViewControllerNotificationCell_NewPhoto", nil), notification.moment.titre.uppercaseString];
                break;
                
            case NotificationTypeNewFollower:
                self.pictoView.image = [UIImage imageNamed:@"picto_invite_past"];
                self.texteLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VoletViewControllerNotificationCell_Follow", nil), notification.follower.formatedUsername];
                break;
                
            case NotificationTypeFollowRequest:
                self.pictoView.image = [UIImage imageNamed:@"picto_invite_past"];
                self.texteLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VoletViewControllerNotificationCell_FollowDemand", nil), notification.requestFollower.formatedUsername];
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
