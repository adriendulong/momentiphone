//
//  CreationPage2ViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CreationPage2ViewController.h"
#import "Config.h"
#import "UserClass+Server.h"

@interface CreationPage2ViewController ()

@end

@implementation CreationPage2ViewController

@synthesize delegate = _delegate;
@synthesize bgBox = _bgBox;
@synthesize boxView = _boxView;
@synthesize descriptionLabel1 = _descriptionLabel1, descriptionLabel2 = _descriptionLabel2;
@synthesize phoneTextField = _phoneTextField;
@synthesize scrollView = _scrollView;
@synthesize boutonValider = _boutonValider;

- (id)initWithDelegate:(id <HomeViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"CreationPage2ViewController" bundle:nil];
    if(self) {
        self.delegate = delegate;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Inscription tel";
    
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
    
    // iPhone 5
    frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    
    // Centrer
    frame = self.boxView.frame;
    frame.origin.y = (self.view.frame.size.height - frame.size.height)/2.0;
    self.boxView.frame = frame;
    frame = self.boutonValider.frame;
    frame.origin.y = (self.view.frame.size.height- frame.size.height)/2.0;
    self.boutonValider.frame = frame;
    
    // Shadows
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:10];
    self.descriptionLabel1.font = font;
    self.descriptionLabel2.font = font;
    [self addShadowToView:self.descriptionLabel1];
    [self addShadowToView:self.descriptionLabel2];
    
    // Accessory View
    self.phoneTextField.inputAccessoryView = self.toolbar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBgBox:nil];
    [self setDescriptionLabel1:nil];
    [self setDescriptionLabel2:nil];
    [self setPhoneTextField:nil];
    [self setScrollView:nil];
    [self setBoxView:nil];
    [self setBoutonValider:nil];
    [super viewDidUnload];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = ( (string.length == 0) || [[Config sharedInstance] isNumeric:string] || ([string isEqualToString:@"-"]) || ([string isEqualToString:@" "]) );
    
    // Activation / Desactivation bouton envoyer
    if(result) {
        
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // Si valide -> Activer bouton
        BOOL enable = (newString.length == 0 ||
                                   [[Config sharedInstance] isValidPhoneNumber:newString]);
        self.sendButton.enabled = enable;
        self.boutonValider.enabled = enable;
    }
    
    return result;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.sendButton.enabled = self.boutonValider.enabled = YES;
    return YES;
}

#pragma mark - Action

- (IBAction)clicValider
{
    [self.phoneTextField resignFirstResponder];
    
    // Si le champ est vide, alertview
    if(self.phoneTextField.text.length == 0)
    {
        
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"CreationPage2ViewController_ConfirmEmptyAlertView_Title", nil)
          message:NSLocalizedString(@"CreationPage2ViewController_ConfirmEmptyAlertView_Message", nil)
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
          otherButtonTitles:NSLocalizedString(@"AlertView_Button_Continue", nil),nil]
         show];
        
    }
    else
    {
        // Envoi
        [UserClass updateCurrentUserInformationsOnServerWithAttributes:@{@"numeroMobile":[[Config sharedInstance] formatedPhoneNumber:self.phoneTextField.text]} withEnded:^(BOOL success) {
            
            // Informe user of success
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if(success)
            {
                [self login];
            }
            else
            {
                [[MTStatusBarOverlay sharedInstance]
                 postImmediateErrorMessage:NSLocalizedString(@"Error", nil)
                 duration:1
                 animated:YES];
            }
            
        }];
        
        /*
        // Vérification
        if([[Config sharedInstance] isValidPhoneNumber:self.phoneTextField.text])
        {
            [UserClass updateCurrentUserInformationsOnServerWithAttributes:@{@"numeroMobile":[[Config sharedInstance] formatedPhoneNumber:self.phoneTextField.text]} withEnded:^(BOOL success) {
                
                // Informe user of success
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if(success)
                {
                    [self login];
                }
                else
                {
                    [[MTStatusBarOverlay sharedInstance]
                postImmediateErrorMessage:NSLocalizedString(@"Error", nil)
                     duration:1
                     animated:YES];
                }
                
            }];
        }
        else
        {
            [[[UIAlertView alloc]
              initWithTitle:NSLocalizedString(@"CreationPage2ViewController_Invalide_Title", nil)
              message:NSLocalizedString(@"CreationPage2ViewController_Invalide_Message", nil)
              delegate:self
              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
              otherButtonTitles:nil]
             show];
            
            [self.phoneTextField becomeFirstResponder];
        }
         */
    }
}

- (void)login {
    // Login
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.delegate entrerDansMomentAnimated:YES];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Confirmer
    if(buttonIndex == 1)
    {
        [self login];
    }
}

#pragma mark - UIScrollView Delegate



@end
