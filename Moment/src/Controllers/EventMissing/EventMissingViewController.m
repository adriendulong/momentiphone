//
//  EventMissingViewController.m
//  Moment
//
//  Created by SkeletonGamer on 27/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "EventMissingViewController.h"
#import "Config.h"

const static NSString *kParameterContactMail = @"hello@appmoment.fr";

@interface EventMissingViewController ()

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

- (IBAction)clicAddPhonenumber
{
    UserClass *currentUser = [UserCoreData getCurrentUser];

    if(currentUser.numeroMobile) {
        
        if(currentUser.secondPhone) {
            [[[UIAlertView alloc] initWithTitle:@"J'ai 2 numéros"
                                        message:@"Supprimes-en 1 des 2 !"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil]
             show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"J'ai 1 seul numéro"
                                        message:@"Rentres-en un second !"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil]
             show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Je n'ai pas de numéro"
                                    message:@"Rentres-en un ;)"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]
         show];
    }
}

- (IBAction)clicContactUs
{
    
    if([MFMailComposeViewController canSendMail])
    {
        
        // Email Subject
        NSString *emailTitle = @"Hello Moment, un petit mot";
        // Email Content
        NSString *messageBody = @"<i>C'était juste pour vous dire</i>";
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        [mc setToRecipients:@[kParameterContactMail]];
        
        // Present mail view controller on screen
        [[VersionControl sharedInstance] presentModalViewController:mc fromRoot:self animated:YES];
    }
    else
    {
        NSLog(@"mail composer fail");
        
        [[[UIAlertView alloc] initWithTitle:@"Envoi impossible"
                                    message:@"Votre appareil ne supporte pas l'envoi d'email"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            
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
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self animated:YES];
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
