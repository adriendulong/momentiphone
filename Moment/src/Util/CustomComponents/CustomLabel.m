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
        self.textAlignment = [[VersionControl sharedInstance] alignment:TextAlignmentCenter];
        self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAttributedTextFromString:(NSString*)text withAccentuatedLetters:(NSArray*)ranges withFontSize:(CGFloat)fontSize;
{
    if ( [[VersionControl sharedInstance] supportIOS6] )
    {
        UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:fontSize];
        UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:fontSize+1];
        
        UIColor *orangeColor = [[Config sharedInstance] orangeColor];
        UIColor *textColor = [[Config sharedInstance] textColor];
        
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
    else
    {
        NSInteger bigFont = fontSize+1;
        Config *cf = [Config sharedInstance];
        
        CGSize size = [text sizeWithFont:[cf defaultFontWithSize:fontSize+1] ];
        
        CGRect frame = self.frame;
        frame.origin.x = (frame.size.width - size.width)/2.0;
        
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSInteger taille = [text length];
            
            // 1er Lettre Couleur
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.orangeColor onRange:NSMakeRange(0, 1)];
            
            // Autres lettres couleurs
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(1, taille-1)];
            
            // 1er Lettre Majuscule
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigFont onRange:NSMakeRange(0, 1)];
            
            // Autres Lettres Minuscule
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:fontSize onRange:NSMakeRange(1, taille-1 )];

            
            // Accentuer les lettres à accentuer
            for (NSValue *val in ranges)
            {
                NSRange r = [val rangeValue];
                [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:r];
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigFont onRange:r];
            }
            
            
            return mutableAttributedString;
        }];
        
        [self addSubview:tttLabel];
        self.textAlignment = NSTextAlignmentCenter;
        self.text = nil;
        
        /*
         self.text = text;
         self.textColor = [[Config sharedInstance] textColor];
         self.font = [[Config sharedInstance] defaultFontWithSize:fontSize];
         */
    }
}

- (void)setAttributedTextFromString:(NSString *)text withFontSize:(CGFloat)fontSize
{
    [self setAttributedTextFromString:text withAccentuatedLetters:nil withFontSize:fontSize];
}



@end
