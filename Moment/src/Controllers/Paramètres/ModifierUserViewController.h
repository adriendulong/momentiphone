//
//  ModifierUserViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextView.h"
#import "GAITrackedViewController.h"

@interface ModifierUserViewController : GAITrackedViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableSet *modifications;
@property (strong, nonatomic) UIImage *coverImage;
@property (strong, nonatomic) UIImage *profilePictureImage;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *contentView;
@property (weak, nonatomic) IBOutlet CustomAGMedallionView *medallion;

@property (weak, nonatomic) IBOutlet CustomTextField *prenomTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *nomTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *emailTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *adresseTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *secondEmailTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *secondPhoneTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *nouveauPasswordTextField;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundDescriptionView;
@property (weak, nonatomic) IBOutlet CustomTextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

- (id)initWithDefaults;

- (IBAction)clicFacebookBadge;
- (IBAction)clicChangeCover;

@end
