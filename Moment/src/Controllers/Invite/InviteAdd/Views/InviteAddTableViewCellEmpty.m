//
//  InviteAddTableViewCellEmpty.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InviteAddTableViewCellEmpty.h"
#import "Config.h"

@implementation InviteAddTableViewCellEmpty

@synthesize noResultsLabel = _noResultsLabel;

- (id)initWithSize:(CGFloat)height reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
                
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"InviteAddTableViewCellEmpty" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;
        
        // Set text
        self.noResultsLabel.text = NSLocalizedString(@"InviteAddTableViewController_EmptyCell_noResultsLabel", nil);
        self.noResultsLabel.font = [[Config sharedInstance] defaultFontWithSize:15];
        
        // Centrer
        frame = self.noResultsLabel.frame;
        frame.origin.y = (height/2.0f - frame.size.height)/2.0 - 20.0f;
        self.noResultsLabel.frame = frame;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

@end
