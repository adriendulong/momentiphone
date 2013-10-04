//
//  HomeViewController.m
//  Moment
//
//  Created by Charlie FANCELLI on 20/09/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "HomeViewController.h"

#import "Config.h"
#import "VersionControl.h"
#import "AFMomentAPIClient.h"
#import "TextFieldAutocompletionManager.h"
#import "PushNotificationManager.h"

#import "RootTimeLineViewController.h"
#import "RootTimeLineViewController.h"
#import "CustomNavigationController.h"
#import "CreationPage1ViewController.h"
#import "VoletViewController.h"

#import "UserCoreData+Model.h"
#import "UserClass+Server.h"
#import "MomentCoreData+Model.h"
#import "MomentClass+Server.h"

#import "CreationPage2ViewController.h"
#import "MTStatusBarOverlay.h"
#import "MBProgressHUD.h"
#import "DeviceModel.h"

#import "TutorialViewController.h"
#import "GAI.h"
#import "FacebookManager.h"
#import "UIImage+handling.h"

@interface HomeViewController ()
@end

static UIImageView *splashScreen = nil;

@implementation HomeViewController

@synthesize boxView = _boxView;
@synthesize logoView = _logoView;

@synthesize inscriptionButton = _inscriptionButton;
@synthesize loginButton = _loginButton;

@synthesize scrollView = _scrollView;
@synthesize forgotPassword = _forgotPassword;

@synthesize loginTextField = _loginTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize backButton = _backButton;

@synthesize isShowFormLogin = _isShowFormLogin;
@synthesize bgBox = _bgBox;

@synthesize user = _user;

#pragma mark - Init & load

- (id)initWithXib
{
    self = [super initWithNibName:@"HomeViewController" bundle:nil];
    if(self) {
        _isShowFormLogin = NO;
        
        [self initAllComponents];
    }
    return self;
}


#pragma mark - placement

- (void)moveView:(UIView*)view toYPosition:(NSInteger)position
{
    view.frame = CGRectMake(view.frame.origin.x, position, view.frame.size.width, view.frame.size.height);
}

- (void) placerHauteurView:(UIView *)view after:(UIView *)before withMargin:(NSInteger) margin{
    [self moveView:view toYPosition:(before.frame.origin.y + before.frame.size.height + margin)];
}

- (void) caculateHeightBox {
    //calcul de la nouvelle taille de la boxViex
    CGRect frame = _boxView.frame;
    frame.size.height = _loginButton.frame.size.height + _loginButton.frame.origin.y + 10;
    _boxView.frame = frame;    
    _bgBox.frame = CGRectMake(0, 0, _boxView.frame.size.width, _boxView.frame.size.height);
}

