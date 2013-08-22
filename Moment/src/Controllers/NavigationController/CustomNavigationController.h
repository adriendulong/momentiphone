//
//  CustomNavigationController.h
//  Moment
//
//  Created by Charlie FANCELLI on 28/06/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController

+ (void)setTitle:(NSString *)title withColor:(UIColor *)color withViewController:(UIViewController *)viewController;

+ (void)setBackButtonWithViewController:(UIViewController *)viewController;
+ (void)setBackButtonWithImage:(UIImage *)img withViewController:(UIViewController *)viewController withSelector:(SEL)selector andWithTarget:(id)target;
+ (void)setBackButtonWithTitle:(NSString *)title andColor:(UIColor *)color andFont:(UIFont *)font withViewController:(UIViewController *)viewController  withSelector:(SEL)selector andWithTarget:(id)target;

+ (void)customNavBarWithTitle:(NSString *)title withColor:(UIColor *)color withViewController:(UIViewController *)viewController;
+ (void)customNavBarWithLogo:(UIImage*)logo withViewController:(UIViewController *) viewController;

+ (void)setRightBarButtonWithImage:(UIImage*)image withTarget:(id)target withAction:(SEL)action withViewController:(UIViewController*)viewController;

@end
