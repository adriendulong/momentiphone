//
//  CustomNavigationBarButton.m
//  Moment
//
//  Created by SkeletonGamer on 23/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomNavigationBarButton.h"

@implementation CustomNavigationBarButton

- (id)initWithFrame:(CGRect)frame andIsLeftButton:(BOOL)isLeftButton
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isLeftButton = isLeftButton;
    }
    return self;
}

- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets;
    if (self.isLeftButton) {
        insets = UIEdgeInsetsMake(0, 10.5f, 0, 0);
    }
    else {
        insets = UIEdgeInsetsMake(0, 0, 0, 10.5f);
    }
    return insets;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
