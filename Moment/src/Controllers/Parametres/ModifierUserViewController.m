//
//  ModifierUserViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ModifierUserViewController.h"
#import "Config.h"
#import "UserClass+Server.h"
#import "TextFieldAutocompletionManager.h"
#import "MTStatusBarOverlay.h"
#import "FacebookManager.h"
#import "VoletViewController.h"
#import "ImporterFBViewController.h"

enum PhotoPickerDestination {
    PhotoPickerDestinationCover = 0,
    PhotoPickerDestinationProfilPicture = 1
    };

@interface ModifierUserViewController () {
    @private
    enum PhotoPickerDestination imagePickerDestination;
    
    NSString *newPassword, *oldPassword;
}

@end

@implementation ModifierUserViewController

@synthesize modifications = _modifications, coverImage = _coverImage, profilePictureImage = _profilePictureImage;
@synthesize contentView = _contentView;
@synthesize medallion = _medallion;
@synthesize label1 = _label1, label2 = _label2, label3 = _label3;
@synthesize prenomTextField = _prenomTextField, nomTextField = _nomTextField;
@synthesize emailTextField = _emailTextField, secondEmailTextField = _secondEmailTextField;
@synthesize phoneTextField = _phoneTextField, secondPhoneTextField = _secondPhoneTextField;
@synthesize oldPasswordTextField = _oldPasswordTextField, nouveauPasswordTextField = _nouveauPasswordTextField;
@synthesize adresseTextField = _adresseTextField;
@synthesize backgroundDescriptionView = _backgroundDescriptionView, descriptionTextView = _descriptionTextView;


- (id)initWithDefaults
{
    self = [super initWithNibName:@"ModifierUserViewController" bundle:nil];
    if(self) {
        
        // Navigation Bar
        [CustomNavigationController setBackButtonWithViewController:self];
        [CustomNavigationController setRightBarButtonWithImage:[UIImage imageNamed:@"topbar_valider"] withTarget:self withAction:@selector(clicValider) withViewController:self];
        
        // Modifications effectuées
        self.modifications = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Edition Profil";
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    
    // Content View
    CGSize contentSize = self.contentView.frame.size;
    self.contentView.frame = frame;
    self.contentView.contentSize = contentSize;
    [self.view addSubview:self.contentView];
    
    // Fonts
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:12];
    self.label1.font = font;
    self.label2.font = font;
    self.label3.font = font;
    
    // User
    UserClass *user = [UserCoreData getCurrentUser];
    
    // Medallion
    self.medallion.borderWidth = 3.0;
    self.medallion.defaultStyle = MedallionStyleProfile;
    if(user.uimage || user.imageString) {
        [self.medallion setImage:user.uimage imageString:user.imageString withSaveBlock:nil];
    }
    [self.medallion addTarget:self action:@selector(clicChangeProfilPicture) forControlEvents:UIControlEventTouchUpInside];
    
    // Description
    UIImage *image = [[VersionControl sharedInstance] resizableImageFromImage:self.backgroundDescriptionView.image withCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    self.backgroundDescriptionView.image = image;
    self.descriptionTextView.placeholder = @"Description";
    
    // Préremplissage des champs
    if(user.prenom)
        self.prenomTextField.text = user.prenom;
    if(user.nom)
        self.nomTextField.text = user.nom;
    if(user.email)
        self.emailTextField.text = user.email;
    if(user.secondEmail) {
        self.secondEmailTextField.text = user.secondEmail;
        
        //Décommenter lorsqu'on pourra modifier l'adresse email principale
        /*if (user.secondEmail.length == 0) {
            [self.emailTextField setEnabled:NO];
        } else {
            self.secondEmailTextField.text = user.secondEmail;
        }*/
    }
    if(user.numeroMobile)
        self.phoneTextField.text = user.numeroMobile;
    if(user.secondPhone)
        self.secondPhoneTextField.text = user.secondPhone;
    if(user.descriptionString)
        self.descriptionTextView.text = user.descriptionString;
    //NSLog(@"privacy = %@", user.privacy);
    if(user.privacy != nil) {
        enum UserPrivacy privacy = user.privacy.intValue;
        switch (privacy) {
            case UserPrivacyClosed:
                self.privacyClosedButton.selected = YES;
                break;
                
            case UserPrivacyOpen:
                self.privacyPublicButton.selected = YES;
                break;
                
            case UserPrivacyPrivate:
                self.privacyFriendButton.selected = YES;
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setPrenomTextField:nil];
    [self setNomTextField:nil];
    [self setEmailTextField:nil];
    [self setPhoneTextField:nil];
    [self setAdresseTextField:nil];
    [self setSecondEmailTextField:nil];
    [self setSecondPhoneTextField:nil];
    [self setOldPasswordTextField:nil];
    [self setNouveauPasswordTextField:nil];
    [self setLabel1:nil];
    [self setLabel2:nil];
    [self setLabel3:nil];
    [self setMedallion:nil];
    [self setModifications:nil];
    [self setCoverImage:nil];
    [self setProfilePictureImage:nil];
    [self setBackgroundDescriptionView:nil];
    [self setDescriptionTextView:nil];
    [self setPrivacyTitleLabels:nil];
    [self setPrivacyDetailLabels:nil];
    [self setPrivacyPublicButton:nil];
    [self setPrivacyFriendButton:nil];
    [self setPrivacyClosedButton:nil];
    [super viewDidUnload];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    if(textField == self.prenomTextField)
        [self.nomTextField becomeFirstResponder];
    else if(textField == self.nomTextField)
        [self.phoneTextField becomeFirstResponder];
    else if(textField == self.phoneTextField)
        [self.adresseTextField becomeFirstResponder];
    else if(textField == self.adresseTextField)
        [self.descriptionTextView becomeFirstResponder];
    else if(textField == self.secondEmailTextField)
        [self.secondPhoneTextField becomeFirstResponder];
    else if(textField == self.secondPhoneTextField)
        [self.oldPasswordTextField becomeFirstResponder];
    else if(textField == self.oldPasswordTextField)
        [self.nouveauPasswordTextField becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

// Phone number only
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Save modification
    // Si le textfield a déjà été ajouté, il n'est pas réajouté (NSSet)
    [self.modifications addObject:textField];
    
    if( (textField == self.phoneTextField) || (textField == self.secondPhoneTextField) ) {
        
        BOOL result =  ( (string.length == 0) || [[Config sharedInstance] isNumeric:string] || ([string isEqualToString:@"-"]) || ([string isEqualToString:@" "]) || ([string isEqualToString:@"+"]) );
        
        // Si on a copié-collé un numéro
        if(!result) {
            NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"+- 0123456789"] invertedSet];
            if([string rangeOfCharacterFromSet:characterSet].location == NSNotFound) {
                // Contient que des caratères autorisés
                result = YES;
            }
        }
        
        return result;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self.modifications addObject:textView];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.modifications addObject:textField];
    return YES;
}

