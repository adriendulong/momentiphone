//
//  HomeViewController.h
//  Moment
//
//  Created by Charlie FANCELLI on 20/09/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCoreData+Model.h"

#import "CustomButton.h"
#import "CustomTextField.h"
#import "IgnoreTouchView.h"

#import "TPKeyboardAvoidingScrollView.h"

@protocol HomeViewControllerDelegate <NSObject>
- (void) entrerDansMomentAnimated:(BOOL)animated;
@end


@interface HomeViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, HomeViewControllerDelegate, UIAlertViewDelegate>

//@property (assign, nonatomic) NSUInteger style;
@property (nonatomic, weak) IBOutlet IgnoreTouchView *boxView;
@property (nonatomic, weak) IBOutlet UIView *logoView;

@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, retain) IBOutlet CustomButton *inscriptionButton;
@property (nonatomic, retain) IBOutlet CustomButton *loginButton;

@property (nonatomic, strong) IBOutlet CustomTextField *loginTextField;
@property (nonatomic, strong) IBOutlet CustomTextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton *forgotPassword;
@property (nonatomic, weak) IBOutlet UIButton *backButton;

@property (nonatomic) BOOL isShowFormLogin;
@property (nonatomic, retain)  UIImageView *bgBox;

@property (nonatomic, strong) UserClass *user;

- (id)initWithXib;

- (void) entrerDansMomentAnimated:(BOOL)animated;
- (void) showLoginForm:(BOOL)isDisplay;

- (IBAction)clicCreateUser;
- (IBAction)clicLogin;
- (IBAction)clicForgotPassword;

@end
