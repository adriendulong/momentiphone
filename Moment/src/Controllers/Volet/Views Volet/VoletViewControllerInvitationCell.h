//
//  VoletViewControllerInvitationCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalNotificationCoreData.h"

@interface VoletViewControllerInvitationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CustomAGMedallionView *medallion;
@property (weak, nonatomic) IBOutlet UILabel *momentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nbInvitesLabel;
@property (weak, nonatomic) IBOutlet UILabel *heureLabel;

- (id)initWithNotification:(LocalNotificationCoreData*)notification;

@end
