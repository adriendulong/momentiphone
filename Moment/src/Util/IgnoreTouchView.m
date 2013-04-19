//
//  IgnoreTouchView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 13/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "IgnoreTouchView.h"

@implementation IgnoreTouchView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{   
    for (UIView * view in [self subviews]) {
        if (view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return YES;
}

@end