#pragma mark - View cycle life

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Actual View Controller
    [AppDelegate updateActualViewController:self];
    
    //Premier lancement de l'application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasRunOnce = [defaults boolForKey:@"hasRunOnce"];
    //NSLog(hasRunOnce ? @"Yes" : @"No");
    if (!hasRunOnce)
    {
        [self showTutorialAnimated:YES];
    }
    
    if ([VersionControl sharedInstance].supportIOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                    animated:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //on check si autologin actif et utilisateur fourni
    UserClass *currentUser = [UserCoreData getCurrentUserWithLocalOnly:YES];
    if( currentUser ){
        
        //NSLog(@"currentUser = %@", currentUser);
        
        // Si un cookie de connexion existe, on le charge et on logue le user
        [[AFMomentAPIClient sharedClient] checkConnexionCookieWithEnded:^{
            [self entrerDansMomentAnimated:NO];
        }];
    }
    // Login Manuel
    else {
        
        // Si on doit se déconnecter -> se déconnecter
        // --> Est appelé si il y a eu une erreur lors de la déconnexion
        // --> Force déconnexion du server pour ne pas recevoir de push notifications alors qu'on est déconnecté
        if([DeviceModel deviceShouldLogout]) {
            [DeviceModel logout];
        }
        
        // Connexion manuelle -> Cacher SplashScreen
        [UIView animateWithDuration:1 animations:^{
            splashScreen.alpha = 0;
        } completion:^(BOOL finished) {
            [HomeViewController hideSplashScreen];
        }];
    }
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showSplashScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initAllComponents
{
    // iPhone 5 support
    NSInteger allElementsHeight =  (self.boxView.frame.origin.y + self.boxView.frame.size.height) - self.logoView.frame.origin.y;
    NSInteger espacementTop = ([[VersionControl sharedInstance] screenHeight] - allElementsHeight)/2.0;
    NSInteger espacementMiddle = self.boxView.frame.origin.y - (self.logoView.frame.origin.y + self.logoView.frame.size.height);
    NSInteger espacementBouton = self.backButton.frame.origin.y - self.boxView.frame.origin.y;
    
    // Autocomplete TextField
    self.loginTextField.autocompleteType = TextFieldAutocompletionTypeEmail|TextFieldAutocompletionTypeEmailFavoris;
    self.loginTextField.autocompleteDisabled = NO;
    
    // Move
    [self moveView:self.logoView toYPosition:espacementTop];
    [self moveView:self.boxView toYPosition:(espacementTop + self.logoView.frame.size.height + espacementMiddle)];
    [self moveView:self.backButton toYPosition:(self.boxView.frame.origin.y + espacementBouton)];
    
    // Init
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    _scrollView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    // Texte du bouton Inscription
    [_inscriptionButton setButtonWithText:NSLocalizedString(@"HomeViewController_InscriptionButtonLabel", nil)];
    
    // Texte du bouton Login   ==>  On accentue le 'C'
    //NSArray *ranges = @[[NSValue valueWithRange:NSMakeRange(3, 1)]];
    [_loginButton setButtonWithText:NSLocalizedString(@"HomeViewController_LoginButtonLabel", nil)];
    
    
    // top bar
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = img;
    
    //mettre le fond
    UIImage *backGround = [UIImage imageNamed:@"login-bg"];
    
    if ([VersionControl sharedInstance].supportIOS7) {
        
        if ([VersionControl sharedInstance].isIphone5) {
            backGround = [UIImage imageWithImage:backGround scaledToHeight:[VersionControl sharedInstance].screenHeight];
        }
    }
    //NSLog(@"login-bg = %@", NSStringFromCGSize(backGround.size));
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:backGround];
    
    //mettre le fond de la box
    UIImage *image = [UIImage imageNamed:@"bg-box.png"];
    //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 5, 5)];
    
    image = [[VersionControl sharedInstance] resizableImageFromImage:image withCapInsets:UIEdgeInsetsMake(15, 5, 5, 5)  stretchableImageWithLeftCapWidth:0 topCapHeight:15];
    
    _bgBox = [[UIImageView alloc] initWithImage:image];
    _bgBox.layer.zPosition = -2;
    [_boxView addSubview:_bgBox];
    
    //on resize la box
    [self caculateHeightBox];
}

- (void)showSplashScreen
{
    // ---------- Splash Screen Imitation ---------
    // On affiche le SpashScreen par dessus la vue pour de pas afficher la vue de connexion si il y a une connexion automatique
    
    UIImage *splashImage = [UIImage imageNamed:@"SplashScreen"];
    //NSLog(@"splashImage.size = %@", NSStringFromCGSize(splashImage.size));
    
    if ([VersionControl sharedInstance].isIphone5) {
        splashImage = [UIImage imageWithImage:splashImage scaledToHeight:[VersionControl sharedInstance].screenHeight];
    }
    
    
    /*if([VersionControl sharedInstance].isIphone5) {
     splashImage = [UIImage imageNamed:@"Default.png"];
     } else {
     splashImage = [UIImage imageNamed:@"Default"];
     }*/
    
    CGSize screenSize = [VersionControl sharedInstance].screenSize;
    
    splashScreen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    CGRect frame = splashScreen.frame;
    
    if (![VersionControl sharedInstance].supportIOS7) {
        frame.origin = CGPointMake(0, -STATUS_BAR_HEIGHT);/*
        frame.origin = CGPointMake(0, 0);
    } else {
        frame.origin = CGPointMake(0, -STATUS_BAR_HEIGHT);*/
    }
    splashScreen.frame = frame;
    
    //NSLog(@"splashScreen.frame = %@", NSStringFromCGRect(splashScreen.frame));
    
    
    
    
    [splashScreen setImage:splashImage];
    
    [self.view addSubview:splashScreen];
    
    
}

