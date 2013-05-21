//
//  VoletViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletViewController.h"
#import "UserCoreData+Model.h"
#import "PushNotificationManager.h"
#import "LocalNotificationCoreData+Model.h"
#import "LocalNotificationCoreData+Server.h"
#import "Config.h"

#import "VoletViewControllerEmptyCell.h"
#import "VoletViewControllerInvitationCell.h"
#import "VoletViewControllerNotificationCell.h"
#import "VoletSearchViewController.h"
#import "ProfilViewController.h"
#import "MesReglagesViewController.h"
#import "UserClass+Server.h"

static VoletViewController *actualVoletViewController;

@interface VoletViewController () {
    @private
    BOOL isEmpty;
    BOOL isShowingInvitations;
}

@end

@implementation VoletViewController

@synthesize delegate = _delegate;
@synthesize rootTimeLine = _rootTimeLine;
@synthesize notifications = _notifications;
@synthesize invitations = _invitations;

@synthesize nomUserButton = _nomUserButton, mesActualites = _mesActualites, parametresButton = _parametresButton;
@synthesize sectionView = _sectionView;
@synthesize sectionTitleLabel = _sectionTitleLabel;
@synthesize ttSectionTitleLabel = _ttSectionTitleLabel;
@synthesize tableView = _tableView;

@synthesize buttonsView = _buttonsView;
@synthesize notificationsButton = _notificationsButton;
@synthesize invitationsButton = _invitationsButton;
@synthesize segementShadow = _segementShadow;

@synthesize searchTextField = _searchTextField;
@synthesize searchViewController = _searchViewController;

+ (VoletViewController*)volet {
    return actualVoletViewController;
}

- (id)initWithDDMenuDelegate:(DDMenuController*)delegate withRootTimeLine:(RootTimeLineViewController*)rootTimeLine
{
    self = [super initWithNibName:@"VoletViewController" bundle:nil];
    if(self) {
        self.delegate = delegate;
        self.rootTimeLine = rootTimeLine;
        isEmpty = YES;
        isShowingInvitations = NO;
        self.notifications = [[NSMutableArray alloc] init];
        self.invitations = [[NSMutableArray alloc] init];
        
        // Accès global au volet pour les Push Notifications
        actualVoletViewController = self;
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear - VoletViewController");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear - VoletViewController");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad - VoletViewController");
    // Do any additional setup after loading the view from its nib.
    
    // iPhone 5 support
    CGRect frame = self.view.frame;
    frame.size.height = [[VersionControl sharedInstance] screenHeight] - STATUS_BAR_HEIGHT;
    self.view.frame = frame;
    
    // Buttons View
    frame = self.buttonsView.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.buttonsView.frame = frame;
    
    // Shadow
    frame = self.segementShadow.frame;
    frame.origin.y = self.buttonsView.frame.origin.y - frame.size.height;
    self.segementShadow.frame = frame;
    
    // Nom User
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:15];
    self.nomUserButton.titleLabel.font = font;
    // Mes actualités
    self.mesActualites.titleLabel.font = font;
    // Paramètres
    self.parametresButton.titleLabel.font = font;
    // Mes Moments
    self.mesMoments.titleLabel.font = font;
    
    // TableView
    frame = self.tableView.frame;
    frame.size.height = self.buttonsView.frame.origin.y - frame.origin.y;
    self.tableView.frame = frame;
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_volet.png"]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Section
    font = [[Config sharedInstance] defaultFontWithSize:13];
    self.sectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_section"]];
    self.sectionTitleLabel.font = font;
    self.sectionTitleLabel.text = NSLocalizedString(@"VoletViewController_Section_Notifications", nil);
    
    // Segment
    self.notificationsButton.titleLabel.font = font;
    self.invitationsButton.titleLabel.font = font;
    
    // Nb Notifications / Invitations
    font = [[Config sharedInstance] defaultFontWithSize:12];
    self.nbNotificationsLabel.font = font;
    self.nbInvitationsLabel.font = font;
    [self.invitationsButton addSubview:self.nbInvitationsView];
    [self.notificationsButton addSubview:self.nbNotificationsView];
    
    UIImage *bgNotif = [UIImage imageNamed:@"bg_notif"];
    bgNotif = [[VersionControl sharedInstance] resizableImageFromImage:bgNotif withCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    
    self.nbNotificationsBackground.image = bgNotif;
    self.nbNotificationsBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.nbInvitationsBackground.image = bgNotif;
    self.nbInvitationsBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicInvitations)];
    [self.nbInvitationsView addGestureRecognizer:tap];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicNotifications)];
    [self.nbNotificationsView addGestureRecognizer:tap];
    
    [self reloadUsername];
    [self designNbNotificationsViews];
    
    // Load
    //[self loadNotifications];
}

