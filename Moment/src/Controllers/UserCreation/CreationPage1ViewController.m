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
    
    // iPhone 5 support ==> Layout
    if ( [[VersionControl sharedInstance] screenHeight] == 568 )
    {
        
        // Resize bgBox
        CGRect frame = self.boxView.frame;
        frame.origin.y += 30;
        frame.size.height += 40;
        self.boxView.frame = frame;
        
        // Move TextFields
        int margin = 4;
        [self moveView:self.nomLabel distance:margin+2];
        [self moveView:self.prenomLabel distance:margin+2];
        [self moveView:self.emailLabel distance:margin+2];
        [self moveView:self.mdpLabel distance:margin+2];
        
        // Move photo
        [self moveView:self.photoProfil distance:margin + 20];
        [self moveView:self.photoProfilLabel distance:margin + 15];
        
        // Move label
        [self moveView:self.confidentialiteLabel distance:margin + 55];
        
        // Move Buttons
        [self moveView:self.backButton distance:margin+10];
        [self moveView:self.nextButton distance:margin+10];
        
    }
    
    // Autocomplétion
    self.emailLabel.autocompleteType = TextFieldAutocompletionTypeEmail;
    self.emailLabel.autocompleteDisabled = NO;
    
    //mettre le fond
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"login-bg.jpg"]];
    
    //mettre le fond de la box
    // bg-box.png
    UIImage *image = [UIImage imageNamed:@"bg_box_inscription.png"];
    
    image = [[VersionControl sharedInstance] resizableImageFromImage:image withCapInsets:UIEdgeInsetsMake(15, 5, 5, 5) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    _bgBox = [[UIImageView alloc] initWithImage:image];
    _bgBox.layer.zPosition = -2;
    [_boxView addSubview:_bgBox];
    
    CGRect frame = _bgBox.frame;
    frame.size.height = _boxView.frame.size.height;
    _bgBox.frame = frame;
    
    NSString *confidialiteLabelString = self.confidentialiteLabel.text;
    NSString *photoProfilString = self.photoProfilLabel.text;
    
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        /* ----------------- CONFIDENTIALITE LABEL ------------------ */
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:confidialiteLabelString];
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:10] range:NSMakeRange(0, 1)];
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:8] range:NSMakeRange(1, [confidialiteLabelString length] -1 )];
        self.confidentialiteLabel.attributedText = attributedString;
        //[self.confidentialiteLabel setAlignment:CLabelAlignmentCenter];
        self.confidentialiteLabel.textAlignment = NSTextAlignmentCenter;
        
        
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
        
        [self addShadowToView:self.confidentialiteLabel];
        [self addShadowToView:self.photoProfilLabel];
        
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
    
    
    // Medallion
    self.photoProfil.image = [UIImage imageNamed:@"picto_tete_avec_fond.png"];
    [self.photoProfil addTarget:self action:@selector(clicPhoto) forControlEvents:UIControlEventTouchUpInside];
    
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
                                message:@"Veuillez remplir tous les champs du formulaire"
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
    else{
        [textField resignFirstResponder];
        
        if(self.imageProfile)
            [self clicNext];
    }
    
    return YES;
}


#pragma mark - UIImagePickerController Delegate

-(void) imagePickerController:(UIImagePickerController *)UIPicker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    UIImage *image = [[Config sharedInstance] imageWithMaxSize:info[@"UIImagePickerControllerOriginalImage"] maxSize:600];
    
    self.imageProfile = image;
    self.photoProfil.image = self.imageProfile;
    _mdpLabel.returnKeyType = UIReturnKeyDone;
    
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:UIPicker animated:YES];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
        return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;

    if(buttonIndex == 0)
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    else
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [[VersionControl sharedInstance] presentModalViewController:picker fromRoot:self animated:YES];
    
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
            [[FacebookManager sharedInstance] getCurrentUserInformationsWithEnded:^(UserClass *user) {
                
                if(user)
                {
                    self.nomLabel.text = user.nom;
                    self.prenomLabel.text = user.prenom;
                    self.emailLabel.text = user.email;
                    if(user.imageString)
                    {
                        [self.photoProfil setImage:nil imageString:user.imageString withSaveBlock:^(UIImage *image) {
                            self.imageProfile = image;
                        }];
                    }
                    facebookId = user.facebookId;
                }
                
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

- (IBAction)clicNext {
    
    [_nomLabel resignFirstResponder];
    [_prenomLabel resignFirstResponder];
    [_emailLabel resignFirstResponder];
    [_mdpLabel resignFirstResponder];
    
    if([self validateForm])
    {
        
        NSMutableDictionary *attributes = @{
        @"firstname" : _prenomLabel.text,
        @"lastname" : _nomLabel.text,
        @"email" : _emailLabel.text,
        @"password" : _mdpLabel.text
        }.mutableCopy;
        
        if(_imageProfile)
        {
            // Ajout de la photo à la requete
            attributes[@"photo"] = UIImagePNGRepresentation(_imageProfile);
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

@end
