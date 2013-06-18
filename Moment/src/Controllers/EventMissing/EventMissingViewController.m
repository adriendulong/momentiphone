//
//  EventMissingViewController.m
//  Moment
//
//  Created by SkeletonGamer on 27/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "EventMissingViewController.h"
#import "Config.h"
#import "UserClass+Server.h"
#import "FacebookManager.h"


@interface EventMissingViewController () {
@private
    UIAlertView *fbLoginPopup;
    UIAlertView *addFirstPhoneNumber;
    UIAlertView *addSecondPhoneNumber;
    UIAlertView *removePhoneNumber;
    UIAlertView *addFirstEmailAddress;
    UIAlertView *addSecondEmailAddress;
    UIAlertView *removeEmailAddress;
}

@property (strong, nonatomic) IBOutlet UILabel *mainTitle;
@property (strong, nonatomic) IBOutlet UILabel *subTitle;
@property (strong, nonatomic) IBOutlet UILabel *facebookTitle;
@property (strong, nonatomic) IBOutlet UILabel *callTitle;
@property (strong, nonatomic) IBOutlet UILabel *mailTitle;
@property (strong, nonatomic) IBOutlet UILabel *contactTitle;

@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UIButton *mailButton;
@property (strong, nonatomic) IBOutlet UIButton *contactButton;

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation EventMissingViewController

@synthesize delegate = _delegate;

@synthesize mainTitle = _mainTitle;
@synthesize subTitle = _subTitle;
@synthesize facebookTitle = _facebookTitle;
@synthesize callTitle = _callTitle;
@synthesize mailTitle = _mailTitle;
@synthesize contactTitle = _contactTitle;

@synthesize facebookButton = _facebookButton;
@synthesize callButton = _callButton;
@synthesize mailButton = _mailButton;
@synthesize contactButton = _contactButton;

@synthesize contentView = _contentView;


#pragma mark - Init

