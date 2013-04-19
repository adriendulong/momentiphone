//
//  CustomUIImageView.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUIImageView : UIImageView

@property (nonatomic, strong) NSString *imageString;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

- (void)setImage:(UIImage *)image
     imageString:(NSString*)imageString
     placeHolder:(UIImage *)placeHolder
   withSaveBlock:( void (^) (UIImage* image) )block;

- (void)setImage:(UIImage *)image
     imageString:(NSString*)imageString
   withSaveBlock:( void (^) (UIImage* image) )block;

@end
