//
//  NSMutableAttributedString+FontAndTextColor.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (FontAndTextColor)

- (void)setFont:(UIFont*)font range:(NSRange)range;
- (void)setFont:(UIFont*)font;

- (void)setTextColor:(UIColor*)color range:(NSRange)range;
- (void)setTextColor:(UIColor *)color;

@end