- (void)reinit
{
    [self showLoginForm:NO];
    self.loginTextField.text = @"";
    self.passwordTextField.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Si on s'est connecté, on réinitialise les champs de connection
    if(self.isShowFormLogin)
       [self reinit];
}

+ (void)hideSplashScreen {
    if(splashScreen) {
        [splashScreen removeFromSuperview];
        splashScreen = nil;
    }
}

#pragma mark - Show Views
- (void)showTutorialAnimated:(BOOL)animated
{
    TutorialViewController *tutorial = [[TutorialViewController alloc] initWithXib];
    //self.definesPresentationContext = YES;
    //[tutorial setModalPresentationStyle:UIModalPresentationFullScreen];
    //tutorial.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if (![VersionControl sharedInstance].supportIOS7) {
        [tutorial setWantsFullScreenLayout:YES];
    }
    [self.navigationController presentViewController:tutorial animated:animated completion:nil];
}

- (void)entrerDansMomentAnimated:(BOOL)animated {
    
    // Loading
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading_Moments", nil);
    
    // --------- Block de création de l'interface
    typedef void (^InterfaceBlock) (void);
    InterfaceBlock interface = [^{
        
        /* ------ Local Notifications Subscribe ------- */
        [[PushNotificationManager sharedInstance] addNotificationObservers];
        
        
        /* ----------------- TIMELINE ----------------- */
        // create the content view controller
        RootTimeLineViewController *timeLineRoot = [[RootTimeLineViewController alloc]
                                                    initWithUser:[UserCoreData getCurrentUser]
                                                    //withSize:CGSizeMake(320, [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT)
                                                    withSize:CGSizeMake(320, [VersionControl sharedInstance].screenHeight)
                                                    withStyle:TimeLineStyleComplete
                                                    withNavigationController:nil
                                                    shouldReloadMoments:(!animated)
                                                    shouldLoadEventsFromFacebook:NO];
        
        
        // Navigation controller
        CustomNavigationController *navController = [[CustomNavigationController alloc] initWithRootViewController:timeLineRoot];
        
        navController.view.frame = CGRectMake(0, 0, 320, [[VersionControl sharedInstance] screenHeight] );
        
        /* ------------------ DDMENU ------------------- */
        // create a DDMenuController setting the content as the root
        DDMenuController *menuController = [[DDMenuController alloc] initWithRootViewController:navController];
        timeLineRoot.ddMenuViewController = menuController;
        
        // set the left view controller property of the menu controller
        VoletViewController *leftController = [[VoletViewController alloc]
                                               initWithDDMenuDelegate:menuController
                                               withRootTimeLine:timeLineRoot];
        menuController.leftViewController = leftController;
        menuController.delegate = leftController;
        
        /* ------------------- PUSH ------------------- */
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        // Afficher Status bar
        /*
        if([[UIApplication sharedApplication] isStatusBarHidden]) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [UIApplication sharedApplication].keyWindow.frame=CGRectMake(0, STATUS_BAR_HEIGHT, 320, [VersionControl sharedInstance].screenHeight - STATUS_BAR_HEIGHT);
        }
         */
        // Push
        [self.navigationController pushViewController:menuController animated:animated];
        
        
    } copy];
    
    
    // --------- Connection automatique
    if(!animated)
    {
        // On affiche la timeline avant et on charge les moments en local avant de charger le reste
        interface();
    }
    else {
        // Chargement
        
        // Si Connexion Facebook, Récupération des Events Facebook
        /*NSString *fbId = [[UserCoreData getCurrentUser] facebookId];
        if(fbId && (fbId.intValue != 0) && [[FacebookManager sharedInstance] facebookIsConnected]) {
            [MomentClass importFacebookEventsWithEnded:nil];
        }*/
        
        // Récupération des moments
        [MomentClass getMomentsServerWithEnded:^(BOOL success) {
            
            if(success) {
                
                interface();
                
            }else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HomeViewController_AlertView_LoadMomentsFail_Title", nil)
                                            message:NSLocalizedString(@"HomeViewController_AlertView_LoadMomentsFail_Message", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                  otherButtonTitles:nil]
                 show];
            }
            
        }];
        
    }
}