- (id)initWithDDMenuDelegate:(DDMenuController *)delegate
{
    self = [super initWithNibName:@"EventMissingViewController" bundle:nil];
    if(self) {
        self.delegate = delegate;
        
        [CustomNavigationController setBackButtonWithViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Moments Manquant";
    
    self.contentView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    [self.facebookButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    [self.facebookButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.facebookButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self.callButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    [self.callButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.callButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self.mailButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    [self.mailButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.mailButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self.contactButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    [self.contactButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.contactButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self.mainTitle setText:NSLocalizedString(@"EventMissingViewController_mainTitle", nil)];
    [self.subTitle setText:NSLocalizedString(@"EventMissingViewController_subTitle", nil)];
    [self.facebookTitle setText:NSLocalizedString(@"EventMissingViewController_facebookTitle", nil)];
    [self.facebookButton.titleLabel setText:NSLocalizedString(@"EventMissingViewController_facebookButton", nil)];
    [self.callTitle setText:NSLocalizedString(@"EventMissingViewController_callTitle", nil)];
    [self.callButton.titleLabel setText:NSLocalizedString(@"EventMissingViewController_callButton", nil)];
    [self.mailTitle setText:NSLocalizedString(@"EventMissingViewController_mailTitle", nil)];
    [self.mailButton.titleLabel setText:NSLocalizedString(@"EventMissingViewController_mailButton", nil)];
    [self.contactTitle setText:NSLocalizedString(@"EventMissingViewController_contactTitle", nil)];
    [self.contactButton.titleLabel setText:NSLocalizedString(@"EventMissingViewController_contactButton", nil)];
    
    
    if([[VersionControl sharedInstance] supportIOS6]) {
        
        //MAIN TITLE
        [self.mainTitle setFont:[UIFont fontWithName:@"Numans-Regular" size:13.0]];
        
        NSMutableAttributedString *mainTitleText = [[NSMutableAttributedString alloc] initWithString:self.mainTitle.text];
        //[text addAttribute:NSForegroundColorAttributeName value:(id) range:NSMakeRange(NSUInteger loc, NSUInteger len)];
        [mainTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [mainTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange([self.mainTitle.text length]-1, 1)];
        [self.mainTitle setAttributedText:mainTitleText];
        
        
        //SUBTITLE
        [self.subTitle setFont:[UIFont fontWithName:@"Numans-Regular" size:13.0]];
        
        NSMutableAttributedString *subTitleText = [[NSMutableAttributedString alloc] initWithString:self.subTitle.text];
        [subTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [self.subTitle setAttributedText:subTitleText];
        
        
        //FACEBOOK TITLE
        [self.facebookTitle setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
        
        NSMutableAttributedString *facebookTitleText = [[NSMutableAttributedString alloc] initWithString:self.facebookTitle.text];
        [facebookTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(0, 1)];
        [facebookTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(34, 1)];
        [facebookTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(81, 1)];
        [facebookTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(99, 1)];
        [facebookTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(106, 1)];
        [self.facebookTitle setAttributedText:facebookTitleText];
        
        
        //FACEBOOK BUTTON
        [self.facebookButton.titleLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:14]];
        
        NSMutableAttributedString *facebookButtonText = [[NSMutableAttributedString alloc] initWithString:self.facebookButton.titleLabel.text];
        [facebookButtonText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:19] range:NSMakeRange(0, 1)];
        //[facebookButtonText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:19] range:NSMakeRange(16, 1)];
        
        [facebookButtonText addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, 1)];
        [self.facebookButton setAttributedTitle:facebookButtonText forState:UIControlStateNormal];
        [self.facebookButton setAttributedTitle:facebookButtonText forState:UIControlStateSelected];
        
        
        //CALL TITLE
        [self.callTitle setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
        
        NSMutableAttributedString *callTitleText = [[NSMutableAttributedString alloc] initWithString:self.callTitle.text];
        [callTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(0, 1)];
        [callTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(32, 3)];
        [callTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(102, 1)];
        [self.callTitle setAttributedText:callTitleText];
        
        
        //CALL BUTTON
        [self.callButton.titleLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:14]];
        
        NSMutableAttributedString *callButtonText = [[NSMutableAttributedString alloc] initWithString:self.callButton.titleLabel.text];
        [callButtonText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:19] range:NSMakeRange(0, 1)];
        
        [callButtonText addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, 1)];
        [self.callButton setAttributedTitle:callButtonText forState:UIControlStateNormal];
        [self.callButton setAttributedTitle:callButtonText forState:UIControlStateSelected];
        
        
        //MAIL TITLE
        [self.mailTitle setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
        
        NSMutableAttributedString *mailTitleText = [[NSMutableAttributedString alloc] initWithString:self.mailTitle.text];
        [mailTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(0, 1)];
        [self.mailTitle setAttributedText:mailTitleText];
        
        
        //MAIL BUTTON
        [self.mailButton.titleLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:14]];
        
        NSMutableAttributedString *mailButtonText = [[NSMutableAttributedString alloc] initWithString:self.mailButton.titleLabel.text];
        [mailButtonText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:19] range:NSMakeRange(0, 1)];
        
        [mailButtonText addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, 1)];
        [self.mailButton setAttributedTitle:mailButtonText forState:UIControlStateNormal];
        [self.mailButton setAttributedTitle:mailButtonText forState:UIControlStateSelected];
        
        
        //CONTACT TITLE
        [self.contactTitle setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
        
        NSMutableAttributedString *contactTitleText = [[NSMutableAttributedString alloc] initWithString:self.contactTitle.text];
        [contactTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(0, 1)];
        [contactTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(13, 1)];
        [contactTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(15, 1)];
        [contactTitleText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange([self.contactTitle.text length]-1, 1)];
        [self.contactTitle setAttributedText:contactTitleText];
        
        
        //CONTACT BUTTON
        [self.contactButton.titleLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:14]];
        
        NSMutableAttributedString *contactButtonText = [[NSMutableAttributedString alloc] initWithString:self.contactButton.titleLabel.text];
        [contactButtonText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:19] range:NSMakeRange(0, 1)];
        
        [contactButtonText addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, 1)];
        [self.contactButton setAttributedTitle:contactButtonText forState:UIControlStateNormal];
        [self.contactButton setAttributedTitle:contactButtonText forState:UIControlStateSelected];
    } else {
        
        //MAIN TITLE
        TTTAttributedLabel *mainTitleText = [[TTTAttributedLabel alloc] initWithFrame:self.mainTitle.frame];
        [mainTitleText setFont:[UIFont fontWithName:@"Numans-Regular" size:11.0]];
        //[mainTitleText setTextColor:[UIColor orangeColor]];
        
        [mainTitleText setText:self.mainTitle.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // 1 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:15.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:15.0 onRange:NSMakeRange([self.mainTitle.text length]-1, 1)];
            
            return mutableAttributedString;
        }];
        
        
        //SUBTITLE
        TTTAttributedLabel *subTitleText = [[TTTAttributedLabel alloc] initWithFrame:self.subTitle.frame];
        [subTitleText setFont:[UIFont fontWithName:@"Numans-Regular" size:11.0]];
        //[subTitleText setTextColor:[UIColor orangeColor]];
        
        [subTitleText setText:self.mainTitle.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // 1 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:15.0 onRange:NSMakeRange(0, 1)];
            
            return mutableAttributedString;
        }];
    }
}