- (void)reloadUsername
{
    UserClass *user = [UserCoreData getCurrentUser];
    NSString *userName = [NSString stringWithFormat:@"%@ %@", user.prenom?[user.prenom capitalizedString]:@"", user.nom?[user.nom capitalizedString]:@""];;
    [self.nomUserButton setTitle:userName forState:UIControlStateNormal];
    [self.nomUserButton setTitle:userName forState:UIControlStateHighlighted];
    [self.nomUserButton setTitle:userName forState:UIControlStateSelected];
}

- (void)designNbNotificationsViews
{
    const short int height = 19;
    
    CGSize maxSize = CGSizeMake(35, height);
    NSString *texte = nil;
    CGSize expectedSize;
    CGRect frame;
    
    // Notifications
    int taille = [self.notifications count];
    if(taille == 0)
        self.nbNotificationsView.hidden = YES;
    else
    {
        self.nbNotificationsView.hidden = NO;
        texte = [NSString stringWithFormat:@"%d", taille];
        self.nbNotificationsLabel.text = texte;
        expectedSize = [texte sizeWithFont:self.nbNotificationsLabel.font constrainedToSize:maxSize];
        expectedSize.width = MAX(height, expectedSize.width);
        expectedSize.height = height;
        frame.size = expectedSize;
        frame.origin.y = (self.notificationsButton.frame.size.height - height + 1)/2.0;
        frame.origin.x = self.notificationsButton.frame.size.width - (expectedSize.width + 4);
        self.nbNotificationsView.frame = frame;
        frame.origin = CGPointZero;
        self.nbNotificationsLabel.frame = frame;
        self.nbNotificationsBackground.frame = frame;
    }
    
    // Invitations
    taille = [self.invitations count];
    if(taille == 0)
        self.nbInvitationsView.hidden = YES;
    else
    {
        self.nbInvitationsView.hidden = NO;
        texte = [NSString stringWithFormat:@"%d", taille];
        self.nbInvitationsLabel.text = texte;
        expectedSize = [texte sizeWithFont:self.nbInvitationsLabel.font constrainedToSize:maxSize];
        expectedSize.width = MAX(height, expectedSize.width);
        expectedSize.height = height;
        frame.size = expectedSize;
        frame.origin.y = (self.invitationsButton.frame.size.height - height + 1)/2.0;
        frame.origin.x = self.invitationsButton.frame.size.width - (expectedSize.width + 4);
        self.nbInvitationsView.frame = frame;
        frame.origin = CGPointZero;
        self.nbInvitationsLabel.frame = frame;
        self.nbInvitationsBackground.frame = frame;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadNotifications {
    
    [LocalNotificationCoreData getNotificationWithEnded:^(NSDictionary *notifications) {
        //NSLog(@"Notifications reçus : %@", notifications);
        
        // Clear
        [self.notifications removeAllObjects];
        
        // Init notifications
        [self.notifications addObjectsFromArray:notifications[@"notifications"]];
        
        // Update nb labels
        [self designNbNotificationsViews];
        
        [self.tableView reloadData];
        
    }];
    
}

- (void)loadInvitations {
    
    [LocalNotificationCoreData getInvitationsWithEnded:^(NSDictionary *notifications) {
        
        // Clear
        [self.invitations removeAllObjects];
        
        // Init invitations
        [self.invitations addObjectsFromArray:notifications[@"invitations"]];
        
        // Update nb labels
        [self designNbNotificationsViews];
        
        [self.tableView reloadData];
        
    }];
    
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setNotificationsButton:nil];
    [self setInvitationsButton:nil];
    [self setButtonsView:nil];
    [self setSectionView:nil];
    [self setSectionTitleLabel:nil];
    [self setTtSectionTitleLabel:nil];
    [self setSegementShadow:nil];
    [self setNomUserButton:nil];
    [self setSearchTextField:nil];
    [self setMesActualites:nil];
    [self setMesMoments:nil];
    [self setParametresButton:nil];
    [self setNbNotificationsView:nil];
    [self setNbNotificationsLabel:nil];
    [self setNbNotificationsBackground:nil];
    [self setNbInvitationsView:nil];
    [self setNbInvitationsLabel:nil];
    [self setNbInvitationsBackground:nil];
    [super viewDidUnload];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger nb;
    
    if(isShowingInvitations)
        nb = [self.invitations count];
    else
        nb = [self.notifications count];
    
    if(nb == 0) {
        isEmpty = YES;
        self.tableView.scrollEnabled = NO;
        return 1;
    }
    isEmpty = NO;
    self.tableView.scrollEnabled = YES;
    return nb;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VoletViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if(isEmpty){
            cell = [[VoletViewControllerEmptyCell alloc] initWithSize:self.tableView.frame.size.height withStyle:isShowingInvitations];
        }else {
            
            if(isShowingInvitations) {
                cell = [[VoletViewControllerInvitationCell alloc] initWithNotification:self.invitations[indexPath.row]];
            }
            else {
                cell = [[VoletViewControllerNotificationCell alloc] initWithNotification:self.notifications[indexPath.row]];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmpty)
        return self.tableView.frame.size.height;
    return 53.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!isEmpty)
    {
        enum NotificationType type = -1;
        MomentClass *moment = nil;
        
        if(isShowingInvitations) {
            LocalNotificationCoreData *invit = self.invitations[indexPath.row];
            type = invit.type.intValue;
            moment = [invit.moment localCopy];
            // Remove From Local
            [self.invitations removeObject:invit];
            // Remove From Core Data
            [LocalNotificationCoreData deleteNotification:invit];
        }
        else {
            LocalNotificationCoreData *notif = self.notifications[indexPath.row];
            type = notif.type.intValue;
            moment = [notif.moment localCopy];
            // Remove From Local
            [self.notifications removeObject:notif];
            // Remove From Core Data
            [LocalNotificationCoreData deleteNotification:notif];
        }
        
        // Update nb labels
        [self designNbNotificationsViews];
        
        // Reload
        [self.tableView reloadData];
        
        switch (type) {
            case NotificationTypeModification:
                [self redirectToInfoMoment:moment];
                break;
                
            case NotificationTypeNewChat:
                [self redirectToChatMoment:moment];
                break;
                
            case NotificationTypeNewPhoto:
                [self redirectToPhotoMoment:moment];
                break;
                
            case NotificationTypeInvitation:
                [self redirectToInfoMoment:moment];
                break;
                
            default:
                break;
        }
    }
    
}

/*
- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
 */

#pragma mark - Actions

- (IBAction)clicInvitations
{ 
    if(!self.invitationsButton.isSelected) {
        
        [self loadInvitations];
        
        [self.invitationsButton setSelected:YES];
        [self.notificationsButton setSelected:NO];
        
        isShowingInvitations = YES;
        self.sectionTitleLabel.text = NSLocalizedString(@"VoletViewController_Section_Invitations", nil);
        [self.tableView reloadData];
    }
}

- (IBAction)clicNotifications
{
    if(!self.notificationsButton.isSelected) {
        
        [self loadNotifications];
        
        [self.notificationsButton setSelected:YES];
        [self.invitationsButton setSelected:NO];
        
        isShowingInvitations = NO;
        self.sectionTitleLabel.text = NSLocalizedString(@"VoletViewController_Section_Notifications", nil);
        [self.tableView reloadData];
    }
}

- (IBAction)clicUser
{
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:[UserCoreData getCurrentUser]];
    UINavigationController *navController = (UINavigationController*)self.delegate.rootViewController;
    [self.delegate showRootController:NO];
    [navController pushViewController:profil animated:YES];
}

