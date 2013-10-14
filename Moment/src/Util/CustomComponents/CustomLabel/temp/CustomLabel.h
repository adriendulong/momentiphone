//
//  CustomLabel.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabelProtocol.h"

enum CLabelAlignment {
    CLabelAlignmentCenter = 0,
    CLabelAlignmentLeft = 1,
    CLabelAlignmentRight = 3
};

@interface CustomLabel : UIView {
    @private
    BOOL supportIOS6;
    BOOL loaded;
}

@property (nonatomic, strong) UIView <CustomLabelProtocol> *label;
@property (nonatomic) enum CLabelAlignment alignment;

- (void)setAttributedText:(NSAttributedString*)attributedText;
- (NSAttributedString*)attributedText;

- (void)setText:(NSString*)text;
- (NSString*)text;

- (void)setAttributedTextFromString:(NSString*)text withAccentuatedLetters:(NSArray*)ranges withFontSize:(CGFloat)fontSize;
- (void)setAttributedTextFromString:(NSString*)text withFontSize:(CGFloat)fontSize;

- (void)setFontSize:(CGFloat)size;
+ (NSInteger)getReelAlignment:(enum CLabelAlignment)alignment;

- (void)setAlignment:(enum CLabelAlignment)alignment;

@end