- (void) showLoginForm:(BOOL)isDisplay{
    
    // ---- Show ----
    if( isDisplay ){
        _isShowFormLogin = YES;
        _backButton.enabled = YES;

        //on ajoute les textfield
        _loginTextField.alpha = 0;
        _passwordTextField.alpha = 0;
        _forgotPassword.alpha = 0;
                
        // Placement LoginTextField
        CGRect frame = _loginTextField.frame;
        frame.origin.y = 20; //marginTop
        frame.origin.x = _loginButton.frame.origin.x;
        _loginTextField.frame = frame;
                
        // Placement passwordTextField
        frame = _passwordTextField.frame;
        frame.origin.x = _loginTextField.frame.origin.x;
        _passwordTextField.frame = frame;
        
        // Placement forgotPasswordLabel
        frame = _forgotPassword.frame;
        frame.origin.x = _loginButton.frame.origin.x + 5;
        _forgotPassword.frame = frame;
        
        [_boxView addSubview:_loginTextField];
        [_boxView addSubview:_passwordTextField];
        [_boxView addSubview:_forgotPassword];
        
        [UIView beginAnimations:@"showLoginForm" context:NULL]; // Begin animation
        
        //on retire le bouton inscription
        _inscriptionButton.alpha = 0;
        
        [self placerHauteurView:_passwordTextField after:_loginTextField withMargin:5];
        [self placerHauteurView:_forgotPassword after:_passwordTextField withMargin:2];
        [self placerHauteurView:_loginButton after:_forgotPassword withMargin:15];
        
        //on resize la box
        [self caculateHeightBox];
        
		[UIView commitAnimations]; // End animations
        
        [UIView beginAnimations:@"showAlphaLoginForm" context:NULL]; // Begin animation
        [_inscriptionButton removeFromSuperview];
        _loginTextField.alpha = 1;
        _passwordTextField.alpha = 1;
        _forgotPassword.alpha = 1;
        _backButton.alpha = 1;
        [UIView commitAnimations]; // End animations
        
        // Google Analytics
        [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Connexion"];
    }
    
    // ----- Hide -----
    else{
        _isShowFormLogin = NO;
        _backButton.enabled = NO;
        _inscriptionButton.alpha = 0;
        
        // Placement bouton inscription
        CGRect frame = _inscriptionButton.frame;
        frame.origin.y = 45; //marginTop
        frame.origin.x = _loginButton.frame.origin.x;
        _inscriptionButton.frame = frame;
        
        [_boxView addSubview:_inscriptionButton];
        
        [UIView beginAnimations:@"hideAlphaLoginForm" context:nil];
        _forgotPassword.alpha = 0;
        _loginTextField.alpha = 0;
        _passwordTextField.alpha = 0;
        
        [UIView commitAnimations];
        
        
        [UIView beginAnimations:@"hideLoginForm" context:NULL]; // Begin animation
        
        [_forgotPassword removeFromSuperview];
        [_loginTextField removeFromSuperview];
        [_passwordTextField removeFromSuperview];
        _backButton.alpha = 0;
        _inscriptionButton.alpha = 1;
        
        [self placerHauteurView:self.loginButton after:self.inscriptionButton withMargin:8];
        
        //on resize la box
        [self caculateHeightBox];
        
		[UIView commitAnimations]; // End animations
    }
    
}


#pragma mark - Actions

- (IBAction)clicCreateUser {
    CreationPage1ViewController *creationPage = [[CreationPage1ViewController alloc] initWithNibName:@"CreationPage1ViewController" bundle:nil];
    
    [self.navigationController pushViewController:creationPage animated:YES];
}

- (IBAction)clicLogin {
    
    
    //on valide le formulaire de login
    if(_isShowFormLogin){
        
        //on check si les champs sont remplis
        if( _loginTextField.text.length == 0 || _loginTextField.text.length == 0){
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HomeViewController_AlertView_IncompleteForm_Title", nil)
                    message:NSLocalizedString(@"HomeViewController_AlertView_IncompleteForm_Message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                                    otherButtonTitles:nil];
            [message show];
        }
        //on se connect
        else{
            //on descend le clavier si besoin
            [_loginTextField resignFirstResponder];
            [_passwordTextField resignFirstResponder];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading_Login", nil);
            
            
            //on lance le login et si c'est bon on lance la timeLine            
            [UserClass loginUserWithUsername:_loginTextField.text withPassword:_passwordTextField.text withEnded:^(NSInteger status){
                
                switch (status) {
                        
                    // Si on est logué
                    case 200: {
                        UserClass *currentUser = [UserCoreData getCurrentUser];
                        [[TextFieldAutocompletionManager sharedInstance] addEmailToFavoriteEmails:currentUser.email];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self entrerDansMomentAnimated:YES];
                    }
                    break;
                        
                    // Mauvais Mot de passe | Utilisateur n'existe pas
                    case 401: {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HomeViewController_AlertView_AuthentificationFail_Title", nil)
                                                    message:NSLocalizedString(@"HomeViewController_AlertView_AuthentificationFail_Message", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                          otherButtonTitles:nil]
                         show];
                    }
                    break;
                        
                    // Erreur 500 ou autre
                    default: {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_Title", nil)
                                                    message:NSLocalizedString(@"Error_Server", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                          otherButtonTitles:nil]
                         show];
                    }
                    break;
                }
             
            }];
            
        }
    }
    //on affiche le formulaire de login
    else{
        [self showLoginForm:YES];
    }
    
}

