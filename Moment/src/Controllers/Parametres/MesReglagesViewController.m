//
//  MesReglagesViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "MesReglagesViewController.h"
#import "ModifierUserViewController.h"
#import "Config.h"
#import "ParametreNotification.h"
#import "UserClass+Server.h"
#import "PushNotificationManager.h"
#import "TutorialViewController.h"
#import "HomeViewController.h"
#import "WebModalViewController.h"
#import "SMSComposeViewController.h"

@interface MesReglagesViewController ()

@end

@implementation MesReglagesViewController

@synthesize delegate = _delegate;
@synthesize contentView = _contentView;

@synthesize followUsLabel = _followUsLabel, madeWithLoveLabel = _madeWithLoveLabel, versionLabel = _versionLabel;
@synthesize titreAproposLabel = _titreAproposLabel, titreNotificationLabel = _titreNotificationLabel, titreProfilLabel = _titreProfilLabel, titreConnaitreMoment = _titreConnaitreMoment, titreFeedbackLabel = _titreFeedbackLabel;
@synthesize notifInvitLabel = _notifInvitLabel, notifModifLabel = _notifModifLabel, notifMessageLabel = _notifMessageLabel, notifPhotoLabel = _notifPhotoLabel;

@synthesize likeButton = _likeButton;

#pragma mark - Init

- (id)initWithDDMenuDelegate:(DDMenuController *)delegate
{
    self = [super initWithNibName:@"MesReglagesViewController" bundle:nil];
    if(self) {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Paramètre";
    
    [CustomNavigationController setBackButtonChevronWithViewController:self];
    [CustomNavigationController setTitle:@"Paramètres" withColor:[UIColor blackColor] withViewController:self];
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    CGSize contentSize = self.contentView.frame.size;
    self.view.frame = frame;
    self.contentView.frame = frame;
    self.contentView.contentSize = contentSize;
    [self.view addSubview:self.contentView];
    
    // Fonts
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:18];
    self.followUsLabel.font = font;
    font = [[Config sharedInstance] defaultFontWithSize:16];
    self.titreConnaitreMoment.font = font;
    self.titreNotificationLabel.font = font;
    self.titreAproposLabel.font = font;
    self.titreProfilLabel.font = font;
    self.titreFeedbackLabel.font = font;
    font = [[Config sharedInstance] defaultFontWithSize:15];
    self.madeWithLoveLabel.font = font;
    self.versionLabel.font = font;
    font = [[Config sharedInstance] defaultFontWithSize:13];
    self.notifMessageLabel.font = font;
    self.notifModifLabel.font = font;
    self.notifPhotoLabel.font = font;
    self.notifInvitLabel.font = font;
    
    // Colors
    UIColor *momentOrange = [Config sharedInstance].orangeColor;
    self.titreConnaitreMoment.textColor = momentOrange;
    self.titreNotificationLabel.textColor = momentOrange;
    self.titreAproposLabel.textColor = momentOrange;
    self.titreProfilLabel.textColor = momentOrange;
    self.titreFeedbackLabel.textColor = momentOrange;
    
    [self loadParametresNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate updateActualViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate updateActualViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setDelegate:nil];
    [self setFollowUsLabel:nil];
    [self setMadeWithLoveLabel:nil];
    [self setNotifInvitLabel:nil];
    [self setTitreConnaitreMoment:nil];
    [self setTitreNotificationLabel:nil];
    [self setTitreProfilLabel:nil];
    [self setTitreAproposLabel:nil];
    [self setNotifPhotoLabel:nil];
    [self setNotifMessageLabel:nil];
    [self setNotifModifLabel:nil];
    [self setVersionLabel:nil];
    [self setNotifInviteButtonPush:nil];
    [self setNotifInviteButtonEmail:nil];
    [self setNotifPhotoButtonPush:nil];
    [self setNotifPhotoButtonEmail:nil];
    [self setNotifMessageButtonPush:nil];
    [self setNotifMessageButtonEmail:nil];
    [self setNotifModifButtonPush:nil];
    [self setNotifModifButtonEmail:nil];
    [self setLikeButton:nil];
    [self setTitreFeedbackLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)clicFollowFacebook {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    // Ouverture dans l'application facebook
    if([app canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", kParameterFacebookPageID]]];
    }
    // Ouverture dans Safari
    else {
        [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", kParameterFacebookPageName]]];
    }
}

- (IBAction)clicFollowTwitter {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:///user?screen_name=%@", kParameterTwitterPageName]];
    
    // Ouverture dans l'application twitter
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
    // Ouverture dans twitter ( différent selon iOS version je suppose)
    else if( [app canOpenURL:(url = [NSURL URLWithString:[NSString stringWithFormat:@"tweetie:///user?screen_name=%@", kParameterTwitterPageName]])] ) {
        [app openURL:url];
    }
    // Ouverture dans Safari
    else {
        [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", kParameterTwitterPageName]]];
    }
}

- (IBAction)clicLikeBadge {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coeur_photo"]];
    imgView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    
    [self.likeButton addSubview:imgView];
    
    [UIView animateWithDuration:0.3/1.5 animations:^{
        imgView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            imgView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                imgView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (finished) {
                    [imgView removeFromSuperview];
                }
            }];
        }];
    }];
}