#pragma mark - Actions

- (IBAction)clicChangeCover
{
    imagePickerDestination = PhotoPickerDestinationCover;
    [self showPhotoPickerActionSheet];
}

- (void)clicChangeProfilPicture
{
    imagePickerDestination = PhotoPickerDestinationProfilPicture;
    [self showPhotoPickerActionSheet];
}

- (void)showPhotoPickerActionSheet
{
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

- (IBAction)clicValider
{
    // Cacher clavier
    [self.view endEditing:YES];
    
    // Si il y a eu des modifications
    int taille = [self.modifications count];
    if( (taille > 0) || self.coverImage || self.profilePictureImage )
    {
        //NSLog(@"modifications = %@", self.modifications);
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
        
        // --------- Validation des données -------------
        
        NSString *phoneNumber = nil, *secondPhoneNumber = nil;
        BOOL emailOK = NO, secondEmailOK = NO;
        BOOL prenomOK = NO, nomOK = NO;
        UITextField *invalideTextField = nil;
        
        // Si on a modifié le Prénom
        if([self.modifications containsObject:self.prenomTextField])
        {
            // Si le nom n'est pas vide
            if(self.prenomTextField.text.length > 0) {
                prenomOK = YES;
            }
            else {
                invalideTextField = self.prenomTextField;
            }
        }
        
        // Si on a modifié le Nom
        if(!invalideTextField && [self.modifications containsObject:self.nomTextField])
        {
            // Si le nom n'est pas vide
            if(self.nomTextField.text.length > 0) {
                nomOK = YES;
            }
            else {
                invalideTextField = self.nomTextField;
            }
        }
                
        // Si on a modifier le numéro de téléphone
        if(!invalideTextField && [self.modifications containsObject:self.phoneTextField]) {
            
            // Vérification de la validité des données
            if( (self.phoneTextField.text.length == 0) || [[Config sharedInstance] isValidPhoneNumber:self.phoneTextField.text])
            {
                // Mettre sous une forme convenable pour le server
                phoneNumber = [[Config sharedInstance] formatedPhoneNumber:self.phoneTextField.text];
            }
            else {
                invalideTextField = self.phoneTextField;
            }
        }
        
        // Si on a modifié le premier email
        if( !invalideTextField && [self.modifications containsObject:self.emailTextField])
        {
            // Vérification de la validité des données
            if( (self.emailTextField.text.length == 0) || [[Config sharedInstance] isValidEmail:self.emailTextField.text]) {
                emailOK = YES;
            }
            else {
                invalideTextField = self.emailTextField;
            }
        }
        
        // Si on a modifié le second email
        if( !invalideTextField && [self.modifications containsObject:self.secondEmailTextField])
        {
            // Vérification de la validité des données
            if( (self.secondEmailTextField.text.length == 0) || [[Config sharedInstance] isValidEmail:self.secondEmailTextField.text]) {
                secondEmailOK = YES;
            }
            else {
                invalideTextField = self.secondEmailTextField;
            }
        }
        
        // Si on a modifier le second numero de téléphone
        if( !invalideTextField && [self.modifications containsObject:self.secondPhoneTextField])
        {
            // Vérification de la validité des données
            if( (self.secondPhoneTextField.text.length == 0) || [[Config sharedInstance] isValidPhoneNumber:self.secondPhoneTextField.text])
            {
                // Mettre sous une forme convenable pour le server
                secondPhoneNumber = [[Config sharedInstance] formatedPhoneNumber:self.secondPhoneTextField.text];
            }
            else {
                invalideTextField = self.secondPhoneTextField;
            }
        }
        
        // Si on a rentré un mot de passe, il faut que le nouveau et l'ancien soient remplis
        if( !invalideTextField && ((self.nouveauPasswordTextField.text.length > 0) || (self.oldPasswordTextField.text.length > 0) )) {
            if( !((self.nouveauPasswordTextField.text.length > 0) && (self.oldPasswordTextField.text.length > 0) )) {
                invalideTextField = (self.oldPasswordTextField.text.length == 0) ? self.oldPasswordTextField : self.nouveauPasswordTextField;
            }
            else {
                newPassword = self.nouveauPasswordTextField.text;
                oldPassword = self.oldPasswordTextField.text;
            }
        }
            
        // --------- Si les données sont valides ---------
        if(!invalideTextField)
        {
            NSMutableDictionary *modifications = [[NSMutableDictionary alloc] initWithCapacity:taille];
            
            if(prenomOK) {
                [modifications setValue:self.prenomTextField.text forKey:@"prenom"];
            }
            if(nomOK) {
                [modifications setValue:self.nomTextField.text forKey:@"nom"];
            }
            if([self.modifications containsObject:self.adresseTextField]) {
                [modifications setValue:self.adresseTextField.text forKey:@"adresse"];
            }
            if([self.modifications containsObject:self.descriptionTextView]) {
                [modifications setValue:self.descriptionTextView.text forKey:@"description"];
            }
            if(phoneNumber) {
                if (phoneNumber.length == 0 && self.secondPhoneTextField.text.length != 0) {
                    [modifications setValue:self.secondPhoneTextField.text forKey:@"numeroMobile"];
                    [modifications setValue:@"" forKey:@"secondPhone"];
                } else {
                    [modifications setValue:phoneNumber forKey:@"numeroMobile"];
                }
            }
            //Décommenter lorsqu'on pourra modifier l'adresse email principale
            /*if(emailOK) {
                if (self.emailTextField.text.length == 0 && self.secondEmailTextField.text.length != 0) {
                    [modifications setValue:self.secondEmailTextField.text forKey:@"email"];
                    [modifications setValue:@"" forKey:@"secondEmail"];
                } else {
                    [modifications setValue:self.emailTextField.text forKey:@"email"];
                    // Update liste des mails
                    [[TextFieldAutocompletionManager sharedInstance] addEmailToFavoriteEmails:self.emailTextField.text];
                }
            }*/
            if(secondEmailOK) {
                [modifications setValue:self.secondEmailTextField.text forKey:@"secondEmail"];
                // Update liste des mails
                [[TextFieldAutocompletionManager sharedInstance] addEmailToFavoriteEmails:self.secondEmailTextField.text];
            }
            if(secondPhoneNumber) {
                [modifications setValue:secondPhoneNumber forKey:@"secondPhone"];
            }
            if(self.profilePictureImage) {
                [modifications setValue:self.profilePictureImage forKey:@"photo"];
            }
            // Privacy
            if([self.modifications containsObject:@"privacy"]) {
                enum UserPrivacy privacy;
                if(self.privacyFriendButton.isSelected)
                    privacy = UserPrivacyPrivate;
                else if(self.privacyPublicButton.isSelected)
                    privacy = UserPrivacyOpen;
                else
                    privacy = UserPrivacyClosed;
                [modifications setValue:@(privacy) forKey:@"privacy"];
            }
            
            // Manque Cover
            //  ---
            // ...
            //  ---
            
            // Update
            [UserClass updateCurrentUserInformationsOnServerWithAttributes:modifications withEnded:^(BOOL success) {
                
                // Informe user of success
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if(success)
                {
                    
                    // Changement du Mot de passe
                    if(newPassword && oldPassword) {
                        
                        [UserClass changeCurrentUserPassword:newPassword oldPassword:oldPassword withEnded:^(NSInteger status) {
                            
                            switch (status) {
                                    
                                // Changement effectué
                                case 200: {
                                    
                                    // Success
                                    [[MTStatusBarOverlay sharedInstance]
                                     postImmediateFinishMessage:NSLocalizedString(@"ModifierUserViewController_StatusBarMessage_EditSuccess", nil)
                                     duration:1
                                     animated:YES];
                                } break;
                                    
                                // Ancien Mot de passe incorrect
                                case 400: {
                                    [[[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"ModifierUserViewController_WrongPassword_Title", nil)
                                      message:NSLocalizedString(@"ModifierUserViewController_WrongPassword_Message", nil)
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                      otherButtonTitles:nil]
                                     show];
                                }break;
                                    
                                default:
                                    break;
                            }
                            
                            // Update UI
                            if(phoneNumber) {
                                if (phoneNumber.length == 0 && self.secondPhoneTextField.text.length != 0) {
                                    self.phoneTextField.text = self.secondPhoneTextField.text;
                                    self.secondPhoneTextField.text = @"";
                                } else {
                                    self.phoneTextField.text = phoneNumber;
                                }
                            }
                            if(secondPhoneNumber)
                                self.secondPhoneTextField.text = secondPhoneNumber;
                            
                            //Décommenter lorsqu'on pourra modifier l'adresse email principale
                            /*if(emailOK) {
                                if (self.emailTextField.text.length == 0 && self.secondEmailTextField.text.length != 0) {
                                    self.emailTextField.text = self.secondEmailTextField.text;
                                    self.secondEmailTextField.text = @"";
                                }
                            }*/
                            
                            // Save Cover image
                            [[Config sharedInstance] saveNewCoverImage:self.coverImage];
                            
                            // Update Profile
                            [UserCoreData currentUserNeedsUpdate];
                            
                            // Reinit Modifs
                            self.coverImage = nil;
                            self.profilePictureImage = nil;
                            [self.modifications removeAllObjects];
                            
                            // Réinitialiser Mot de passe
                            newPassword = nil;
                            oldPassword = nil;
                            self.nouveauPasswordTextField.text = @"";
                            self.oldPasswordTextField.text = @"";
                            
                        }];
                        
                    }
                    else {
                        [[MTStatusBarOverlay sharedInstance]
                         postImmediateFinishMessage:NSLocalizedString(@"ModifierUserViewController_StatusBarMessage_EditSuccess", nil)
                         duration:1
                         animated:YES];
                        
                        // Update UI
                        if(phoneNumber) {
                            if (phoneNumber.length == 0 && self.secondPhoneTextField.text.length != 0) {
                                self.phoneTextField.text = self.secondPhoneTextField.text;
                                self.secondPhoneTextField.text = @"";
                                
                                //NSLog(@"self.phoneTextField.text = %@", self.secondPhoneTextField.text);
                            } else {
                                self.phoneTextField.text = phoneNumber;
                                
                                //NSLog(@"self.phoneTextField.text = %@", phoneNumber);
                            }
                        }
                        if(secondPhoneNumber)
                            self.secondPhoneTextField.text = secondPhoneNumber;
                        
                        //Décommenter lorsqu'on pourra modifier l'adresse email principale
                        /*if(emailOK) {
                            if (self.emailTextField.text.length == 0 && self.secondEmailTextField.text.length != 0) {
                                self.emailTextField.text = self.secondEmailTextField.text;
                                self.secondEmailTextField.text = @"";
                            }
                         }*/
                        
                        // Save Cover image
                        [[Config sharedInstance] saveNewCoverImage:self.coverImage];
                        
                        // Update Profile
                        [UserCoreData currentUserNeedsUpdate];
                        
                        // Reinit Modifs
                        self.coverImage = nil;
                        self.profilePictureImage = nil;
                        [self.modifications removeAllObjects];
                    }
                    
                }
                else
                {
                    [[MTStatusBarOverlay sharedInstance]
                     postImmediateErrorMessage:NSLocalizedString(@"Error_Classic", nil)
                     duration:1
                     animated:YES];
                }
                
                
            }];
        }
        // Non Valide
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [[[UIAlertView alloc]
              initWithTitle:NSLocalizedString(@"ModifierUserViewController_AlertUnvalide_Title", nil)
              message:NSLocalizedString(@"ModifierUserViewController_AlertUnvalide_Message", nil)
              delegate:nil
              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil) otherButtonTitles:nil]
             show];
            
            // Select invalide textfield
            [invalideTextField becomeFirstResponder];
        }
        
    }
}

