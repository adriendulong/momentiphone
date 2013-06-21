//
//  InviteAddViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InviteAddViewController.h"
#import "Config.h"
#import "NSMutableAttributedString+FontAndTextColor.h"
#import "UILabel+BottomAlign.h"
#import "UserClass+Server.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MomentClass+Server.h"
#import "SMSComposeViewController.h"

#define headerSize 100

enum InviteAddFontSize {
    InviteAddFontSizeSmall = 10,
    InviteAddFontSizeBig = 14
    };

@interface InviteAddViewController () {
    
    @private
    NSString *contactSearchText;
    NSString *facebookSearchText;
    NSString *favorisSearchText;
    UIAlertView *cancelConfirmAlertView, *successInvitedAlertView;
    BOOL acceptReturnBackButton;
}

@end

@implementation InviteAddViewController

@synthesize owner = _owner;
@synthesize moment = _moment;
@synthesize selectedFriends = _selectedFriends;
@synthesize notifSelectedFriends = _notifSelectedFriends;
@synthesize scrollView = _scrollView;
@synthesize selectedOnglet = _selectedOnglet;

@synthesize searchTextField = _searchTextField;

@synthesize navBarRigthButtonsView = _navBarRigthButtonsView;
@synthesize contactButton = _contactButton;
@synthesize facebookButton = _facebookButton;
@synthesize favorisButton = _favorisButton;

@synthesize actualTableViewController = _actualTableViewController;
@synthesize contactTableViewController = _contactTableViewController;
@synthesize facebookTableViewController = _facebookTableViewController;
@synthesize favorisTableViewController = _favorisTableViewController;
@synthesize contactLoaded = _contactLoaded, facebookLoaded = _facebookLoaded, favorisLoaded = _favorisLoaded;

@synthesize validerLabel = _validerLabel;
@synthesize nbInvitesLabel = _nbInvitesLabel;
@synthesize phraseLabel = _phraseLabel;
@synthesize ttValiderLabel = _ttValiderLabel;

- (id)initWithOwner:(UserClass*)owner withMoment:(MomentClass*)moment
{
    self = [super initWithNibName:@"InviteAddViewController" bundle:nil];
    if(self) {
        self.owner = owner;
        self.moment = moment;
        self.selectedFriends = [[NSMutableArray alloc] init];
        self.notifSelectedFriends = [[NSMutableArray alloc] init];
        self.selectedOnglet = 0;
        acceptReturnBackButton = NO;
    }
    return self;
}

- (void)placerLabel:(UILabel*)label afterView:(UILabel*)origin withMarginX:(NSInteger)marginX withMarginY:(NSInteger)marginY
{    
    CGRect frame = label.frame;
    frame.origin.x = origin.frame.origin.x + origin.frame.size.width + marginX;
    frame.origin.y = [label topAfterBottomAligningWithLabel:origin] + marginY;
    label.frame = frame;
}