- (IBAction)clicConnaitreEmail {
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:NSLocalizedString(@"WebModalViewController_ConnaitreMoment_Subject", nil)];
        [mc setMessageBody:NSLocalizedString(@"WebModalViewController_ConnaitreMoment_MessageBody", nil) isHTML:YES];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];
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

- (IBAction)clicConnaitreSMS {
    // SMS Composer
    SMSComposeViewController *controller = [[SMSComposeViewController alloc] init];
    
    // SMS body
    controller.body = NSLocalizedString(@"WebModalViewController_ConnaitreMoment_MessageBody", nil);
    
    // Numéros de téléphones
    //controller.recipients = smsList.allObjects;
    
    // Delegate
    controller.messageComposeDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)clicTutoriel
{
    TutorialViewController *tutorial = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
    [tutorial setWantsFullScreenLayout:YES];
    [tutorial setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:tutorial animated:YES completion:nil];
}

- (IBAction)clicEditProfil {
    ModifierUserViewController *edit = [[ModifierUserViewController alloc] initWithDefaults];
    [self.navigationController pushViewController:edit animated:YES];
}

- (IBAction)clicCGU {
    WebModalViewController *webView = [[WebModalViewController alloc] initWithURL:[NSURL URLWithString:kAppMomentCGU]];
    [self presentViewController:webView animated:YES completion:nil];
}

- (IBAction)clicContactUs {
        
    if([MFMailComposeViewController canSendMail])
    {        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:NSLocalizedString(@"MFMailComposeViewController_Moment_Subject", nil)];
        [mc setMessageBody:NSLocalizedString(@"MFMailComposeViewController_Moment_MessageBody", nil) isHTML:YES];
        [mc setToRecipients:@[kParameterContactMail]];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];
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

