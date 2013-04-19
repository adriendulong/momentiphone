//
//  InvitePresentsEmptyCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InvitePresentsEmptyCell.h"
#import "Config.h"

@implementation InvitePresentsEmptyCell

@synthesize emptyLabel = _emptyLabel;

- (id)initWithSize:(CGFloat)height reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"InvitePresentsEmptyCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;
        
        // Set text
        self.emptyLabel.text = NSLocalizedString(@"InvitePresentsTableView_EmptyCell_emptyLabel", nil);
        self.emptyLabel.font = [[Config sharedInstance] defaultFontWithSize:15];
        
        // Centrer
        frame = self.emptyLabel.frame;
        frame.origin.y = (height - frame.size.height)/2.0;
        self.emptyLabel.frame = frame;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:NO];
}

@end