- (void)updateHeaderFrames
{
    NSInteger margin = 3;
    
    // nb Invité
    [self.nbInvitesLabel sizeToFit];
    if(self.ttValiderLabel)
        [self placerLabel:self.nbInvitesLabel afterView:self.ttValiderLabel withMarginX:margin withMarginY:1];
    else
        [self placerLabel:self.nbInvitesLabel afterView:self.validerLabel withMarginX:margin withMarginY:1];
    
    // phrase Label
    [self.phraseLabel sizeToFit];
    [self placerLabel:self.phraseLabel afterView:self.nbInvitesLabel withMarginX:margin withMarginY:-1];
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation bar
    [self initNavigationBar];
    
    // iPhone 5 support
    self.view.frame = CGRectMake(0, 0, 320, [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT );
    self.scrollView.frame = CGRectMake(0, headerSize, 320, self.view.frame.size.height - headerSize );
    
    // Update Scroll View Size
    self.scrollView.contentSize = CGSizeMake(320*3, self.scrollView.frame.size.height);
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    // Valider Label
    [self setValiderLabelText:NSLocalizedString(@"InviteAddViewController_validerLabel", nil)];
    
    // nb Invités
    self.nbInvitesLabel.font = [[Config sharedInstance] defaultFontWithSize:15];
    self.nbInvitesLabel.textColor = [[Config sharedInstance] orangeColor];
    [self updateSelectedFriendsLabel];
    
    // Phrase
    self.phraseLabel.text = NSLocalizedString(@"InviteAddViewController_phraseLabel", nil);
    self.phraseLabel.font = [[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeSmall];
    self.phraseLabel.textColor = [[Config sharedInstance] textColor];
    
    // Moment Label
    //[self setMomentLabelText:@"MOMENT"];
    
    // Frames
    [self updateHeaderFrames];
    
    // Initialisation des vues
    [self addAndScrollToOnglet:InviteAddTableViewControllerContactStyle];
    [self addOnglet:InviteAddTableViewControllerFacebookStyle];
    [self addOnglet:InviteAddTableViewControllerFavorisStyle];
    
    self.contactLoaded = NO;
    self.facebookLoaded = NO;
    self.favorisLoaded = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Invitation"];
}

#pragma mark - Custom Label initialisation

- (void)setValiderLabelText:(NSString*)texteLabel
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeBig] range:range];
        range = NSMakeRange(1, taille-1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeSmall] range:range];
        [attributedString setTextColor:[[Config sharedInstance] textColor] ];
        
        [self.validerLabel setAttributedText:attributedString];
        self.validerLabel.textAlignment = kCTLeftTextAlignment;
        [self.validerLabel sizeToFit];
    }
    else
    {
        self.ttValiderLabel = [[TTTAttributedLabel alloc] initWithFrame:self.validerLabel.frame];
        self.ttValiderLabel.backgroundColor = [UIColor clearColor];
        [self.ttValiderLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeBig onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeSmall onRange:NSMakeRange(1, taille-1)];
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [self.ttValiderLabel sizeToFit];
        [self.validerLabel.superview addSubview:self.ttValiderLabel];
        self.validerLabel.hidden = YES;
    }
}

/*
- (void)setMomentLabelText:(NSString*)texteLabel
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeBig];
        UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeSmall];
        
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:smallFont range:range];
        [attributedString setTextColor:[[Config sharedInstance] textColor] ];
        range = NSMakeRange(1, 1);
        [attributedString setFont:bigFont range:range];
        [attributedString setTextColor:[[Config sharedInstance] orangeColor] range:range];
        
        range = NSMakeRange(2, taille-2);
        [attributedString setFont:smallFont range:range];
        [attributedString setTextColor:[[Config sharedInstance] textColor] range:range];
        
        [self.momentLabel setAttributedText:attributedString];
        self.momentLabel.textAlignment = kCTTextAlignmentLeft;
        [self.momentLabel sizeToFit];
    }
    else
    {
        self.ttMomentLabel = [[TTTAttributedLabel alloc] initWithFrame:self.momentLabel.frame];
        self.ttMomentLabel.backgroundColor = [UIColor clearColor];
        [self.ttMomentLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            NSRange rang = NSMakeRange(0, 1);
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeSmall onRange:rang];
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:rang];
            rang = NSMakeRange(1, 1);
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeBig onRange:rang];
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.orangeColor onRange:rang];
            rang = NSMakeRange(2, taille-2);
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeSmall onRange:rang];
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:rang];
            
            return mutableAttributedString;
        }];
        
        [self.ttMomentLabel sizeToFit];
        [self.momentLabel.superview addSubview:self.ttMomentLabel];
        self.momentLabel.hidden = YES;
    }
}
*/

#pragma mark - InviteViewController Delegate

