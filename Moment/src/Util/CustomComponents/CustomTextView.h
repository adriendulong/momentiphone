//
//  CustomTextView.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextView : UITextView {
    NSInteger paddingLeft;
    NSInteger paddingTop;
}

@property(nonatomic) NSInteger paddingLeft;
@property(nonatomic) NSInteger paddingTop;

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
