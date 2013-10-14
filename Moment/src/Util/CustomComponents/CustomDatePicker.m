//
//  CustomDatePicker.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "CustomDatePicker.h"

@implementation CustomDatePicker

- (void)setupFromNibName
{
    // Load from Xib
    NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"CustomDatePicker" owner:self options:nil];
    [self addSubview:screens[0]];
    
    self.frame = CGRectMake(0,0,320,260);
    self.datePicker.locale = [NSLocale currentLocale];
    self.datePicker.calendar = [NSCalendar currentCalendar];
    self.datePicker.timeZone = [NSTimeZone systemTimeZone];
}

- (void)setValiderButtonTarget:(id)target action:(SEL)action
{
    [self.validerButton setTarget:target];
    [self.validerButton setAction:action];
}

- (void)setDatePickerTarget:(id)target action:(SEL)action
{
    [self.datePicker addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}

- (void)setButtonStyle:(enum CustomDatePickerButtonStyle)style
{
    switch (style) {
        case CustomDatePickerButtonStyleNext:
            self.validerButton.style = UIBarButtonItemStyleBordered;
            self.validerButton.title = @"Suivant";
            break;
            
        case CustomDatePickerButtonStyleDone:
            self.validerButton.style = UIBarButtonItemStyleDone;
            self.validerButton.title = @"Valider";
            break;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupFromNibName];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self) {
        [self setupFromNibName];
    }
    return self;
}

@end
