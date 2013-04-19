//
//  ChatTableViewEmptyCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatTableViewEmptyCell.h"
#import "Config.h"

@implementation ChatTableViewEmptyCell

- (id)initWithHeight:(CGFloat)height reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        CGRect frame = self.frame;
        frame.size.height = height;
        frame.size.width = 320;
        self.frame = frame;
        
        NSString *texte = NSLocalizedString(@"ChatViewController_EmptyCell_label", nil);
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:14];
        CGSize size = [texte sizeWithFont:font];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (height - size.height)/2.0 , 320, size.height)];
        label.text = texte;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [Config sharedInstance].textColor;
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:label];
    }
    return self;
}

@end