- (void)addNewSelectedFriend:(UserClass*)friend notif:(BOOL)notif
{
    if([self.selectedFriends count] == 0)
        self.bandeauButton.backgroundColor = [UIColor grayColor];
    
    [self.selectedFriends addObject:friend];
    [self updateSelectedFriendsLabel];
    if(notif)
        [self.notifSelectedFriends addObject:friend];
}

- (void)removeSelectedFriend:(UserClass*)friend
{
    if([self.selectedFriends containsObject:friend]) {
        [self.selectedFriends removeObject:friend];
        [self updateSelectedFriendsLabel];
    }
    if([self.notifSelectedFriends containsObject:friend]) {
        [self.notifSelectedFriends removeObject:friend];
    }
    
    if([self.selectedFriends count] == 0)
        self.bandeauButton.backgroundColor = [UIColor clearColor];
}

- (void)updateSelectedFriendsLabel {
    self.nbInvitesLabel.text = [NSString stringWithFormat:@"%d", [self.selectedFriends count]];
    [self updateHeaderFrames];
}

- (BOOL)selectedFriendsEmpty {
    return ([self.selectedFriends count] == 0);
}

#pragma mark - NavigationBar

- (void) initNavigationBar
{
    [CustomNavigationController setBackButtonWithViewController:self];
    
    // Remove space at right
    UIBarButtonItem *negativeSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpace.width = -5;
    
    // Add customView
    UIBarButtonItem *buttons = [[UIBarButtonItem alloc] initWithCustomView:self.navBarRigthButtonsView];
    
    // Set Nav bar buttons
    self.navigationItem.rightBarButtonItems = @[negativeSpace, buttons];
    [self selectNavigationBarButton:self.selectedOnglet];
    
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"btn-back.png"];
    
    button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateSelected];
    
    [button removeTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(confirmCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationItem.leftBarButtonItem = barBackItem;
}

- (void)selectNavigationBarButton:(enum InviteAddTableViewControllerStyle)rank
{        
    switch (rank) {
        case InviteAddTableViewControllerContactStyle:
            self.contactButton.selected = YES;
            self.facebookButton.selected = NO;
            self.favorisButton.selected = NO;
            break;
            
        case InviteAddTableViewControllerFacebookStyle:
            self.contactButton.selected = NO;
            self.facebookButton.selected = YES;
            self.favorisButton.selected = NO;
            break;
            
        case InviteAddTableViewControllerFavorisStyle:
            self.contactButton.selected = NO;
            self.facebookButton.selected = NO;
            self.favorisButton.selected = YES;
            break;
    }
    
}

#pragma mark - Util

- (void)placerView:(UIView*)view toOnglet:(enum InviteAddTableViewControllerStyle)onglet
{
    CGRect frame = view.frame;
    frame.origin.x = onglet*320;
    frame.origin.y = 0;
    frame.size.height = self.scrollView.frame.size.height;
    view.frame = frame;
}

- (void)addOngletView:(UIView*)view rank:(enum InviteAddTableViewControllerStyle)rank
{
    [self placerView:view toOnglet:rank];
    [self.scrollView addSubview:view];
}


- (void)addOnglet:(enum InviteAddTableViewControllerStyle)onglet
{
    switch (onglet) {
        case InviteAddTableViewControllerContactStyle:
            if(!_contactTableViewController)
                [self addOngletView:self.contactTableViewController.view rank:onglet];
            break;
        
        case InviteAddTableViewControllerFacebookStyle:
            if(!_facebookTableViewController)
                [self addOngletView:self.facebookTableViewController.view rank:onglet];
            break;
            
        case InviteAddTableViewControllerFavorisStyle:
            if(!_favorisTableViewController)
                [self addOngletView:self.favorisTableViewController.view rank:onglet];
            break;
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollToOnglet:(enum InviteAddTableViewControllerStyle)onglet animated:(BOOL)animated
{
    // Scroll
    [self.scrollView scrollRectToVisible:CGRectMake(onglet*320, 0, 320, self.scrollView.frame.size.height) animated:animated];
    
    // Enregistrement du texte du champ de recherche
    switch (self.selectedOnglet) {
        case InviteAddTableViewControllerContactStyle:
            contactSearchText = self.searchTextField.text;
            break;
            
        case InviteAddTableViewControllerFacebookStyle:
            facebookSearchText = self.searchTextField.text;
            break;
        
        case InviteAddTableViewControllerFavorisStyle:
            favorisSearchText = self.searchTextField.text;
            break;
    }
    
    // Update selected onglet
    self.selectedOnglet = onglet;
    
    // Loading
    switch (onglet) {
        case InviteAddTableViewControllerContactStyle:
            if(!self.contactLoaded) {
                [self.contactTableViewController loadFriendsList];
                self.contactLoaded = YES;
            }
            self.actualTableViewController = self.contactTableViewController;
            self.searchTextField.text = contactSearchText;
            break;
            
        case InviteAddTableViewControllerFacebookStyle:
            if(!self.facebookLoaded) {
                [self.facebookTableViewController loadFriendsList];
                self.facebookLoaded = YES;
            }
            self.actualTableViewController = self.facebookTableViewController;
            self.searchTextField.text = facebookSearchText;
            break;
            
        case InviteAddTableViewControllerFavorisStyle:
            if(!self.favorisLoaded) {
                [self.favorisTableViewController loadFriendsList];
                self.favorisLoaded = YES;
            }
            self.actualTableViewController = self.favorisTableViewController;
            self.searchTextField.text = favorisSearchText;
            break;
    }
}

- (void)addAndScrollToOnglet:(enum InviteAddTableViewControllerStyle)onglet
{
    [self resignFirstResponder];
    [self selectNavigationBarButton:onglet];
    [self addOnglet:onglet];
    [self scrollToOnglet:onglet animated:YES];
}

#pragma mark - Action

- (IBAction)clicNavigationBarButtonFavoris {
    [self addAndScrollToOnglet:InviteAddTableViewControllerFavorisStyle];
}

- (IBAction)clicNavigationBarButtonFacebook {
    [self addAndScrollToOnglet:InviteAddTableViewControllerFacebookStyle];
}

- (IBAction)clicNavigationBarButtonContact {
    [self addAndScrollToOnglet:InviteAddTableViewControllerContactStyle];
}

- (IBAction)clicValider {
        
    if([self.selectedFriends count] > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
        
        [self.moment inviteNewGuest:self.selectedFriends withEnded:^(BOOL success) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if(success)
            {                
                // Envoyer SMS d'invitation
                BOOL smsSend = NO;
                
                if([MFMessageComposeViewController canSendText])
                {
                    // Empeche les doublons
                    NSMutableSet *smsList = [[NSMutableSet alloc] init];
                    for(UserClass *user in self.notifSelectedFriends)
                    {
                        // Envoyer que aux 06 ou 07
                        if(user.numeroMobile && [[Config sharedInstance] isMobilePhoneNumber:user.numeroMobile forceValidation:NO]) {
                            [smsList addObject:[user.numeroMobile stringByReplacingOccurrencesOfString:@" " withString:@""]];
                        }
                        if(user.secondPhone && [[Config sharedInstance] isMobilePhoneNumber:user.secondPhone forceValidation:NO]) {
                            [smsList addObject:[user.secondPhone stringByReplacingOccurrencesOfString:@" " withString:@""]];
                        }
                    }
                    
                    if([smsList count] > 0)
                    {
                        // SMS Composer
                        SMSComposeViewController *controller = [[SMSComposeViewController alloc] init];
                        
                        // Paramètres
                        NSString *titre = self.moment.titre;
                        NSString *url = self.moment.uniqueURL;
                        NSString *currentUserName = [self currentUserName];
                        
                        // SMS body
                        controller.body =
                        [NSString stringWithFormat:
                         NSLocalizedString(@"InviteAddViewController_SendSMS_Message", nil),titre, url, currentUserName];
                        
                        // Numéros de téléphones
                        controller.recipients = smsList.allObjects;
                        
                        // Delegate
                        controller.messageComposeDelegate = self;
                        smsSend = YES;
                        [self presentModalViewController:controller animated:YES];
                    }
                }
                else {
                    [TestFlight passCheckpoint:@"DEVICE CAN'T SEND SMS"];
                }
                
                // Envoyer Notification d'invitations Facebook
                if(!smsSend) {
                    
                    // Si il n'y a pas d'invitations Facebook
                    if(![self sendNotifToFacebookFriends]) {
                        
                        // Informer l'utilisateur que les invitations ont été envoyées
                        successInvitedAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InviteAddTableViewController_AlertView_InviteSuccess_Title", nil)
                                                                        message:NSLocalizedString(@"InviteAddTableViewController_AlertView_InviteSuccess_Message", nil)
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                                              otherButtonTitles:nil];
                        [successInvitedAlertView show];
                    }
                }
                
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"ERREUR" message:@"ERREUR" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
        }];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InviteAddTableViewController_AlertView_InviteWithNoGuest_Title", nil)
                                    message:NSLocalizedString(@"InviteAddTableViewController_AlertView_InviteWithNoGuest_Message", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                          otherButtonTitles:nil]
         show];
    }
    
}

#pragma mark - UIScrollView Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if( !((int)scrollView.contentOffset.x%320) ) {
        NSInteger select = scrollView.contentOffset.x/320;
        [self addAndScrollToOnglet:select];
    }
    
}

