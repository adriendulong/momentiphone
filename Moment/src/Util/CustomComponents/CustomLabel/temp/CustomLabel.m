//
//  CustomLabel.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomLabel.h"
#import "VersionControl.h"
#import "CustomLabelForIOS5.h"
#import "CustomLabelForIOS6.h"

@implementation CustomLabel

@synthesize label = _label;

- (void)setup
{
    // Identification de la version de l'OS
    supportIOS6 = [[VersionControl sharedInstance] supportIOS6];
    
    // iOS 6
    if( supportIOS6 ) {
        self.label = [[CustomLabelForIOS6 alloc] initWithFrame:self.frame];
    }
    // iOS 5
    else {
        self.label = [[CustomLabelForIOS5 alloc] initWithFrame:self.frame];
    }
    
    self.userInteractionEnabled = NO;
    self.label.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
    
    loaded = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setAttributedText:(NSAttributedString*)attributedText
{    
    if([self.label respondsToSelector:@selector(setAttributedText:)])
        [self.label setAttributedText:attributedText];
    else
        [self.label setText:attributedText.string withFirstLetterColored:YES];
}

- (NSAttributedString*)attributedText
{
    if([self.label respondsToSelector:@selector(attributedText)])
        return self.label.attributedText;
    return [[NSAttributedString alloc] initWithString:self.label.text];
}

- (void)setText:(NSString*)text
{
    if([self.label respondsToSelector:@selector(setText:)])
        [self.label setText:text];
}

- (NSString*)text
{
    if ([self.label respondsToSelector:@selector(text)])
        return self.label.text;
    
    return nil;
}

- (void)setAttributedTextFromString:(NSString*)text withAccentuatedLetters:(NSArray*)ranges withFontSize:(CGFloat)fontSize
{
    if([self.label respondsToSelector:@selector(setAttributedTextFromString:withAccentuatedLetters:withFontSize:)])
        [self.label setAttributedTextFromString:text withAccentuatedLetters:ranges withFontSize:fontSize];
    else {
        [self.label setAttributedTextFromString:text withFontSize:fontSize];
    }
}

- (void)setAttributedTextFromString:(NSString*)text withFontSize:(CGFloat)fontSize
{
    [self.label setAttributedTextFromString:text withFontSize:fontSize];
}

- (void)setFontSize:(CGFloat)size
{
    [self.label setFontSize:size];
}

+ (NSInteger)getReelAlignment:(enum CLabelAlignment)alignment
{
    NSInteger reel;
    
    if( [[VersionControl sharedInstance] supportIOS6] ) {
        switch (alignment) {
            case CLabelAlignmentCenter:
                reel = kCTCenterTextAlignment;
                break;
                
            case CLabelAlignmentLeft:
                reel = kCTLeftTextAlignment;
                break;
                
            case CLabelAlignmentRight:
                reel = kCTRightTextAlignment;
                
            default:
                reel = kCTCenterTextAlignment;
                NSLog(@"Custom Label does not support this alignment mode");
                break;
        }
    }
    else {
        switch (alignment) {
            case CLabelAlignmentCenter:
                reel = UITextAlignmentCenter;
                break;
                
            case CLabelAlignmentLeft:
                reel = UITextAlignmentLeft;
                break;
                
            case CLabelAlignmentRight:
                reel = UITextAlignmentRight;
                
            default:
                reel = UITextAlignmentCenter;
                NSLog(@"Custom Label does not support this alignment mode");
                break;
        }
    }
    
    return reel;
}

- (void)setAlignment:(enum CLabelAlignment)alignment
{
    [self.label setAlignment:[CustomLabel getReelAlignment:alignment] ];    
}

@end
