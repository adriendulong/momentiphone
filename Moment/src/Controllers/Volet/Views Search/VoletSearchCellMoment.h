//
//  VoletSearchCellMoment.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIImageView.h"
#include "VoletSearchViewController.h"

@interface VoletSearchCellMoment : UITableViewCell

@property (nonatomic, weak) MomentClass *moment;

@property (nonatomic, weak) IBOutlet CustomUIImageView *pictureView;
@property (nonatomic, weak) IBOutlet UILabel *nomLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

- (id)initWithMoment:(MomentClass*)moment
     reuseIdentifier:(NSString*)reuseIdentifier;

@end
