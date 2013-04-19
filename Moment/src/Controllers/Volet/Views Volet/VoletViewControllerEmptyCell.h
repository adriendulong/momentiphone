//
//  VoletViewControllerEmptyCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 23/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoletViewControllerEmptyCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *noResultsLabel;

- (id)initWithSize:(CGFloat)height withStyle:(BOOL)isInvitationView;

@end