/*- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"Reply");
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"Button Clicked" message:@"U clicked Reply " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [myalert show];
    }
    
    if (buttonIndex == 2)
    {
        NSLog(@"Delete");
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"Button Clicked" message:@"U clicked Delete " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [myalert show];
    }
}*/

- (IBAction)clicAddFacebookAccount:(id)sender
{
    // ------------ FACEBOOK LOGIN POPUP -------------
    fbLoginPopup = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EventMissingViewController_fbLoginPopup_Title", nil)
                                              message:NSLocalizedString(@"EventMissingViewController_fbLoginPopup_Message", nil)
                                             delegate:self
                                    cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Decline", nil)
                                    otherButtonTitles:NSLocalizedString(@"AlertView_Button_Accept", nil), nil];
    [fbLoginPopup show];
}

- (IBAction)clicAddPhonenumber:(id)sender
{
    UserClass *currentUser = [UserCoreData getCurrentUser];

    if(currentUser.numeroMobile.length != 0) {
        
        if(currentUser.secondPhone.length != 0) {
            [self showPhoneNumbersAlertViewType:@"removePhoneNumber"];
        } else {
            [self showPhoneNumbersAlertViewType:@"addSecondPhoneNumber"];
        }
    } else {
        [self showPhoneNumbersAlertViewType:@"addFirstPhoneNumber"];
    }
}

- (IBAction)clicAddEmailAddress:(id)sender
{
    UserClass *currentUser = [UserCoreData getCurrentUser];
    
    if(currentUser.email.length != 0) {
        
        if(currentUser.secondEmail.length != 0) {
            [self showEmailsAlertViewType:@"removeEmailAddress"];
        } else {
            [self showEmailsAlertViewType:@"addSecondEmailAddress"];
        }
    } else {
        [self showEmailsAlertViewType:@"addFirstEmailAddress"];
    }
}

- (IBAction)clicContactUs:(id)sender
{
    
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:NSLocalizedString(@"MFMailComposeViewController_Moment_Subject", nil)];
        [mc setMessageBody:NSLocalizedString(@"MFMailComposeViewController_Moment_MessageBody", nil) isHTML:YES];
        [mc setToRecipients:@[kParameterContactMail]];
        
        // Present mail view controller on screen
        [[VersionControl sharedInstance] presentModalViewController:mc fromRoot:self animated:YES];
    }
    else
    {
        //NSLog(@"mail composer fail");
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MFMailComposeViewController_Moment_Popup_Title", nil)
                                    message:NSLocalizedString(@"MFMailComposeViewController_Moment_Popup_Message", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                          otherButtonTitles:nil]
         show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_Send", nil)
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                              otherButtonTitles:nil]
             show];
            
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self animated:YES];
}

- (void)showPhoneNumbersAlertViewType:(NSString *)phone_type {
    UserClass *currentUser = [UserCoreData getCurrentUser];
    
    if ([phone_type isEqualToString:@"addFirstPhoneNumber"]) {
        addFirstPhoneNumber = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EventMissingViewController_addFirstPhoneNumber_Title", nil)
                                                         message:NSLocalizedString(@"EventMissingViewController_addObject_Message", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                               otherButtonTitles:NSLocalizedString(@"AlertView_Button_Valide", nil), nil];
        [addFirstPhoneNumber setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* tf = [addFirstPhoneNumber textFieldAtIndex:0];
        [tf setKeyboardType:UIKeyboardTypePhonePad];
        [addFirstPhoneNumber show];
    } else if ([phone_type isEqualToString:@"addSecondPhoneNumber"]) {
        addSecondPhoneNumber = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EventMissingViewController_addSecondPhoneNumber_Title", nil)
                                                          message:[NSString stringWithFormat:NSLocalizedString(@"EventMissingViewController_addSecondPhoneNumber_Message", nil), currentUser.numeroMobile]
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                                otherButtonTitles:NSLocalizedString(@"AlertView_Button_Valide", nil), nil];
        [addSecondPhoneNumber setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* tf = [addSecondPhoneNumber textFieldAtIndex:0];
        [tf setKeyboardType:UIKeyboardTypePhonePad];
        [addSecondPhoneNumber show];
    } else if ([phone_type isEqualToString:@"removePhoneNumber"]) {
        removePhoneNumber = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EventMissingViewController_removePhoneNumber_Title", nil)
                                                       message:NSLocalizedString(@"EventMissingViewController_removePhoneNumber_Message", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                             otherButtonTitles:nil, nil];
        
        [removePhoneNumber addButtonWithTitle:currentUser.numeroMobile];
        [removePhoneNumber addButtonWithTitle:currentUser.secondPhone];
        
        [removePhoneNumber show];
    }
}

- (void)getPhoneNumber:(NSString *)phoneNumber withAttribute:(NSString *)attribute {
       
    // Si le champ est vide, alertview
    if(phoneNumber.length == 0)
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
        if ([[Config sharedInstance] isMobilePhoneNumber:phoneNumber forceValidation:YES]) {
            // Envoi
            [self sendPhoneNumber:phoneNumber withAttribute:attribute];
        } else { // Si l'email a un format non valide
            [[[UIAlertView alloc]
              initWithTitle:NSLocalizedString(@"CreationPage2ViewController_Invalide_Title", nil)
              message:NSLocalizedString(@"CreationPage2ViewController_Invalide_Message", nil)
              delegate:self
              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
              otherButtonTitles:nil,nil]
             show];
        }
    }
}
- (void)sendPhoneNumber:(NSString *)phoneNumber withAttribute:(NSString *)attribute {
    [UserClass updateCurrentUserInformationsOnServerWithAttributes:@{attribute:[[Config sharedInstance] formatedPhoneNumber:phoneNumber]} withEnded:^(BOOL success) {
        
        // Informe user of success
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if(!success)
        {
            [[MTStatusBarOverlay sharedInstance]
             postImmediateErrorMessage:NSLocalizedString(@"Error", nil)
             duration:1
             animated:YES];
        }
    }];
}

