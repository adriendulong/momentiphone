//
//  CustomDatePicker.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>

enum CustomDatePickerButtonStyle {
    CustomDatePickerButtonStyleNext = 0,
    CustomDatePickerButtonStyleDone = 1
};

@interface CustomDatePicker : UIView

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *validerButton;

- (void)setValiderButtonTarget:(id)target action:(SEL)action;
- (void)setDatePickerTarget:(id)target action:(SEL)action;
- (void)setButtonStyle:(enum CustomDatePickerButtonStyle)style;

@end
