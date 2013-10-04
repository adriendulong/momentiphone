//
//  VersionControl.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "VersionControl.h"

@implementation VersionControl

#pragma mark - Singleton

static VersionControl *sharedInstance = nil;

+ (VersionControl*)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

- (CGFloat)screenHeight {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return screenBounds.size.height;
}

- (CGSize)screenSize {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return screenBounds.size;
}

- (BOOL)isRetina {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && ([[UIScreen mainScreen] scale] > 1.0) );
}

- (BOOL)isIphone5 {
    if(self.screenHeight == 568) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)supportIOS7
{
    NSUInteger version = [[UIDevice currentDevice].systemVersion substringToIndex:1].integerValue;
    
    //NSLog(@"iOS version = %i", version);
    
    return (version >= 7) ? YES : NO;
}

- (UIImage*)resizableImageFromImage:(UIImage*)image withCapInsets:(UIEdgeInsets)edge stretchableImageWithLeftCapWidth:(NSInteger)capWidth topCapHeight:(NSInteger)capHeight
{
    if( [image respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)] ) {
        return [image resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    }
        
    return [[image resizableImageWithCapInsets:edge] stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
}

@end
