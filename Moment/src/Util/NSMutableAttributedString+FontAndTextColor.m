//
//  NSMutableAttributedString+FontAndTextColor.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "NSMutableAttributedString+FontAndTextColor.h"
#import "VersionControl.h"

@implementation NSMutableAttributedString (FontAndTextColor)

- (void)setFont:(UIFont*)font range:(NSRange)range
{
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setFont:(UIFont*)font
{
    [self setFont:font range:NSMakeRange(0, self.length)];
}

- (void)setTextColor:(UIColor*)color range:(NSRange)range
{
    [self addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)setTextColor:(UIColor *)color
{
    [self setTextColor:color range:NSMakeRange(0, self.length )];
}

@end
