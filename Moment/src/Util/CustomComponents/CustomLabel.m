//
//  CustomLabel.m
//  Moment
//
//  Created by Charlie Mathieu PIERAGGI on 03/10/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "CustomLabel.h"
#import "Config.h"
#import "TTTAttributedLabel.h"
#import "NSMutableAttributedString+FontAndTextColor.h"


@implementation CustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.textAlignment = NSTextAlignmentCenter;
        self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAttributedTextFromString:(NSString*)text withAccentuatedLetters:(NSArray*)ranges withFontSize:(CGFloat)fontSize;
{
    UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:fontSize];
    UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:fontSize+1];
    
    UIColor *orangeColor = [Config sharedInstance].orangeColor;
    UIColor *textColor = [Config sharedInstance].textColor;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    
    //[string setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
    
    [string setTextColor:orangeColor range:NSMakeRange(0, 1)];
    [string setTextColor:textColor range:NSMakeRange(1, [text length]-1)];
    
    [string setFont:bigFont range:NSMakeRange(0, 1)];
    [string setFont:smallFont range:NSMakeRange(1, [text length]-1)];
    
    // Accentuer les lettres à accentuer
    for (NSValue *val in ranges)
    {
        NSRange r = [val rangeValue];
        [string setFont:bigFont range:r];
    }
    
    [self setAttributedText:string];
}

- (void)setAttributedTextFromString:(NSString *)text withFontSize:(CGFloat)fontSize
{
    [self setAttributedTextFromString:text withAccentuatedLetters:nil withFontSize:fontSize];
}



@end
