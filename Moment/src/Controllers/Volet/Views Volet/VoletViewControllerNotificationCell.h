//
//  VoletViewControllerNotificationCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 23/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalNotification.h"
#import "TTTAttributedLabel.h"

@interface VoletViewControllerNotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *pictoView;

@property (weak, nonatomic) IBOutlet UILabel *texteLabel;

- (id)initWithNotification:(LocalNotification*)notification;

@end
