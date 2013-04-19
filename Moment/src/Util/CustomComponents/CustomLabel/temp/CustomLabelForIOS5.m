//
//  CustomLabelForIOS5.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomLabelForIOS5.h"
#import "Config.h"
#import "CustomLabel.h"

static NSInteger paddingLeft = 5;
static NSInteger paddingRight = 5;

@implementation CustomLabelForIOS5

@synthesize string = _string;
@synthesize firstLetterLabel = _firstLetterLabel;
@synthesize otherLettersLabel = _otherLettersLabel;
@synthesize firstLetterFontSize = _firstLetterFontSize;
@synthesize otherLettersFontSize = _otherLettersFontSize;
@synthesize textAlignment = _textAlignment;

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    self.firstLetterLabel = [[UILabel alloc] init];
    self.otherLettersLabel = [[UILabel alloc] init];
    self.firstLetterFontSize = 18.0f;
    self.otherLettersFontSize = 14.0f;
    self.firstLetterLabel.backgroundColor = [UIColor clearColor];
    self.otherLettersLabel.backgroundColor = [UIColor clearColor];
    self.otherLettersLabel.textColor = [[Config sharedInstance] textColor];
    self.textAlignment = [CustomLabel getReelAlignment:CLabelAlignmentCenter];
    
    [self addSubview:self.firstLetterLabel];
    [self addSubview:self.otherLettersLabel];
}

- (id)initWithFrame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setAttributedTextFromString:(NSString *)text withFontSize:(CGFloat)fontSize
{
    [self setText:text withFirstLetterColored:YES];
    [self setFontSize:fontSize];
}

- (void)updateFonts
{
    UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:self.firstLetterFontSize];
    UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:self.otherLettersFontSize];
    
    // Calcul taille label 1
    CGFloat firstLetterMaxWidht = self.frame.size.width/3.0;
    CGSize firstSize = [self.firstLetterLabel.text sizeWithFont:bigFont constrainedToSize:CGSizeMake(firstLetterMaxWidht, self.frame.size.height)];
    
    // Calcul espacement
    CGFloat espacement = 1;
    
    // Calcul taille label 2
    CGSize otherSize = [self.otherLettersLabel.text sizeWithFont:smallFont constrainedToSize:CGSizeMake(self.frame.size.width - firstSize.width, self.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    
    // Calcul positions
    CGFloat startX1;
    CGFloat startY1 = (self.frame.size.height - firstSize.height)/2.0f;
    CGFloat startX2;
    CGFloat startY2 = (self.frame.size.height - otherSize.height)/2.0f;
    switch( self.textAlignment )
    {
        case UITextAlignmentCenter:
            startX1 = ( self.frame.size.width - (firstSize.width + espacement + otherSize.width) )/2.0f;
            startX2 = startX1 + firstSize.width + espacement;
            break;
            
        case UITextAlignmentLeft:
            startX1 = paddingLeft;
            startX2 = startX1 + firstSize.width + espacement;
            break;
            
        case UITextAlignmentRight:
            startX1 = self.frame.size.height - paddingRight - firstSize.width - otherSize.width - espacement;
            startX2 = startX1 + firstSize.width + espacement;
            break;
            
        default:
            startX1 = ( self.frame.size.width - (firstSize.width + espacement + otherSize.width) )/2.0f;
            startX2 = startX1 + firstSize.width + espacement;
            NSLog(@"Custom Label Does Not Support This Alignment Mode");
            break;
    }
    
    
    // Construction label 1
    self.firstLetterLabel.font = bigFont;
    self.firstLetterLabel.frame = CGRectMake(startX1, startY1, firstSize.width, firstSize.height);
    
    // Construction label 2
    self.otherLettersLabel.font = smallFont;
    self.otherLettersLabel.frame = CGRectMake(startX2, startY2, otherSize.width, otherSize.height);
}

- (void)setText:(NSString*)text withFirstLetterColored:(BOOL)colored
{
    self.string = text;
    
    self.firstLetterLabel.text = [text substringWithRange:NSMakeRange(0, 1)];
    self.otherLettersLabel.text = [text substringWithRange:NSMakeRange(1, [text length]-1)];
    
    self.firstLetterLabel.textColor = colored?[[Config sharedInstance] orangeColor] : [[Config sharedInstance] textColor];
    
    [self updateFonts];
}

- (void)setText:(NSString *)text
{
    [self setText:text withFirstLetterColored:NO];
}

- (NSString*)text
{
    return self.string;
}

- (void)setFontSize:(CGFloat)size
{
    self.otherLettersFontSize = size;
    self.firstLetterFontSize = size + 4.0f;
    
    [self updateFonts];
}

- (void)setAlignment:(NSInteger)alignment {
    [self setTextAlignment:alignment];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    NSLog(@"set Text Alignement iOS 5 : %d", textAlignment);
    _textAlignment = textAlignment;
    [self updateFonts];
}

@end
