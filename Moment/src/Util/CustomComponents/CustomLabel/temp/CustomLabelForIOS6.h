//
//  CustomLabelForIOS6.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabelProtocol.h"

@interface CustomLabelForIOS6 : UILabel <CustomLabelProtocol>

- (void)setAttributedTextFromString:(NSString*)text withAccentuatedLetters:(NSArray*)ranges withFontSize:(CGFloat)fontSize;
- (void)setAttributedTextFromString:(NSString*)text withFontSize:(CGFloat)fontSize;

- (void)setAlignment:(NSInteger)alignment;

@end
