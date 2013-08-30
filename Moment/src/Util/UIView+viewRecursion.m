//
//  UIView+viewRecursion.m
//  Moment
//
//  Created by SkeletonGamer on 19/08/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UIView+viewRecursion.h"

@implementation UIView (viewRecursion)

- (NSArray *)allSubViews
{
    NSMutableArray *arr = [NSMutableArray array];
    //[arr addObject:self];
    
    for (UIView *subview in self.subviews)
    {
        //[arr addObjectsFromArray:(NSArray*)[subview allSubViews]];
        [arr addObject:subview];
    }
    return arr;
}

@end
