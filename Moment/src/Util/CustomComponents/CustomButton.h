//
//  CustomButton.h
//  Moment
//
//  Created by Charlie FANCELLI on 01/11/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomLabel.h"

@interface CustomButton : UIButton

@property (nonatomic, strong) CustomLabel *label;

- (void) setButtonWithText:(NSString *)text withAccentuatedLetters:(NSArray*)ranges;
- (void) setButtonWithText:(NSString *)text;

@end
