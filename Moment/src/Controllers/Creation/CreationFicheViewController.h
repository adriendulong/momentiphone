//
//  CreationFicheViewController.h
//  Moment
//
//  Created by Charlie FANCELLI on 03/10/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCoreData.h"
#import "MomentClass.h"

// Delegate
// -> Utilisé pour retourné la valeur depuis le PlacesViewController
@protocol CreationFicheViewControllerDelegate <NSObject>
@property (nonatomic, strong) NSString *adresseText;
@end

#import "TimeLineViewController.h"
#import "CustomTextField.h"
#import "CustomDatePicker.h"
#import "CustomLabel.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CustomUIImageView.h"
#import "CustomTextView.h"

@interface CreationFicheViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, CreationFicheViewControllerDelegate> {
    @private
    NSInteger viewHeight;
}

@property (nonatomic, weak) UIViewController <TimeLineDelegate> *timeLineViewContoller;

/* ---- Model ---- */
@property (nonatomic, strong) UserClass *user;
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, strong) NSString *nomEvent;
@property (nonatomic, strong) UIImage *coverImage;

/* ---- Global ---- */
@property (nonatomic, weak) IBOutlet UIScrollView *globalScrollView;
@property (nonatomic) NSInteger currentStep;

/* ---- Step 1 ---- */
@property (nonatomic, weak) IBOutlet TPKeyboardAvoidingScrollView *step2ScrollView;
@property (nonatomic, weak) IBOutlet CustomLabel *quandLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *etape1Label;
@property (nonatomic, weak) IBOutlet CustomUIImageView *coverView;
@property (nonatomic, weak) IBOutlet CustomLabel *titreMomentLabel;
@property (nonatomic, weak) IBOutlet UIButton *changerCoverButton;
@property (nonatomic, weak) IBOutlet CustomLabel *changerCoverLabel;
@property (nonatomic, strong) CustomDatePicker *pickerView;
@property (nonatomic, weak) IBOutlet CustomTextField *startDateTextField;
@property (nonatomic, weak) IBOutlet CustomTextField *endDateTextField;
@property (nonatomic, weak) IBOutlet CustomLabel *startDateLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *endDateLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *dateDebut, *dateFin;

/* ---- Step 2 ---- */
@property (nonatomic, weak) IBOutlet TPKeyboardAvoidingScrollView *step1ScrollView;
@property (nonatomic, weak) IBOutlet CustomLabel *ouLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *etape2Label;
@property (nonatomic, weak) IBOutlet CustomTextField *adresseTextField;
@property (nonatomic, weak) IBOutlet CustomTextField *infoLieuTextField;
@property (nonatomic, weak) IBOutlet CustomTextField *hashtagTextField;
@property (nonatomic, weak) IBOutlet CustomLabel *adresseLabel;
@property (nonatomic, strong) NSString *adresseText;
@property (nonatomic, weak) IBOutlet CustomLabel *infoLieuLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *hashtagLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *infoHashtagLabel;
@property (nonatomic, weak) IBOutlet UIButton *switchButton;
@property (nonatomic) BOOL switchControlState;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundDescriptionView;
@property (nonatomic, weak) IBOutlet CustomTextView *descriptionTextView;

- (id)initWithUser:(UserClass*)user withEventName:(NSString*)eventName withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine;
- (id)initWithUser:(UserClass*)user withMoment:(MomentClass*)moment withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine;

@end
