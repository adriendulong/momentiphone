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
        //CGSize size = [texte sizeWithFont:font];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = texte;
        label.numberOfLines = 0;
        label.lineBreakMode = UILineBreakModeTailTruncation;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [Config sharedInstance].textColor;
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        label.frame = CGRectMake(20/2.0, 30 , frame.size.width - 20, frame.size.height - 30);
        
        [self addSubview:label];
    }
    return self;
}

@end
