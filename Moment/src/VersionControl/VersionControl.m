//
//  VersionControl.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "VersionControl.h"

@implementation VersionControl

@synthesize supportIOS6 = _supportIOS6;

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

- (BOOL)isRetina {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && ([[UIScreen mainScreen] scale] > 1.0) );
}

- (BOOL)supportIOS6
{
    if(!_supportIOS6) {
        _supportIOS6 = [[[UILabel alloc] init] respondsToSelector:@selector(setAttributedText:)];
    }
    return _supportIOS6;
}

- (NSInteger)alignment:(enum TextAlignment)align
{
    switch (align) {
            
        case TextAlignmentCenter:
            return (self.supportIOS6)?kCTCenterTextAlignment:NSTextAlignmentCenter;
            break;
            
        case TextAlignmentLeft:
            return (self.supportIOS6)?kCTLeftTextAlignment:NSTextAlignmentLeft;
            break;
            
        case TextAlignmentRight:
            return (self.supportIOS6)?kCTRightTextAlignment:NSTextAlignmentRight;
            break;
            
        default:
            NSLog(@"INVALID ALIGNMENT MODE - VERSION CONTROL");
            return -1;
            break;
    }
}

- (UIImage*)resizableImageFromImage:(UIImage*)image withCapInsets:(UIEdgeInsets)edge stretchableImageWithLeftCapWidth:(NSInteger)capWidth topCapHeight:(NSInteger)capHeight
{
    if( [image respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)] ) {
        return [image resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    }
        
    return [[image resizableImageWithCapInsets:edge] stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
}

- (void)dismissModalViewControllerFromRoot:(UIViewController*)root animated:(BOOL)animated
{
    if ([root respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [root dismissViewControllerAnimated:animated completion:nil];
    }
    else {
        [root dismissModalViewControllerAnimated:animated];
    }
}

- (void)presentModalViewController:(UIViewController*)modal fromRoot:(UIViewController*)root animated:(BOOL)animated
{
    if ([root respondsToSelector:@selector(presentViewController:animated:completion:)]){
        [root presentViewController:modal animated:animated completion:nil];
    }
    else {
        [root presentModalViewController:modal animated:animated];
    }
    
}


@end
