//
//  VoletViewControllerEmptyCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 23/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletViewControllerEmptyCell.h"
#import "Config.h"

@implementation VoletViewControllerEmptyCell

- (id)initWithSize:(CGFloat)height withStyle:(BOOL)isInvitationView
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoletViewControllerEmptyCell"];
    if(self) {
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"VoletViewControllerEmptyCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;
        
        // Set text
        if(isInvitationView)
            self.noResultsLabel.text = NSLocalizedString(@"VoletViewController_EmptyCell_invitationView", nil);
        else
            self.noResultsLabel.text = NSLocalizedString(@"VoletViewController_EmptyCell_notificationView", nil);
        self.noResultsLabel.font = [[Config sharedInstance] defaultFontWithSize:14.3];
                
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

@end