- (void)showEmailsAlertViewType:(NSString *)email_type {
    UserClass *currentUser = [UserCoreData getCurrentUser];
    
    if ([email_type isEqualToString:@"addFirstEmailAddress"]) {
        addFirstEmailAddress = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EventMissingViewController_addFirstEmailAddress_Title", nil)
                                                          message:NSLocalizedString(@"EventMissingViewController_addObject_Message", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                                otherButtonTitles:NSLocalizedString(@"AlertView_Button_Valide", nil), nil];
        [addFirstEmailAddress setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* tf = [addFirstEmailAddress textFieldAtIndex:0];
        [tf setKeyboardType:UIKeyboardTypeDefault];
        [addFirstEmailAddress show];
    } else if ([email_type isEqualToString:@"addSecondEmailAddress"]) {
        addSecondEmailAddress = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EventMissingViewController_addSecondEmailAddress_Title", nil)
                                                           message:[NSString stringWithFormat:NSLocalizedString(@"EventMissingViewController_EmailAlreadySave_Message", nil), currentUser.email]
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"AlertView_Button_Valide", nil), nil];
        [addSecondEmailAddress setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* tf = [addSecondEmailAddress textFieldAtIndex:0];
        [tf setKeyboardType:UIKeyboardTypeDefault];
        [addSecondEmailAddress show];
    } else if ([email_type isEqualToString:@"removeEmailAddress"]) {
        removeEmailAddress = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EventMissingViewController_removeEmailAddress_Title", nil)
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"EventMissingViewController_EmailAlreadySave_Message", nil), currentUser.secondEmail]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"AlertView_Button_Valide", nil), nil];
        [removeEmailAddress setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* tf = [removeEmailAddress textFieldAtIndex:0];
        [tf setKeyboardType:UIKeyboardTypeEmailAddress];
        
        [removeEmailAddress show];
        
        
        
        // Décommenter lorsqu'on pourra changer l'adresse principale
        /*removeEmailAddress = [[UIAlertView alloc] initWithTitle:@"2 email enregistrés"
         message:@"Supprimer en un:"
         delegate:self
         cancelButtonTitle:@"Annuler"
         otherButtonTitles:nil, nil];
         
         [removeEmailAddress addButtonWithTitle:currentUser.email];
         [removeEmailAddress addButtonWithTitle:currentUser.secondEmail];
         
         [removeEmailAddress show];*/
    }
}

- (void)getEmail:(NSString *)email withAttribute:(NSString *)attribute {
    
    if ([[Config sharedInstance] isValidEmail:email]) {
        // Si le champ est vide, alertview
        if(email.length == 0)
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
            [self sendEmail:email withAttribute:attribute];
        }
        
    } else { // Si l'email a un format non valide
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"MFMailComposeViewController_Moment_InvalideFormat_Title", nil)
          message:NSLocalizedString(@"MFMailComposeViewController_Moment_InvalideFormat_Message", nil)
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
          otherButtonTitles:nil,nil]
         show];
    }
}