- (IBAction)clicFacebookBadge {
    //NSLog(@"GET PERMISSIONS");
    //[[FacebookManager sharedInstance] getPublishPermissions];
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CreationHomeViewController_importFBAlertView_Title", nil)
                                message:NSLocalizedString(@"CreationHomeViewController_importFBAlertView_Message", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_NO", nil)
                      otherButtonTitles:NSLocalizedString(@"AlertView_Button_YES", nil), nil]
     show];
}

- (IBAction)clicPrivacyButton:(UIButton *)sender {
    
    if(sender == self.privacyPublicButton) {
        [self.privacyPublicButton setSelected:YES];
        [self.privacyFriendButton setSelected:NO];
        [self.privacyClosedButton setSelected:NO];
    }
    else if(sender == self.privacyClosedButton) {
        [self.privacyPublicButton setSelected:NO];
        [self.privacyFriendButton setSelected:NO];
        [self.privacyClosedButton setSelected:YES];
    }
    else if(sender == self.privacyFriendButton) {
        [self.privacyPublicButton setSelected:NO];
        [self.privacyFriendButton setSelected:YES];
        [self.privacyClosedButton setSelected:NO];
    }

    if(![self.modifications containsObject:@"privacy"]) {
        [self.modifications addObject:@"privacy"];
    }
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // --- Import FB Alert View ---
    
    // Oui -> Importer
    if(buttonIndex == 1) {
        
        /*
        // Importation
        ImporterFBViewController *fbViewController = [[ImporterFBViewController alloc] initWithTimeLine:nil];
        
        // Remove this view controller
        // -> On pousse le ImportFB View controller et le bouton BACK retournera à la TimeLine
        NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
        //[viewControllers removeLastObject];
        //[viewControllers removeLastObject];
        [viewControllers addObject:fbViewController];
        
        [self.navigationController setViewControllers:viewControllers animated:NO];
         */
        
        // Update Facebook ID
        [[FacebookManager sharedInstance] updateCurrentUserFacebookIdOnServer:nil];
    }
    
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
        return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    // Album photo
    if(buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)UIPicker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    
    switch (imagePickerDestination) {
        case PhotoPickerDestinationProfilPicture:
            self.profilePictureImage = [[Config sharedInstance] imageWithMaxSize:image maxSize:200];
            self.medallion.image = [[Config sharedInstance] imageWithMaxSize:image maxSize:200];
            break;
            
        case PhotoPickerDestinationCover:
            self.coverImage = image;
            break;
    }
    
    [UIPicker dismissViewControllerAnimated:YES completion:nil];
}

@end
