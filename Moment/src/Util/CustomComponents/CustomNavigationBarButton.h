//
//  CustomNavigationBarButton.h
//  Moment
//
//  Created by SkeletonGamer on 23/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationBarButton : UIButton

@property (nonatomic) BOOL *isLeftButton;

- (id)initWithFrame:(CGRect)frame andIsLeftButton:(BOOL)isLeftButton;

@end
