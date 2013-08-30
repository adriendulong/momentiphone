//
//  CreationPage1ViewController.m
//  Moment
//
//  Created by Charlie FANCELLI on 15/10/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "CreationPage1ViewController.h"

#import "Config.h"
#import "VersionControl.h"
#import "TextFieldAutocompletionManager.h"
#import "CreationPage2ViewController.h"

#import "NSMutableAttributedString+FontAndTextColor.h"
#import "UserCoreData+Model.h"
#import "MBProgressHUD.h"
#import "TTTAttributedLabel.h"

#import "UserClass+Server.h"
#import "FacebookManager.h"
#import "WebModalViewController.h"

@interface CreationPage1ViewController () {
    @private
    UIAlertView *fbLoginPopup;
    NSString *facebookId;
}

@end

@implementation CreationPage1ViewController

@synthesize delegate = _delegate;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize imageProfile = _imageProfile;
@synthesize scrollView = _scrollView;

@synthesize boxView = _boxView;
@synthesize bgBox = _bgBox;

@synthesize photoProfil = _photoProfil;
@synthesize photoProfilLabel = _photoProfilLabel;
@synthesize confidentialiteLabel = _confidentialiteLabel;
@synthesize cguLabel = _cguLabel;
@synthesize sublineCGU = _sublineCGU;

@synthesize nomLabel = _nomLabel;
@synthesize prenomLabel = _prenomLabel;
@synthesize emailLabel = _emailLabel;
@synthesize mdpLabel = _mdpLabel;

@synthesize backButton = _backButton;
@synthesize nextButton = _nextButton;

#pragma mark - init & load

- (id)initWithDelegate:(id <HomeViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"CreationPage1ViewController" bundle:nil];
    if(self) {
        self.delegate = delegate;
        facebookId = nil;
    }
    return self;
}

- (void)initDatePicker
{
    // Init
    self.pickerView = [[CustomDatePicker alloc] init];
    self.pickerView.datePicker.datePickerMode = UIDatePickerModeDate;
    // Date Max = Aujourd'hui
    self.pickerView.datePicker.maximumDate = [NSDate date];
    // Bouton Valider
    [self.pickerView setButtonStyle:CustomDatePickerButtonStyleDone];
    
    // Actions
    [self.pickerView setValiderButtonTarget:self action:@selector(clicValiderPickerView)];
    [self.pickerView setDatePickerTarget:self action:@selector(datePickerChangeValue)];
    
    // Date Formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.locale = [NSLocale currentLocale];
    self.dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    self.dateFormatter.calendar = [NSCalendar currentCalendar];
    self.dateFormatter.dateFormat = @"dd'/'MM'/'yyyy";
    
    // Data par défaut
    self.pickerView.datePicker.date = [self.dateFormatter dateFromString:@"01/01/1990"];
    
    // Set InputViews
    self.birthdayTextField.inputView = self.pickerView;
}

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowRadius = 3.0;
    view.layer.shadowOpacity = 1.0;
    view.layer.masksToBounds  = NO;
}

