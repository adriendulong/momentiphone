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

- (id)initWithSize:(CGFloat)height
   reuseIdentifier:(NSString*)reuseIdentifier
             style:(enum InviteAddTableViewControllerStyle)style
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
        
        self.backgroundColor = [UIColor clearColor];
        
        // Set text
        if(style == InviteAddTableViewControllerFavorisStyle) {
            self.noResultsLabel.text = NSLocalizedString(@"InviteAddTableViewController_EmptyCell_noResultsLabel_favoris", nil);
            self.noResultsLabel.font = [[Config sharedInstance] defaultFontWithSize:15];
            [self.noResultsLabel sizeToFit];
        }
        else {
            self.noResultsLabel.hidden = YES;
        }
        
        // Centrer
        frame = self.noResultsLabel.frame;
        frame.origin.y = (height - frame.size.height)/2.0 - 20.0f;
        frame.origin.x = (320 - frame.size.width)/2.0f;
        self.noResultsLabel.frame = frame;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

@end
