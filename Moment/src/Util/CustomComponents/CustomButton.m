//
//  CustomButton.m
//  Moment
//
//  Created by Charlie FANCELLI on 01/11/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "CustomButton.h"
//#import "NSMutableAttributedString+FontAndTextColor.h"

@implementation CustomButton

@synthesize label = _label;

- (void) setButtonWithText:(NSString *)text withAccentuatedLetters:(NSArray*)ranges
{
    // On supprime le précédent label si il est déjà alloué
    if(self.label)
    {
        [self.label removeFromSuperview];
        self.label = nil;
    }
    
    // Frame
    CGRect labelFrame = self.frame;
    labelFrame.origin.x = 0;
    labelFrame.origin.y = 0; //fix pour centrer
    
    self.label = [[CustomLabel alloc] initWithFrame:labelFrame];
    [self.label setAttributedTextFromString:text withAccentuatedLetters:ranges withFontSize:14.0f];
    self.label.textAlignment = NSTextAlignmentCenter;
    //[self.label setAlignment:CLabelAlignmentCenter];
    
    /*
    // Label
     //self.label.text = text;
     [self.label setAttributedTextFromString:text withFontSize:14.0f];
    */
    
    [self addSubview:self.label];
}

- (void) setButtonWithText:(NSString *)text{
    [self setButtonWithText:text withAccentuatedLetters:nil];    
}

@end
