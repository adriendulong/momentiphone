//
//  CreationPage1ViewController.h
//  Moment
//
//  Created by Charlie FANCELLI on 15/10/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "HomeViewController.h"
#import "CustomLabel.h"
#import "CustomTextField.h"
#import "CustomAGMedallionView.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface CreationPage1ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <HomeViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImage *imageProfile;
@property (nonatomic, weak) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIView *boxView;
@property (nonatomic, strong) UIImageView *bgBox;

@property (nonatomic, weak) IBOutlet CustomAGMedallionView *photoProfil;
@property (nonatomic, weak) IBOutlet CustomLabel *photoProfilLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *confidentialiteLabel;

@property (nonatomic, weak) IBOutlet CustomTextField *prenomLabel;
@property (nonatomic, weak) IBOutlet CustomTextField *emailLabel;
@property (nonatomic, weak) IBOutlet CustomTextField *mdpLabel;
@property (nonatomic, weak) IBOutlet CustomTextField *nomLabel;

@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

- (id)initWithDelegate:(id <HomeViewControllerDelegate>)delegate;

- (void) clicPhoto;
- (IBAction)clicNext;
- (IBAction)clicPrev;

@end
