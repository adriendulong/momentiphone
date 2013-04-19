//
//  CropImageUtility.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import <Foundation/Foundation.h>

enum CirleSize {
    CircleSizeFeed = 1,
    CircleSizeProfil = 2
};

@interface CropImageUtility : NSObject

+ (UIImage*)cropImage:(UIImage*)image toSize:(CGSize)size fromPoint:(CGPoint)origin;
+ (UIImage*)cropImageToSquare:(UIImage*)image withCote:(NSInteger)cote;
+ (UIImage*)cropImageToSquare:(UIImage*)image;

+ (UIImage *)makeRoundedImage:(UIImage *) image radius: (float)radius;
+ (UIImage*)makeCircleImage:(UIImage*)image;

// Mask Methode
+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage*)maskForCircleSize:(enum CirleSize)size;
+ (UIImage*)cropImage:(UIImage*)image intoCircle:(enum CirleSize)circleSize;

@end
