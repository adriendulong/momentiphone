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
    // Do any additional setup after loading the view from its nib.
    
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
    if(user.secondEmail)
        self.secondEmailTextField.text = user.secondEmail;
    if(user.numeroMobile)
        self.phoneTextField.text = user.numeroMobile;
    if(user.secondPhone)
        self.secondPhoneTextField.text = user.secondPhone;
    if(user.descriptionString)
        self.descriptionTextView.text = user.descriptionString;
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
    [super viewDidUnload];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    if(textField == self.prenomTextField)
        [self.nomTextField becomeFirstResponder];
    else if(textField == self.nomTextField)
        [self.emailTextField becomeFirstResponder];
    else if(textField == self.emailTextField)
        [self.phoneTextField becomeFirstResponder];
    else if(textField == self.phoneTextField)
        [self.adresseTextField becomeFirstResponder];
    else if(textField == self.adresseTextField)
        [self.descriptionTextView becomeFirstResponder];
    else if(textField == self.secondEmailTextField)
        [self.secondPhoneTextField becomeFirstResponder];
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
    
    if( (textField == self.phoneTextField) || (textField == self.secondPhoneTextField) )
        return ( (string.length == 0) || [[Config sharedInstance] isNumeric:string] || ([string isEqualToString:@"-"]) || ([string isEqualToString:@" "]) );
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

- (void)clicValider
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
        
        // Si on a modifié l'email
        if( !invalideTextField && [self.modifications containsObject:self.emailTextField])
        {
            // Vérification de la validité des données --> Ne peux pas être vide
            if([[Config sharedInstance] isValidEmail:self.emailTextField.text]) {
                emailOK = YES;
            }
            else {
                invalideTextField = self.emailTextField;
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
            if(emailOK) {
                [modifications setValue:self.emailTextField.text forKey:@"email"];
                // Update liste des mails
                [[TextFieldAutocompletionManager sharedInstance] addEmailToFavoriteEmails:self.emailTextField.text];
            }
            if([self.modifications containsObject:self.adresseTextField]) {
                [modifications setValue:self.adresseTextField.text forKey:@"adresse"];
            }
            if([self.modifications containsObject:self.descriptionTextView]) {
                [modifications setValue:self.descriptionTextView.text forKey:@"description"];
            }
            if(phoneNumber) {
                [modifications setValue:phoneNumber forKey:@"numeroMobile"];
            }
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
            // Password
            // -> Manque vérification de l'ancien mot de passe
            if([self.modifications containsObject:self.nouveauPasswordTextField]) {
                [modifications setValue:self.nouveauPasswordTextField forKey:@"password"];
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
                    [[MTStatusBarOverlay sharedInstance]
                     postImmediateFinishMessage:NSLocalizedString(@"ModifierUserViewController_StatusBarMessage_EditSuccess", nil)
                     duration:1
                     animated:YES];
                    
                    // Update UI
                    if(phoneNumber)
                        self.phoneTextField.text = phoneNumber;
                    if(secondPhoneNumber)
                        self.secondEmailTextField.text = secondPhoneNumber;
                    
                    // Save Cover image
                    [[Config sharedInstance] saveNewCoverImage:self.coverImage];
                    
                    // Update Profile
                    [UserCoreData currentUserNeedsUpdate];
                    
                    // Reinit Modifs
                    self.coverImage = nil;
                    self.profilePictureImage = nil;
                    [self.modifications removeAllObjects];
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


#pragma mark - UIImagePickerController Delegate

-(void) imagePickerController:(UIImagePickerController *)UIPicker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    UIImage *image = [[Config sharedInstance] imageWithMaxSize:info[@"UIImagePickerControllerOriginalImage"] maxSize:600];
    
    switch (imagePickerDestination) {
        case PhotoPickerDestinationProfilPicture:
            self.profilePictureImage = [[Config sharedInstance] imageWithMaxSize:image maxSize:600];
            self.medallion.image = image;
            break;
            
        case PhotoPickerDestinationCover:
            self.coverImage = image;
            break;
    }
    
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:UIPicker animated:YES];
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
    
    [[VersionControl sharedInstance] presentModalViewController:picker fromRoot:self animated:YES];
}

#pragma mark - Actions

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

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // --- Import FB Alert View ---
    
    // Oui -> Importer
    if(buttonIndex == 1) {
        ImporterFBViewController *fbViewController = [[ImporterFBViewController alloc] initWithTimeLine:nil];
        
        // Remove this view controller
        // -> On pousse le ImportFB View controller et le bouton BACK retournera à la TimeLine
        NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
        //[viewControllers removeLastObject];
        //[viewControllers removeLastObject];
        [viewControllers addObject:fbViewController];
        
        [self.navigationController setViewControllers:viewControllers animated:NO];
    }
    
}

@end
