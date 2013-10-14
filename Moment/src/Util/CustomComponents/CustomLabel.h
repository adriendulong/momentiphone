//
//  CustomLabel.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 03/10/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomLabel : UILabel

- (void)setAttributedTextFromString:(NSString*)text withAccentuatedLetters:(NSArray*)ranges withFontSize:(CGFloat)fontSize;
- (void)setAttributedTextFromString:(NSString*)text withFontSize:(CGFloat)fontSize;

@end