- (void)sendEmail:(NSString *)email withAttribute:(NSString *)attribute {
    [UserClass updateCurrentUserInformationsOnServerWithAttributes:@{attribute:email} withEnded:^(BOOL success) {
        
        // Informe user of success
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if(!success)
        {
            [[MTStatusBarOverlay sharedInstance]
             postImmediateErrorMessage:NSLocalizedString(@"Error", nil)
             duration:1
             animated:YES];
        }
    }];
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
            [[FacebookManager sharedInstance] updateCurrentUserFacebookIdOnServer:nil];
        }
        
    }
    
    
    
    
    // PHONE NUMBERS
    else if (alertView == addFirstPhoneNumber) {
        UITextField *phoneTextField = [alertView textFieldAtIndex:0];
        
        if(buttonIndex == 1)
        {
            [phoneTextField resignFirstResponder];
            [self getPhoneNumber:phoneTextField.text withAttribute:@"numeroMobile"];
            
        }
    } else if (alertView == addSecondPhoneNumber) {
        UITextField *phoneTextField = [alertView textFieldAtIndex:0];
        
        if(buttonIndex == 1)
        {
            [phoneTextField resignFirstResponder];
            [self getPhoneNumber:phoneTextField.text withAttribute:@"secondPhone"];
        }
    } else if (alertView == removePhoneNumber) {
        UserClass *currentUser = [UserCoreData getCurrentUser];
        
        if(buttonIndex == 1)
        {            
            // Envoi - Remplacement 1er numéro par 2nd numéro
            [self sendPhoneNumber:currentUser.secondPhone withAttribute:@"numeroMobile"];
            
            // Envoi - Suppression 2nd numéro
            [self sendPhoneNumber:@"" withAttribute:@"secondPhone"];
            
            
            [self showPhoneNumbersAlertViewType:@"addSecondPhoneNumber"];
        } else if (buttonIndex == 2) {
            // Envoi - Suppression 2nd numéro
            [self sendPhoneNumber:@"" withAttribute:@"secondPhone"];
            
            
            [self showPhoneNumbersAlertViewType:@"addSecondPhoneNumber"];
        }
    }
    
    
    
    
    // EMAILS
    else if (alertView == addFirstEmailAddress) {
        UITextField *emailAddressTextField = [alertView textFieldAtIndex:0];
        
        if(buttonIndex == 1)
        {
            [emailAddressTextField resignFirstResponder];
            [self getEmail:emailAddressTextField.text withAttribute:@"email"];
        }
    } else if (alertView == addSecondEmailAddress) {
        UITextField *emailAddressTextField = [alertView textFieldAtIndex:0];
        
        if(buttonIndex == 1)
        {
            [emailAddressTextField resignFirstResponder];
            [self getEmail:emailAddressTextField.text withAttribute:@"secondEmail"];
        }
    } else if (alertView == removeEmailAddress) {
        UITextField *emailAddressTextField = [alertView textFieldAtIndex:0];
        
        if(buttonIndex == 1)
        {
            [emailAddressTextField resignFirstResponder];
            [self getEmail:emailAddressTextField.text withAttribute:@"secondEmail"];
        }
        
        
        // Décommenter lorsqu'on pourra changer l'adresse principale
        /*if(buttonIndex == 1)
        {            
            // Envoi - Remplacement 1er numéro par 2nd numéro
            [self sendEmail:currentUser.secondEmail withAttribute:@"email"]
            
            // Envoi - Suppression 2nd numéro
            [self sendEmail:@"" withAttribute:@"secondEmail"]
        } else if (buttonIndex == 2) {
            // Envoi - Suppression 2nd numéro
            [self sendEmail:@"" withAttribute:@"secondEmail"]
        }*/
    }
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
        
        return enable;
    }
    
    return result;
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        
        if (alertView == addFirstPhoneNumber || alertView == addSecondPhoneNumber) {
            UITextField *phoneTextField = [alertView textFieldAtIndex:0];
            
            BOOL result = ( (phoneTextField.text.length != 0) && [[Config sharedInstance] isNumeric:phoneTextField.text] );
            
            // Activation / Desactivation bouton envoyer
            if(result) {
                
                // Si valide -> Activer bouton
                BOOL enable = (phoneTextField.text.length != 0 ||
                               [[Config sharedInstance] isValidPhoneNumber:phoneTextField.text]);
                
                return enable;
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitle:nil];
    [self setSubTitle:nil];
    [self setFacebookTitle:nil];
    [self setCallTitle:nil];
    [self setMailTitle:nil];
    [self setContactTitle:nil];
    [self setFacebookButton:nil];
    [self setCallButton:nil];
    [self setMailButton:nil];
    [self setContactButton:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}
@end