- (void)moveView:(UIView*)view distance:(NSInteger)distance
{
    CGRect frame = view.frame;
    frame.origin.y += distance;
    view.frame = frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Inscription";
    
    // iPhone 4 layout
    if ( ![[VersionControl sharedInstance] isIphone5] )
    {
        // Move & Resize Box
        CGRect frame = self.boxView.frame;
        frame.origin.y = 15;
        frame.size.height -= 15;
        self.boxView.frame = frame;
        
        // Move TextFields
        int margin = -2;
        [self moveView:self.prenomLabel distance:margin];
        [self moveView:self.nomLabel distance:margin-1];
        [self moveView:self.emailLabel distance:margin-2];
        [self moveView:self.mdpLabel distance:margin-3];
        [self moveView:self.birthdayTextField distance:margin-4];
        [self moveView:self.maleButton distance:margin-5];
        [self moveView:self.femaleButton distance:margin-5];
        
        // Move photo
        [self moveView:self.photoProfil distance:margin-13];
        [self moveView:self.photoProfilLabel distance:margin-8];
        
        // Move label
        [self moveView:self.confidentialiteLabel distance:margin - 75];
        [self moveView:self.cguLabel distance:margin - 75];
    }
        
    // Autocomplétion
    self.emailLabel.autocompleteType = TextFieldAutocompletionTypeEmail;
    self.emailLabel.autocompleteDisabled = NO;
    
    // Image de fond
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"login-bg.jpg"]];
    
    // Fond de la box
    UIImage *image = [UIImage imageNamed:@"bg_box_inscription.png"];
    image = [[VersionControl sharedInstance] resizableImageFromImage:image withCapInsets:UIEdgeInsetsMake(15, 5, 5, 5) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    _bgBox = [[UIImageView alloc] initWithImage:image];
    _bgBox.layer.zPosition = -2;
    [_boxView addSubview:_bgBox];
    
    // Resize
    CGRect frame = _bgBox.frame;
    frame.size.height = _boxView.frame.size.height;
    _bgBox.frame = frame;
    
    // Boutons
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:14];
    self.maleButton.titleLabel.font = font;
    self.femaleButton.titleLabel.font = font;
    UIColor *grey = [Config sharedInstance].textColor;
    UIColor *orange = [Config sharedInstance].orangeColor;
    [self.maleButton setTitleColor:grey forState:UIControlStateNormal];
    [self.femaleButton setTitleColor:grey forState:UIControlStateNormal];
    [self.maleButton setTitleColor:orange forState:UIControlStateSelected];
    [self.femaleButton setTitleColor:orange forState:UIControlStateSelected];
    
    // Picker view
    [self initDatePicker];
    
    // Lien CGU
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCGU)];
    [self.confidentialiteLabel addGestureRecognizer:tap];
    [self.cguLabel addGestureRecognizer:tap];
    
    // Labels
    NSString *confidialiteLabelString = self.confidentialiteLabel.text;
    NSString *photoProfilString = self.photoProfilLabel.text;
    NSString *cguString = self.cguLabel.text;
    
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        /* ----------------- CONFIDENTIALITE LABEL ------------------ */
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:confidialiteLabelString];
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:10] range:NSMakeRange(0, 1)];
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:8] range:NSMakeRange(1, [confidialiteLabelString length] -1 )];
        self.confidentialiteLabel.attributedText = attributedString;
        //[self.confidentialiteLabel setAlignment:CLabelAlignmentCenter];
        self.confidentialiteLabel.textAlignment = NSTextAlignmentCenter;
        
        /* ---------------------- CGU LABEL ----------------------- */
        attributedString = [[NSMutableAttributedString alloc] initWithString:cguString];
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:11] range:NSMakeRange(0, 1)];
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:9] range:NSMakeRange(1, [cguString length] -1 )];
        self.cguLabel.attributedText = attributedString;
        //[self.confidentialiteLabel setAlignment:CLabelAlignmentCenter];
        self.cguLabel.textAlignment = NSTextAlignmentCenter;
        
        /* ----------------- PHOTO PROFIL LABEL ------------------ */
        attributedString = [[NSMutableAttributedString alloc] initWithString:photoProfilString];
        UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:12];
        UIFont *smalFont = [[Config sharedInstance] defaultFontWithSize:10];
        
        [attributedString setFont:bigFont range:NSMakeRange(0, 1)];
        [attributedString setFont:smalFont range:NSMakeRange(1, 2)];
        [attributedString setFont:bigFont range:NSMakeRange(3, 1)];
        [attributedString setFont:smalFont range:NSMakeRange(4, 8)];
        [attributedString setFont:bigFont range:NSMakeRange(12, 1)];
        [attributedString setFont:smalFont range:NSMakeRange(13, 5)];
        self.photoProfilLabel.attributedText = attributedString;
        //[self.photoProfilLabel setAlignment:CLabelAlignmentCenter];
        self.photoProfilLabel.textAlignment = NSTextAlignmentCenter;
        
        self.confidentialiteLabel.textColor = [UIColor whiteColor];
        self.photoProfilLabel.textColor = [UIColor whiteColor];
        self.cguLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        Config *cf = [Config sharedInstance];
        
        /* ----------------- CONFIDENTIALITE LABEL ------------------ */
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.confidentialiteLabel.frame];
        
        tttLabel.textAlignment = NSTextAlignmentCenter;        
        tttLabel.textColor = [UIColor whiteColor];
        tttLabel.lineBreakMode = self.confidentialiteLabel.lineBreakMode;
        tttLabel.numberOfLines = self.confidentialiteLabel.numberOfLines;
        [self addShadowToView:tttLabel];
        
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:confidialiteLabelString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSInteger taille = [confidialiteLabelString length];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:10 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:8 onRange:NSMakeRange(1, taille-1 )];
            
            [cf updateTTTAttributedString:mutableAttributedString withColor:[UIColor whiteColor] onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [self.confidentialiteLabel.superview addSubview:tttLabel];
        self.confidentialiteLabel.hidden = YES;
        
        /* ---------------------- CGU LABEL ----------------------- */
        
        tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.cguLabel.frame];
        
        tttLabel.textAlignment = NSTextAlignmentCenter;
        tttLabel.textColor = [UIColor whiteColor];
        tttLabel.lineBreakMode = self.cguLabel.lineBreakMode;
        tttLabel.numberOfLines = self.cguLabel.numberOfLines;
        [self addShadowToView:tttLabel];
        
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:cguString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSInteger taille = [cguString length];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:11 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:9 onRange:NSMakeRange(1, taille-1 )];
            
            [cf updateTTTAttributedString:mutableAttributedString withColor:[UIColor whiteColor] onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [self.cguLabel.superview addSubview:tttLabel];
        self.cguLabel.hidden = YES;
        
        /* ----------------- PHOTO PROFIL LABEL ------------------ */
        
        tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.photoProfilLabel.frame];
        
        tttLabel.textAlignment = NSTextAlignmentCenter;        
        tttLabel.textColor = [UIColor whiteColor];
        tttLabel.lineBreakMode = self.photoProfilLabel.lineBreakMode;
        tttLabel.numberOfLines = self.photoProfilLabel.numberOfLines;
        [self addShadowToView:tttLabel];

        
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:photoProfilString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSInteger bigSize = 12, smallSize = 10;
            NSInteger taille = [photoProfilString length];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange(1, 2)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(3, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange(4, 8)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(12, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange(13, 5)];
            
            [cf updateTTTAttributedString:mutableAttributedString withColor:[UIColor whiteColor] onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [self.photoProfilLabel.superview addSubview:tttLabel];
        self.photoProfilLabel.hidden = YES;
        
        /*
        [self.confidentialiteLabel setAttributedTextFromString:confidialiteLabelString withFontSize:8];
        [self.photoProfilLabel setAttributedTextFromString:photoProfilString withFontSize:12];
         */
    }
    
    
    // Shadows
    [self addShadowToView:self.confidentialiteLabel];
    [self addShadowToView:self.photoProfilLabel];
    [self addShadowToView:self.cguLabel];
    
    // Subline
    self.sublineCGU.backgroundColor = [UIColor whiteColor];
    [self addShadowToView:self.sublineCGU];
    
    // Medallion
    self.photoProfil.image = [UIImage imageNamed:@"picto_tete_avec_fond.png"];
    [self.photoProfil addTarget:self action:@selector(clicPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    // TextFields Font
    font = [[Config sharedInstance] defaultFontWithSize:13];
    self.nomLabel.font = font;
    self.prenomLabel.font = font;
    self.emailLabel.font = font;
    self.mdpLabel.font = font;
    self.birthdayTextField.font = [[Config sharedInstance] defaultFontWithSize:11];
    
    // ------------ FACEBOOK LOGIN POPUP -------------
    fbLoginPopup = [[UIAlertView alloc] initWithTitle:@"Inscription via Facebook"
                                              message:@"Inscrivez-vous à partir de informations Facebook"
                                             delegate:self
                                    cancelButtonTitle:@"Refuser"
                                    otherButtonTitles:@"Accepter", nil];
    [fbLoginPopup show];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNomLabel:nil];
    [self setPrenomLabel:nil];
    [self setEmailLabel:nil];
    [self setMdpLabel:nil];
    [self setPhotoProfil:nil];
    [self setPhotoProfilLabel:nil];
    [self setConfidentialiteLabel:nil];
    [self setBackButton:nil];
    [self setNextButton:nil];
    [self setBgBox:nil];
    [self setBoxView:nil];
    [self setScrollView:nil];
    [self setBirthdayTextField:nil];
    [self setMaleButton:nil];
    [self setFemaleButton:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [AppDelegate updateActualViewController:self];
}

#pragma mark - Validation

- (BOOL)validateForm
{
    if( ([_nomLabel.text length] > 0) &&
       ([_prenomLabel.text length] > 0) &&
       ([_emailLabel.text length] > 0) &&
       ([_mdpLabel.text length] > 0)
       )
    {
        if( ![[Config sharedInstance] isValidEmail:_emailLabel.text] )
        {
            [[[UIAlertView alloc] initWithTitle:@"Email invalide"
                                        message:@"L'adresse email rentrée est invalide"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] 
             show];
            return NO;
        }
        
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Formulaire invalide"
                                message:@"Veuillez remplir tous les champs obligatoires du formulaire"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] 
     show];
    
    return NO;
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if (textField == _prenomLabel) {
        [_nomLabel becomeFirstResponder];
    }
    else if (textField == _nomLabel) {
        [_emailLabel becomeFirstResponder];
    }
    else if (textField == _emailLabel) {
        [_mdpLabel becomeFirstResponder];
    }
    else if(textField == _mdpLabel) {
        [_birthdayTextField becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
        
        // Si on a rempli la photo, on valide automatiquement
        if(self.imageProfile)
            [self clicNext];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    BOOL birthdayIsFull = self.birthdayTextField.text.length > 0;
    
    if( textField == self.birthdayTextField ) {
        
        [self.pickerView setButtonStyle:CustomDatePickerButtonStyleDone];
        
        if(birthdayIsFull) {
            self.pickerView.datePicker.maximumDate = [NSDate date];
        }
        
        // Rénitialise date min
        if(!birthdayIsFull) {
            self.pickerView.datePicker.date = [NSDate date];
            self.pickerView.datePicker.maximumDate = [NSDate date];
            [self.birthdayTextField setText:[self.dateFormatter stringFromDate:[NSDate date]]];
        }
    }
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [[Config sharedInstance] imageWithMaxSize:info[@"UIImagePickerControllerOriginalImage"] maxSize:200];
    
    self.imageProfile = image;
    self.photoProfil.image = self.imageProfile;
    _mdpLabel.returnKeyType = UIReturnKeyDone;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ------- Change Picture ---------
    // -> Choix de la source
    
    // Bouton Annuler
    if(buttonIndex == 2)
        return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    // Bouton Librairie
    if(buttonIndex == 0)
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // Bouton Caméra
    else
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - UIAlertView Delegate -> Login FB

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Login via FB
    if(alertView == fbLoginPopup)
    {
        // Accepter
        if(buttonIndex == 1)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
            
            [[FacebookManager sharedInstance] getCurrentUserInformationsWithEnded:^(UserClass *user) {
                
                if(user)
                {
                    self.nomLabel.text = user.nom;
                    self.prenomLabel.text = user.prenom;
                    self.emailLabel.text = user.email;
                    
                    if(user.sex == UserSexMale) {
                        self.maleButton.selected = YES;
                    }
                    else {
                        self.femaleButton.selected = YES;
                    }
                    
                    if(user.imageString)
                    {
                        [self.photoProfil setImage:nil imageString:user.imageString withSaveBlock:^(UIImage *image_raw) {
                            UIImage *image = [[Config sharedInstance] imageWithMaxSize:image_raw maxSize:200];
                            self.imageProfile = image;
                        }];
                    }
                    facebookId = user.facebookId;
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }
        
    }
}

#pragma mark - clic Actions

- (void)clicPhoto {
        
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"ActionSheet_PeekPhoto_Title", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"ActionSheet_PeekPhoto_Button_Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  NSLocalizedString(@"ActionSheet_PeekPhoto_Button_PhotoLibrary", nil),
                                  NSLocalizedString(@"ActionSheet_PeekPhoto_Button_Camera", nil),
                                  nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
    
}

- (IBAction)toggleSexeButtons:(UIButton*)sender
{
    if(!sender.isSelected)
    {
        if(self.maleButton == sender)
            self.femaleButton.selected = sender.selected;
        else
            self.maleButton.selected = sender.selected;
        
        sender.selected = !sender.selected;
    }
    else {
        sender.selected = !sender.selected;
    }
}

- (IBAction)clicNext {
    
    [_nomLabel resignFirstResponder];
    [_prenomLabel resignFirstResponder];
    [_emailLabel resignFirstResponder];
    [_mdpLabel resignFirstResponder];
    [_birthdayTextField resignFirstResponder];
    
    if([self validateForm])
    {
        // Birthday
        NSNumber *timeStamp = nil;
        if(self.birthdayTextField.text.length > 0) {
            timeStamp = @([self.pickerView.datePicker.date timeIntervalSince1970]);
        }
        
        // Sexe
        NSString *sexe = nil;
        if(self.maleButton.isSelected || self.femaleButton.isSelected)
            sexe = (self.maleButton.isSelected)? @"M" : @"F";
        
        // Params
        NSMutableDictionary *attributes = @{
        @"firstname" : _prenomLabel.text,
        @"lastname" : _nomLabel.text,
        @"email" : _emailLabel.text,
        @"password" : _mdpLabel.text
        }.mutableCopy;
        
        // Date de naissance
        if(timeStamp) {
            attributes[@"birth_date"] = timeStamp;
        }
        
        // Sexe
        if(sexe) {
            attributes[@"sex"] = sexe;
        }
        
        if(_imageProfile)
        {
            // Ajout de la photo à la requete
            attributes[@"photo"] = UIImageJPEGRepresentation(_imageProfile, 0.8);
        }
        
        if(facebookId)
            attributes[@"facebookId"] = facebookId;
        
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         hud.labelText = @"Inscription ...";
        
        [UserClass registerUserWithAttributes:attributes withEnded:^(NSInteger status) {
            
            if (status == 200) {
                UserClass *currentUser = [UserCoreData getCurrentUser];
                [[TextFieldAutocompletionManager sharedInstance] addEmailToFavoriteEmails:currentUser.email];
                
                // Numéro téléphone
                CreationPage2ViewController *page2 = [[CreationPage2ViewController alloc] initWithDelegate:self.delegate];
                [self.navigationController pushViewController:page2 animated:YES];
            }
            else if(status == 405) {
                [[[UIAlertView alloc] initWithTitle:@"Erreur"
                                            message:@"L'utilisateur existe déjà"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]
                 show];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Erreur"
                                            message:@"Une erreur est survenue lors de la connexion. Merci de réessayer ultérieurement."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]
                 show];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            
        }];
        
    }
    
}

- (IBAction)clicPrev {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clicValiderPickerView
{
    [self.birthdayTextField resignFirstResponder];
}

- (void)datePickerChangeValue
{
    self.birthdayTextField.text = [self.dateFormatter stringFromDate:self.pickerView.datePicker.date];
}

- (void)showCGU {
    WebModalViewController *webView = [[WebModalViewController alloc] initWithURL:[NSURL URLWithString:kAppMomentCGU]];
    [self presentViewController:webView animated:YES completion:nil];
}

@end
