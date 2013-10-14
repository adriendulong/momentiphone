//
//  CustomLabelForIOS6.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomLabelForIOS6.h"
#import "Config.h"
#import "NSMutableAttributedString+FontAndTextColor.h"

@implementation CustomLabelForIOS6

- (void)setup {
    self.textAlignment = kCTTextAlignmentCenter;
    self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.backgroundColor = [UIColor clearColor];
}

- (id)init
{
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size
{
    self.font = [[Config sharedInstance] defaultFontWithSize:size];
}

- (void)setAttributedTextFromString:(NSString*)text withAccentuatedLetters:(NSArray*)ranges withFontSize:(CGFloat)fontSize;
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    
    //[string setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
    
    [string setTextColor:[[Config sharedInstance] orangeColor] range:NSMakeRange(0, 1)];
    [string setTextColor:[[Config sharedInstance] darkTextColor] range:NSMakeRange(1, [text length]-1)];
    
    UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:fontSize+1];
    
    [string setFont:bigFont range:NSMakeRange(0, 1)];
    [string setFont:[[Config sharedInstance] defaultFontWithSize:fontSize] range:NSMakeRange(1, [text length]-1)];
    
    // Accentuer les lettres à accentuer
    for (NSValue *val in ranges)
    {
        NSRange r = [val rangeValue];
        [string setFont:bigFont range:r];
        [string setTextColor:[UIColor colorWithHex:0x536060] range:r];
    }
    
    [self setAttributedText:string];
}

- (void)setAttributedTextFromString:(NSString *)text withFontSize:(CGFloat)fontSize
{
    [self setAttributedTextFromString:text withAccentuatedLetters:nil withFontSize:fontSize];
}

- (void)setAlignment:(NSInteger)alignment {
    NSLog(@"set alignment iOS 6");
    [self setTextAlignment:alignment];
}


@end
