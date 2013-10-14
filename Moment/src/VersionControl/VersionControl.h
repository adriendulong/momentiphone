//
//  VersionControl.h
//  Moment
//
//  iOS 5.0 & iOS 6.0 Support
//
//  Created by Mathieu PIERAGGI on 06/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TextAlignment {
    TextAlignmentCenter = 0,
    TextAlignmentRight = 1,
    TextAlignmentLeft = 2
};

@interface VersionControl : NSObject

// Singleton
+ (VersionControl*)sharedInstance;

// iPhone 5  Screen Size Support
#define STATUS_BAR_HEIGHT 20
#define NAVIGATION_BAR_HEIGHT 44 
#define TOPBAR_HEIGHT (STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT)
- (CGFloat)screenHeight;
- (CGSize)screenSize;
- (BOOL)isRetina;
- (BOOL)isIphone5;

// Custom Label Support
@property (nonatomic, readonly) BOOL supportIOS7;

- (UIImage*)resizableImageFromImage:(UIImage*)image withCapInsets:(UIEdgeInsets)edge stretchableImageWithLeftCapWidth:(NSInteger)capWidth topCapHeight:(NSInteger)capHeight;

@end
