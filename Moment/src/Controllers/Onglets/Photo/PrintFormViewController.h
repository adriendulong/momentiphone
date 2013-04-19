//
//  PrintFormViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "CustomTextField.h"

@interface PrintFormViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *photos;
@property (weak, nonatomic) IBOutlet UIView *bandeauView;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiretLabel;
@property (weak, nonatomic) IBOutlet UILabel *photosSelectionneesLabel;
@property (weak, nonatomic) IBOutlet UILabel *nbPhotosLabel;

@property (weak, nonatomic) IBOutlet CustomTextField *prenomTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *nomTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *adresseTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *codePostalTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *villeTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *paysTextField;

@property (weak, nonatomic) IBOutlet UILabel *facturationLabel;
@property (weak, nonatomic) IBOutlet CustomTextField *emailTextField;

- (id)initWithPhotosToPrint:(NSArray*)photos;

@end
