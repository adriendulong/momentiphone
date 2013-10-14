//
//  CropImageUtility.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "CropImageUtility.h"

@implementation CropImageUtility

#pragma mark - Crop (Layer Methode)

+ (UIImage*)cropImage:(UIImage*)image toSize:(CGSize)size fromPoint:(CGPoint)origin
{
    // Si les coordonnées de l'image cible sont valides
    //if( (origin.x >= 0) && (origin.x + size.width <= image.size.width) && (origin.y >= 0) && (origin.y + size.height <= image.size.height) )
    //{
        CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
        
        // Create bitmap image from original image data,
        // using rectangle to specify desired crop area
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
        UIImage *img = [UIImage imageWithCGImage:imageRef]; 
        CGImageRelease(imageRef);
        
        return img;
    //}
    //NSLog(@"pop");
    return nil;
}

+ (UIImage*)cropImageToSquare:(UIImage*)image withCote:(NSInteger)cote
{
    // Création du point d'origine du crop ==> on récupère le centre de l'image
    CGFloat scale = [VersionControl sharedInstance].isRetina? 2.0f : 1.0f;
    CGPoint point = CGPointMake( scale*(image.size.width - cote)/(2.0f) , scale*(image.size.height - cote)/(2.0f) );
    
    // Création de la taille cible
    CGSize size = CGSizeMake(scale*cote, scale*cote);
    
    return [CropImageUtility cropImage:image toSize:size fromPoint:point];
}

+ (UIImage*)cropImageToSquare:(UIImage*)image
{
    // Identification coté le plus court
    int cote = image.size.width;
    if(image.size.height < image.size.width)
        cote = image.size.height;
    
    return [CropImageUtility cropImageToSquare:image withCote:cote];
}

#pragma mark - Round Image (Layer Methode)

+ (UIImage *)makeRoundedImage:(UIImage *) image radius: (float)radius
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(image.size);    
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

+ (UIImage*)makeCircleImage:(UIImage*)image
{
    UIImage* square = [self cropImageToSquare:image];
    
    return [CropImageUtility makeRoundedImage:square radius:square.size.width / 2];
}


#pragma mark - Mask Methode

CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage) {
    CGImageRef retVal = NULL;
    
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height,
                                                          8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    if (offscreenContext != NULL) {
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return retVal;
}

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef sourceImage = [image CGImage];
    CGImageRef imageWithAlpha = sourceImage;
    if ((CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNone)
        || (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNoneSkipFirst)
        || (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNoneSkipLast)) {
        imageWithAlpha = CopyImageAndAddAlphaChannel(sourceImage);
    }
    
    CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);
    CGImageRelease(mask);
    
    if (sourceImage != imageWithAlpha) {
        CGImageRelease(imageWithAlpha);
    }
    
    UIImage* retImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    
    return retImage;
}

+ (UIImage*)maskForCircleSize:(enum CirleSize)size
{
    switch (size) {
        case CircleSizeFeed:
            return [UIImage imageNamed:@"mask_medallion_feed"];
            break;
            
        case CircleSizeProfil:
            return [UIImage imageNamed:@"bg_profil_mask"];
            break;
    }
}


+ (CGSize)sizeForCircleSize:(enum CirleSize)size
{
    switch (size) {
        case CircleSizeFeed:
            return CGSizeMake(53, 53);
            break;
            
        case CircleSizeProfil:
            return CGSizeMake(90, 90);
            break;
    }
}

+ (UIImage *)resizeImage:(UIImage*)image resizeSize:(CGSize)resizeSize {
    CGImageRef refImage = image.CGImage;
    CGRect resizedRect = CGRectIntegral(CGRectMake(0, 0, resizeSize.width, resizeSize.height));
    UIGraphicsBeginImageContextWithOptions(resizeSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform vertFlip = CGAffineTransformMake(1, 0, 0, -1, 0, resizeSize.height);
    CGContextConcatCTM(context, vertFlip);
    CGContextDrawImage(context, resizedRect, refImage);
    CGImageRef resizedRefImage = CGBitmapContextCreateImage(context);
    UIImage *resizedImage = [UIImage imageWithCGImage:resizedRefImage];
    CGImageRelease(resizedRefImage);
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

+ (UIImage*)cropImage:(UIImage*)image intoCircle:(enum CirleSize)circleSize
{
    UIImage *mask = [self maskForCircleSize:circleSize];
    UIImage *resized = [self resizeImage:image resizeSize:[self sizeForCircleSize:circleSize]];
    return [self maskImage:resized withMask:mask];
}


@end
