//
//  Cagnotte1ViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextView.h"

@interface Cagnotte1ViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *parametres;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *bandeauLabel;
@property (nonatomic, weak) IBOutlet UIView *bandeauView;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundDescriptionView;
@property (nonatomic, weak) IBOutlet CustomTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet CustomTextField *beneficiaireTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *titreTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *montantTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *dateFinTextField;

@property (weak, nonatomic) IBOutlet UILabel *choixLabel;
@property (weak, nonatomic) IBOutlet UILabel *cagnotteLabel;
@property (weak, nonatomic) IBOutlet UILabel *cadeauLabel;

- (id)initWithMoment:(MomentClass*)moment;

@end
