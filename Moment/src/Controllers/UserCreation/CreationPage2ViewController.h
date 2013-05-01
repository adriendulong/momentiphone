//
//  CreationPage2ViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface CreationPage2ViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id <HomeViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (nonatomic, strong) UIImageView *bgBox;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel1, *descriptionLabel2;
@property (weak, nonatomic) IBOutlet CustomTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *boutonValider;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

- (id)initWithDelegate:(id <HomeViewControllerDelegate>)delegate;

@end
