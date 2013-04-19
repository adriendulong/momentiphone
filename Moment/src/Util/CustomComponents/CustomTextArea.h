//
//  CustomTextArea.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextArea : UIView

@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)setText:(NSString *)text;
- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)setDelegate:(id<UITextViewDelegate>)delegate;

@end
