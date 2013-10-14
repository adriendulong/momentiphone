//
//  CustomLabelForIOS5.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomLabelProtocol.h"

@interface CustomLabelForIOS5 : UIView  <CustomLabelProtocol>

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) UILabel *firstLetterLabel;
@property (nonatomic, strong) UILabel *otherLettersLabel;
@property (nonatomic) CGFloat firstLetterFontSize;
@property (nonatomic) CGFloat otherLettersFontSize;
@property (nonatomic) NSTextAlignment textAlignment;

- (void)setAttributedTextFromString:(NSString*)text withFontSize:(CGFloat)fontSize;

- (void)setText:(NSString *)text;
- (NSString*)text;

- (void)setAttributedText:(NSAttributedString *)attributedText;

- (void)setAlignment:(NSInteger)alignment;

@end