- (IBAction)clicLogout
{
    
    [[[UIAlertView alloc]
      initWithTitle:NSLocalizedString(@"Logout_AlertView_Title", nil)
      message:NSLocalizedString(@"Logout_AlertView_Message", nil)
      delegate:self
      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
      otherButtonTitles:NSLocalizedString(@"Logout_AlertView_LogoutButton", nil),nil]
     show];
    
    /*
    [UserClass logoutCurrentUserWithEnded:^ {
        // Show Home
        [self.delegate showRootController:YES];
        [self.delegate.navigationController popToRootViewControllerAnimated:YES];
    }];
    */
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Déconnexion
    if(buttonIndex == 1)
    {
        [UserClass logoutCurrentUserWithEnded:^ {
            // Show Home
            [self.delegate showRootController:YES];
            [self.delegate.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - MFMessageComposeViewController Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultFailed) {
        // L'envoi a échoué
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Error_Classic", nil)
          message:NSLocalizedString(@"InviteAddViewController_SendSMS_Fail", nil)
          delegate:nil
          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
          otherButtonTitles: nil]
         show];
    }
    
    // Cacher Fenetre SMS
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
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
            
            [[[UIAlertView alloc] initWithTitle:@"Erreur d'envoi"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
            
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Parametres Notifications

- (void)loadParametresNotifications
{
    // Si les push notifications sont désactivés
    BOOL loadPush = [[PushNotificationManager sharedInstance] pushNotificationEnabled];
    
    // Si des données sont déjà stockées en local, on les charge en attendant
    if([ParametreNotification settingsStoredLocally]) {
        
        NSArray *types = @[@(ParametreNotificationTypeInvitation),
                           @(ParametreNotificationTypeModification),
                           @(ParametreNotificationTypeNewChat),
                           @(ParametreNotificationTypeNewPhoto)
                           ];
        
        for( NSNumber *t in types ) {
            
            enum ParametreNotificationType type = t.intValue;
            BOOL val;
            
            // Push
            if(loadPush) {
                val = [ParametreNotification localValueForType:type mode:ParametreNotificationModePush];
                [self updateNotificationButton:type mode:ParametreNotificationModePush value:val];
            }
            else {
                // Désactiver Boutons
                [self updateNotificationButton:type mode:ParametreNotificationModePush value:NO];
            }
            
            // Email
            val = [ParametreNotification localValueForType:type mode:ParametreNotificationModeEmail];
            [self updateNotificationButton:type mode:ParametreNotificationModeEmail value:val];
        }
        
    }
    
    // Load depuis le server
    [ParametreNotification getParametres:^(NSArray *parametres) {
        if(parametres)
        {
            for(NSDictionary *params in parametres)
            {
                enum ParametreNotificationType type = [params[@"type_notif"] intValue];
                BOOL push  = [params[@"push"] boolValue];
                BOOL email = [params[@"mail"] boolValue];
                
                if(loadPush)
                    [self updateNotificationButton:type mode:ParametreNotificationModePush value:push];
                else
                    [self updateNotificationButton:type mode:ParametreNotificationModePush value:NO];
                [self updateNotificationButton:type mode:ParametreNotificationModeEmail value:email];
            }
        }
    }];
}

- (void)updateNotificationButton:(enum ParametreNotificationType)type
                      mode:(enum ParametreNotificationMode)mode
                     value:(BOOL)on
{
    
    // Enregistrer en local
    [ParametreNotification store:on type:type mode:mode];
    
    switch (type) {
            
        case ParametreNotificationTypeInvitation:
            if(mode == ParametreNotificationModePush)
                [self.notifInviteButtonPush setSelected:on];
            else
                [self.notifInviteButtonEmail setSelected:on];
            break;
            
        case ParametreNotificationTypeNewPhoto:
            if(mode == ParametreNotificationModePush)
                [self.notifPhotoButtonPush setSelected:on];
            else
                [self.notifPhotoButtonEmail setSelected:on];
            break;
            
        case ParametreNotificationTypeNewChat:
            if(mode == ParametreNotificationModePush)
                [self.notifMessageButtonPush setSelected:on];
            else
                [self.notifMessageButtonEmail setSelected:on];
            break;
            
        case ParametreNotificationTypeModification:
            if(mode == ParametreNotificationModePush)
                [self.notifModifButtonPush setSelected:on];
            else
                [self.notifModifButtonEmail setSelected:on];
            break;
            
        default:
            break;
    }
    
}

- (void)clicButton:(UIButton*)button
              type:(enum ParametreNotificationType)type
              mode:(enum ParametreNotificationMode)mode
{
    [ParametreNotification changeParametres:type mode:mode withEnded:^(BOOL success) {
        if(success) {
            [ParametreNotification store:!button.selected type:type mode:mode];
            [button setSelected:!button.selected];
        }
        else {
            [[MTStatusBarOverlay sharedInstance] postImmediateErrorMessage:@"Erreur lors de la modification des paramètres" duration:1 animated:YES];
        }
    }];
}

- (IBAction)clicButton:(UIButton*)sender {
    
    BOOL pushAuthorized = [[PushNotificationManager sharedInstance] pushNotificationEnabled];
    BOOL pushTried = NO;
    
    // Notification Invitation
    if(sender == self.notifInviteButtonPush) {
        if(!sender.selected)
            pushTried = YES;
        
        if(pushAuthorized)
            [self clicButton:sender type:ParametreNotificationTypeInvitation mode:ParametreNotificationModePush];
    }
    else if(sender == self.notifInviteButtonEmail)
        [self clicButton:sender type:ParametreNotificationTypeInvitation mode:ParametreNotificationModeEmail];
    
    // Notification Photo
    else if(sender == self.notifPhotoButtonPush) {
        if(!sender.selected)
            pushTried = YES;
        
        if(pushAuthorized)
            [self clicButton:sender type:ParametreNotificationTypeNewPhoto mode:ParametreNotificationModePush];
    }
    else if(sender == self.notifPhotoButtonEmail)
        [self clicButton:sender type:ParametreNotificationTypeNewPhoto mode:ParametreNotificationModeEmail];
    
    // Notification Message
    else if(sender == self.notifMessageButtonPush) {
        if(!sender.selected)
            pushTried = YES;
        
        if(pushAuthorized)
            [self clicButton:sender type:ParametreNotificationTypeNewChat mode:ParametreNotificationModePush];
    }
    else if(sender == self.notifMessageButtonEmail)
        [self clicButton:sender type:ParametreNotificationTypeNewChat mode:ParametreNotificationModeEmail];
    
    // Notification Message
    else if(sender == self.notifModifButtonPush) {
        if(!sender.selected)
            pushTried = YES;
        
        if(pushAuthorized)
            [self clicButton:sender type:ParametreNotificationTypeModification mode:ParametreNotificationModePush];
    }
    else if(sender == self.notifModifButtonEmail)
        [self clicButton:sender type:ParametreNotificationTypeModification mode:ParametreNotificationModeEmail];
    
    // Si push désactivé
    if(!pushAuthorized && pushTried) {
        [[PushNotificationManager sharedInstance] pushNotificationDisabledAlertView];
    }
}

///////////////////////////////////////////
//#pragma mark - TestFlight SDK
//#pragma mark DEBUG

-(IBAction)launchFeedback {
    //[TestFlight openFeedbackView];
    [[Config sharedInstance] feedBackMailComposerWithDelegate:self root:self];
}

@end
