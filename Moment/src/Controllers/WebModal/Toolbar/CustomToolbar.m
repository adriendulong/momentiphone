//
//  CustomToolbar.m
//  Moment
//
//  Created by SkeletonGamer on 22/08/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomToolbar.h"

@implementation CustomToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *image = [UIImage imageNamed:@"topbar-bg.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}


@end