- (IBAction)clicForgotPassword {

    // Alert View
    UIAlertView *lostPasswordAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HomeViewController_AlertView_ForgotPassword_Title", nil)
                                message:NSLocalizedString(@"HomeViewController_AlertView_ForgotPassword_Message", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                      otherButtonTitles:NSLocalizedString(@"AlertView_Button_Valide", nil), nil];
    
    // TextField
    lostPasswordAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textfield = [lostPasswordAlertView textFieldAtIndex:0];
    textfield.placeholder = @"Email";
    textfield.delegate = self;
    
    [lostPasswordAlertView show];
}

- (IBAction)clicBackButton {
    [self showLoginForm:NO];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ------ LostPassword AlertView ---------
    // Bouton Valider
    if(buttonIndex == 1)
    {
        NSString *email = [[alertView textFieldAtIndex:0] text];
        
        [UserClass requestNewPasswordAtEmail:email withEnded:^(BOOL success) {
            
            if(success) {
                // Success
                [[MTStatusBarOverlay sharedInstance]
                 postImmediateFinishMessage:NSLocalizedString(@"HomeViewController_Status_ForgotPassword_Success", nil)
                 duration:1
                 animated:YES];
            }
            else {
                // Erreur
                [[MTStatusBarOverlay sharedInstance]
                 postImmediateErrorMessage:NSLocalizedString(@"Error_Classic", nil)
                 duration:1
                 animated:YES];
            }
            
        }];
    }
}

// Enable/Disable Valider Button
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *email = [[alertView textFieldAtIndex:0] text];
    if([[Config sharedInstance] isValidEmail:email]) {
        return YES;
    }
    return NO;
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _loginTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    else if(textField == _passwordTextField) {
        [textField resignFirstResponder];
        
        if( _loginTextField.text.length > 0 && _passwordTextField.text.length > 0 )
            [self clicLogin];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _loginTextField || textField == _passwordTextField)
        [_scrollView adjustOffsetToIdealIfNeeded];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Centrer view même quand le clavier monte
    // (Sur écran non iPhone 5)
    
    int pointsToMove = 0;
    
    if ([[VersionControl sharedInstance] isIphone5]) {
        pointsToMove = -100;
    } else {
        pointsToMove = -115;
    }
    
    if ( [_loginTextField isFirstResponder] || [_passwordTextField isFirstResponder] ) {
        
        [UIView animateWithDuration:0.2 animations:^{
            [scrollView scrollRectToVisible:CGRectMake(0, pointsToMove, scrollView.contentSize.width, scrollView.contentSize.height) animated:NO];
        }];
    }
}

@end