- (IBAction)clicParametres
{
    MesReglagesViewController *reglages = [[MesReglagesViewController alloc] initWithDDMenuDelegate:self.delegate];
    UINavigationController *navController = (UINavigationController*)self.delegate.rootViewController;
    [self.delegate showRootController:NO];
    [navController pushViewController:reglages animated:YES];
}

- (void)selectActualitesButton {
    if(!self.mesActualites.selected) {
        self.mesActualites.selected = YES;
        self.mesMoments.selected = NO;
    }
}

- (void)selectMesMomentsButton {
    if(!self.mesMoments.selected) {
        self.mesMoments.selected = YES;
        self.mesActualites.selected = NO;
    }
}

- (IBAction)clicChangeTimeLine:(UIButton*)sender {
    
    if( (sender == self.mesActualites && !self.mesActualites.selected) || (sender == self.mesMoments && !self.mesMoments.selected) ) {
        [self.delegate showRootController:YES];
        [self.rootTimeLine clicChangeTimeLine];
    }
}

#pragma mark - Redirection vue profonde

- (void)redirectToInfoMoment:(MomentClass*)moment
{
    [self.delegate showRootController:NO];
    [[self.rootTimeLine timeLineForMoment:moment] showInfoMomentView:moment];
}

- (void)redirectToPhotoMoment:(MomentClass*)moment
{
    [self.delegate showRootController:NO];
    [[self.rootTimeLine timeLineForMoment:moment] showPhotoView:moment];
}

