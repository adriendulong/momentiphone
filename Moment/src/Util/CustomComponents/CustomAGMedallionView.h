//
//  CustomAGMedallionView.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "AGMedallionView.h"

enum MedallionStyle {
    MedallionStyleProfile = 0,
    MedallionStyleCover = 1
    };

@interface CustomAGMedallionView : AGMedallionView

@property (nonatomic, strong) NSString *imageString;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) BOOL isShinning, isShadow;
@property (nonatomic, strong) UIImage *globalImage;
@property (nonatomic) enum MedallionStyle defaultStyle;

- (void)setImage:(UIImage *)image imageString:(NSString*)imageString withSaveBlock:(void (^)(UIImage *image))block;

@end
