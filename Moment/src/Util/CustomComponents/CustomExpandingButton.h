//
//  CustomExpandingButton.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "RNExpandingButtonBar.h"
#import "UserCoreData+Model.h"

@interface CustomExpandingButton : RNExpandingButtonBar {
    @private
    NSInteger startPositionExpandingButton;
    NSInteger heightExpandingButton;
}

@property (nonatomic, strong) UIButton *firstButton;
@property (nonatomic, strong) UIButton *secondButton;

@property (nonatomic, strong) UIImage *styloImage;
@property (nonatomic, strong) UIImage *validImage;
@property (nonatomic, strong) UIImage *refusedImage;
@property (nonatomic, strong) UIImage *waitingImage;

@property (nonatomic, strong) UIImageView *fondBlanc;
@property (nonatomic, readonly) BOOL isShowed;

- (id)initWithDelegate:(NSObject<RNExpandingButtonBarDelegate> *)delegate withState:(enum UserState)state;

- (NSArray*)orderButtonsWithState:(enum UserState)state;

@end