#pragma mark - Getters

- (InviteAddTableViewController*)contactTableViewController {
    
    if(!_contactTableViewController) {
        _contactTableViewController = [[InviteAddTableViewController alloc] initWithOwner:self.owner withDelegate:self withStyle:InviteAddTableViewControllerContactStyle];
    }
    
    return _contactTableViewController;
}

- (InviteAddTableViewController*)facebookTableViewController {
    if(!_facebookTableViewController) {
        _facebookTableViewController = [[InviteAddTableViewController alloc] initWithOwner:self.owner withDelegate:self withStyle:InviteAddTableViewControllerFacebookStyle];
    }
    
    return _facebookTableViewController;
}

- (InviteAddTableViewController*)favorisTableViewController {
    if(!_favorisTableViewController) {
        _favorisTableViewController = [[InviteAddTableViewController alloc] initWithOwner:self.owner withDelegate:self withStyle:InviteAddTableViewControllerFavorisStyle];
    }
    
    return _favorisTableViewController;
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.actualTableViewController updateVisibleFriends:self.actualTableViewController.friends];
    return YES;
}

- (IBAction)clicSearchButton {
    [self.searchTextField resignFirstResponder];
}

- (IBAction)searchBarChangeValue:(UITextField *)searchBar {
    if(searchBar.text.length > 1) {
        
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        // NSDictionary* de la forme
        // @{
        //      @"user":[UserClass]
        //      @"isSelected" : [BOOL]
        //  }
        for( NSDictionary *person in self.actualTableViewController.friends )
        {
            BOOL add = NO;
            
            UserClass *user = person[@"user"];
            
            // Cherche Prénom
            if(user.prenom) {
                NSRange prenomRange = [user.prenom rangeOfString:searchBar.text options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
                if(prenomRange.location != NSNotFound)
                    add = YES;
            }
            // Cherche Nom
            if(!add && user.nom) {
                NSRange nomRange = [user.nom rangeOfString:searchBar.text options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
                if( nomRange.location != NSNotFound )
                    add = YES;
            }
            // Cherche Prénom et Nom
            if(!add && user.prenom && user.nom) {
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", user.prenom, user.nom];
                NSRange fullNameRange = [fullName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
                if( fullNameRange.location != NSNotFound )
                    add = YES;
                else {
                    
                    fullName = [NSString stringWithFormat:@"%@ %@", user.nom, user.prenom];
                    fullNameRange = [fullName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
                    
                    if(fullNameRange.location != NSNotFound)
                        add = YES;
                    
                }
                
            }
            
            // Si trouvé
            if(add) {
                [temp addObject:person];
            }
        }
        
        if([temp count] == 0)
        {
            // On vérifie si c'est un début de numéro de téléphone
            NSString *regex = @"0[1-9]([0-9]*)";
            NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            BOOL phone = [test evaluateWithObject:searchBar.text];
            
            // User attributes
            NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
            if(phone)
                attr[@"numeroMobile"] = searchBar.text;
            else
                attr[@"email"] = searchBar.text;
            
            // Création du user à inviter
            UserClass *user = [[UserClass alloc] initWithAttributesFromLocal:attr];
            
            attr = @{
                     @"user":user,
                     @"isSelected":@(NO),
                     @"newUser":(phone ? @"numeroMobile" : @"email") // Cellule Email ou Phone
                     }.mutableCopy;
            
            // Ajout
            [temp addObject:attr];
            
        }
    
        [self.actualTableViewController updateVisibleFriends:temp];
    }
    else {
        [self.actualTableViewController updateVisibleFriends:self.actualTableViewController.friends];
    }
}

#pragma mark - UIAlertView Delegate

- (BOOL)sendNotifToFacebookFriends
{
    
    // Liste les id facebook
    NSMutableSet *fbId = [[NSMutableSet alloc] init];
    for( UserClass* user in self.notifSelectedFriends )
    {
        if(user.facebookId)
            [fbId addObject:user.facebookId];
    }
    
    if([fbId count] > 0)
    {
        // Destinataires
        NSDictionary* params = @{@"to" : [fbId.allObjects componentsJoinedByString:@","]};
        
        // Message
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"InviteAddViewController_NotifsFB_Message", nil),  [self currentUserName], self.moment.titre];
                
        [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                      message:message
                                                        title:@"Invitations"
                                                   parameters:params
                                                      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                          
                                                          NSLog(@"HANDLER CALLED");
                                                          if (error) {
                                                              
                                                              [[[UIAlertView alloc]
                                                                initWithTitle:NSLocalizedString(@"Error_Classic", nil)
                                                                message:NSLocalizedString(@"InviteAddViewController_NotifsFB_Fail", nil)
                                                                delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                                                otherButtonTitles:nil]
                                                               show];
                                                              
                                                              
                                                          }
                                                          
                                                          // Retour à la vue info
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }];
    }
    else
    {
        // Invitations Facebook pas envoyées
        return NO;
    }
    
    // Invitations Facebook envoyées
    return YES;
    
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
    [self dismissModalViewControllerAnimated:YES];
    
    // Send Facebook Notif
    if(![self sendNotifToFacebookFriends]) {
        // Retour à la vue info
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Util

- (NSString*)currentUserName {
    // Nom de l'expéditeur
    return [[UserCoreData getCurrentUser] formatedUsernameWithStyle:UsernameStyleCapitalized];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == cancelConfirmAlertView) {
        if (buttonIndex == 1) {
            acceptReturnBackButton = YES;
            [self clicValider];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (alertView == successInvitedAlertView) {
        if (acceptReturnBackButton)
            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)confirmCancel
{
    if([self.selectedFriends count] != 0) {
        NSString *message = [[NSString alloc] init];
        
        if([self.selectedFriends count] == 1 )
            message = NSLocalizedString(@"InviteAddViewController_AlertView_BackButton_Message_One", nil);
        else
            message = NSLocalizedString(@"InviteAddViewController_AlertView_BackButton_Message_Several", nil);
        
        cancelConfirmAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InviteAddViewController_AlertView_BackButton_Title", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"AlertView_Button_YES", nil), nil];
        [cancelConfirmAlertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
