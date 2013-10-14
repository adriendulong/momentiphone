//
//  UIImage+handling.m
//  Moment
//
//  Created by SkeletonGamer on 26/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UIImage+handling.h"

@implementation UIImage (handling)

+(UIImage *)imageWithImage:(UIImage*)sourceImage scaledToHeight:(float)i_height
{
    float oldWidth = sourceImage.size.width;
    float oldHeight = sourceImage.size.height;
    
    float scaleFactor = i_height / oldHeight;
    
    float newWidth = oldWidth * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