- (void)redirectToChatMoment:(MomentClass*)moment
{
    [self.delegate showRootController:NO];
    [[self.rootTimeLine timeLineForMoment:moment] showTchatView:moment];
}


#pragma mark - UITextField Delegate

/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    / *
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = self.searchTextField.frame;
        frame.origin.y = 0;
        self.searchTextField.alpha = 0;
        [self.delegate.navigationController setNavigationBarHidden:YES animated:YES];
        
    } completion:^(BOOL finished) {
        
        VoletSearchViewController *searchViewController = [[VoletSearchViewController alloc] initWithRootViewController:self];
        [self.delegate.navigationController pushViewController:searchViewController animated:NO];
    }];
    * /
    //NSLog(@"pop");
    

}
*/

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.delegate.navigationController.view.layer addAnimation:transition forKey:@"VoletSearchAnimation"];
    [self.delegate.navigationController pushViewController:self.searchViewController animated:NO];
        
    return NO;
}


#pragma mark - DDMenuDelegate

- (void)menuController:(DDMenuController *)controller willShowViewController:(UIViewController *)c
{
    static BOOL isLoading = NO;
    
    // Will Show Volet
    if(c == self)
    {
        // Si les informations du user sont incompletes --> Reload
        UserClass *user = [UserCoreData getCurrentUser];
        if( !isLoading && !(user && user.userId && (user.nom || user.prenom) ))
        {
            isLoading = YES;
            [UserClass getLoggedUserFromServerWithEnded:^(UserClass *user) {
                isLoading = NO;
                [self reloadUsername];
                [self menuController:controller willShowViewController:self];
            }];
        }
        
        // Load Notifs
        [self loadNotifications];
        
        // Reset Notif on Server
        [LocalNotificationCoreData resetNotificationsWithEnded:nil];
        
        // Si il y des Invitations --> Afficher invitations
        if([self.invitations count] > 0) {
            [self clicInvitations];
        }
        // Sinon afficher notifications
        else
            [self clicNotifications];
        
    }
}

#pragma mark - Getters

- (VoletSearchViewController*)searchViewController {
    if(!_searchViewController) {
        _searchViewController = [[VoletSearchViewController alloc] initWithDelegate:self];
    }
    return _searchViewController;
}

#pragma mark - VoletViewController Delegate

- (void)showUserProfileFromVoletSearch:(UserClass*)user
{
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:user];
    
    // Cacher search view controller
    [self.searchViewController clicAnnuler];
    
    // Afficher profil
    [self.delegate showRootController:NO];
    [self.rootTimeLine.navigationController pushViewController:profil animated:YES];
}

- (void)showInfoMomentFromSearch:(MomentClass*)moment
{
    // Cacher search view controller
    [self.searchViewController clicAnnuler];
    
    // Afficher InfoMoment
    [self redirectToInfoMoment:moment];
}

@end
