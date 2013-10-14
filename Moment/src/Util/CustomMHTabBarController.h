//
//  CustomMHTabBarController.h
//  BestComparator.com
//
//  Created by Mathieu PIERAGGI on 29/06/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTabBarController.h"
#import "VariableStore.h"

@interface CustomMHTabBarController : MHTabBarController

@property (nonatomic, strong) UIColor *selectedTitleColor;

- (UIImage *)createButtonImage;
- (UIImage *)createIndicatorImage;

@end
