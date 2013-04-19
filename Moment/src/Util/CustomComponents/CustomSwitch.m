//
//  CustomSwitch.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomSwitch.h"

@implementation CustomSwitch

- (void)setup {
    [self setTrackImage:[UIImage imageNamed:@"switch_track"]];
    UIImage *thumb = [UIImage imageNamed:@"switch_toggler"];
    [self setThumbImage:thumb];
    [self setThumbHighlightImage:thumb];
    UIImage *mask = [UIImage imageNamed:@"switch_mask"];
    [self setTrackMaskImage:mask];
    [self setThumbMaskImage:mask];
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

@end
