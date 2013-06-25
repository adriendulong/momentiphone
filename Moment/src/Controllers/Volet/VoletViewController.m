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
#import "LocalNotification.h"
#import "Config.h"

#import "VoletViewControllerEmptyCell.h"
#import "VoletViewControllerInvitationCell.h"
#import "VoletViewControllerNotificationCell.h"
#import "VoletSearchViewController.h"
#import "ProfilViewController.h"
#import "MesReglagesViewController.h"
#import "UserClass+Server.h"

#import "EventMissingViewController.h"
#import "RowIndexInVolet.h"

static VoletViewController *actualVoletViewController;

@interface VoletViewController () {
    @private
    BOOL isEmpty;
    BOOL isShowingInvitations;
    int nbNewInvitations;
    int nbNewNotifications;
    int nbNewNotificationsShowing;
}

@end

@implementation VoletViewController

@synthesize delegate = _delegate;
@synthesize rootTimeLine = _rootTimeLine;
@synthesize notifications = _notifications;
@synthesize invitations = _invitations;

@synthesize nomUserButton = _nomUserButton, mesActualites = _mesActualites, parametresButton = _parametresButton, eventMissingButton = _eventMissingButton;
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
        nbNewInvitations = nbNewNotifications = 0;
        
        // Accès global au volet pour les Push Notifications
        actualVoletViewController = self;
        
        //Initialisation du tableau de décompte des lignes des nouvelles notifications.
        RowIndexInVolet *sharedManager = [RowIndexInVolet sharedManager];
        sharedManager.indexNotifications = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    // Event Missing
    self.eventMissingButton.titleLabel.font = font;
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Show Notifications
    if (nbNewNotifications == 0 && nbNewInvitations != 0) {
        [self clicInvitations];
    } else {
        [self clicNotifications];
    }
    
    // Load
    //[self loadInvitations];
}

- (void)reloadUsername
{
    UserClass *user = [UserCoreData getCurrentUser];
    NSString *userName = [user formatedUsernameWithStyle:UsernameStyleCapitalized];
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
    
    RowIndexInVolet *rowIndexInVolet = [RowIndexInVolet sharedManager];
    
    // Notifications
    int taille = nbNewNotifications;//[self.notifications count];
    if(taille == 0)
        self.nbNotificationsView.hidden = YES;
    else
    {
        for (int i=0; i < taille; i++) {
            LocalNotification *notif = [self.notifications objectAtIndex:i];
            
            if (![rowIndexInVolet.indexNotifications containsObject:notif.id_notif]) {
                [rowIndexInVolet.indexNotifications addObject:notif.id_notif];
                
                NSLog(@"count = %i | sharedManager.indexNotifications = %@",[rowIndexInVolet.indexNotifications count], rowIndexInVolet.indexNotifications);
            }
        }
        
        nbNewNotificationsShowing = taille;
        self.nbNotificationsView.hidden = NO;
        texte = [NSString stringWithFormat:@"%i", [rowIndexInVolet.indexNotifications count]];
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
    taille = nbNewInvitations;//[self.invitations count];
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
    
    // Update Badge
    //NSInteger badgeNumber = nbNewInvitations + nbNewNotifications;    
    NSInteger badgeNumber = nbNewInvitations + [rowIndexInVolet.indexNotifications count];
    [[PushNotificationManager sharedInstance] setNbNotifcations:badgeNumber];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadNotifications {
    
    [LocalNotification getNotificationWithEnded:^(NSDictionary *notifications) {
        //NSLog(@"Notifications reçus : %@", notifications);
        
        
        // Clear
        [self.notifications removeAllObjects];
        
        // Init notifications
        [self.notifications addObjectsFromArray:notifications[@"notifications"]];
        
        //NSLog(@"id_notif = %i",[notifications[@"id_notif"] intValue]);
        
        // Update nb labels
        nbNewNotifications = [notifications[@"nb_new_notifs"] intValue];
        nbNewInvitations = [notifications[@"total_notifs"] intValue] - nbNewNotifications;
        
        /*if (nbNewNotifications != 0)
        {
            RowIndexInVolet *sharedManager = [RowIndexInVolet sharedManager];
            if ([sharedManager.indexNotifications count] != 0)
            {
                [sharedManager.indexNotifications removeAllObjects];
            }
        }*/
        
        [self designNbNotificationsViews];
        
        [self.tableView reloadData];
        
    }];
    
}

- (void)loadInvitations {
    
    [LocalNotification getInvitationsWithEnded:^(NSDictionary *notifications) {
        
        // Clear
        [self.invitations removeAllObjects];
        
        // Init invitations
        [self.invitations addObjectsFromArray:notifications[@"invitations"]];
        
        // Update nb labels
        nbNewInvitations = [notifications[@"nb_new_invits"] intValue];
        nbNewNotifications = [notifications[@"total_notifs"] intValue] - nbNewInvitations;
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
    [self setEventMissingButton:nil];
    [super viewDidUnload];
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Volet"
     withAction:action
     withLabel:label
     withValue:value];
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
        } else {
            
            if(isShowingInvitations) {
                cell = [[VoletViewControllerInvitationCell alloc] initWithNotification:self.invitations[indexPath.row]];
            }
            else {
                cell = [[VoletViewControllerNotificationCell alloc] initWithNotification:self.notifications[indexPath.row]];
                
                LocalNotification *notif = [self.notifications objectAtIndex:indexPath.row];
                
                RowIndexInVolet *rowIndexInVolet = [RowIndexInVolet sharedManager];
                if ([rowIndexInVolet.indexNotifications containsObject:notif.id_notif]) {
                     switch (notif.type) {
                     
                         case NotificationTypeModification:
                             ((VoletViewControllerNotificationCell *)cell).pictoView.image = [UIImage imageNamed:@"picto_bulle"];
                             break;
                     
                         case NotificationTypeNewChat:
                             ((VoletViewControllerNotificationCell *)cell).pictoView.image = [UIImage imageNamed:@"picto_message"];
                             break;
                     
                         case NotificationTypeNewPhoto:
                             ((VoletViewControllerNotificationCell *)cell).pictoView.image = [UIImage imageNamed:@"picto_photo"];
                             break;
                     
                         case NotificationTypeNewFollower:
                             ((VoletViewControllerNotificationCell *)cell).pictoView.image = [UIImage imageNamed:@"picto_invite"];
                             break;
                     
                         case NotificationTypeFollowRequest:
                             ((VoletViewControllerNotificationCell *)cell).pictoView.image = [UIImage imageNamed:@"picto_invite"];
                             break;
                     
                         default:
                             break;
                     }
                }
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
        LocalNotification *notif = nil;
        
        if(isShowingInvitations) {
            notif = self.invitations[indexPath.row];
            // Remove From Local
            //[self.invitations removeObject:notif];
        }
        else {
            notif = self.notifications[indexPath.row];
            // Remove From Local
            //[self.notifications removeObject:notif];
        }
        
        // Update nb labels
        //[self designNbNotificationsViews];
        
        // Reload
        //[self.tableView reloadData];
        
        switch (notif.type) {
            case NotificationTypeModification:
                [self redirectToInfoMoment:notif.moment];
                break;
                
            case NotificationTypeNewChat:
                [self redirectToChatMoment:notif.moment];
                break;
                
            case NotificationTypeNewPhoto:
                [self redirectToPhotoMoment:notif.moment];
                break;
                
            case NotificationTypeInvitation:
                [self redirectToInfoMoment:notif.moment];
                break;
                
            case NotificationTypeFollowRequest:
                [self redirectToProfile:notif.requestFollower];
                break;
                
            case NotificationTypeNewFollower:
                [self redirectToProfile:notif.follower];
                break;
            
            default:
                break;
        }
        
        // Passera l'icône en gris après le clic.
        RowIndexInVolet *rowIndexInVolet = [RowIndexInVolet sharedManager];
        
        if ([rowIndexInVolet.indexNotifications containsObject:notif.id_notif])
            [rowIndexInVolet.indexNotifications removeObject:notif.id_notif];
    }
}

#pragma mark - Actions

- (IBAction)clicInvitations
{
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Invitations Volet" value:nil];
    
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
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Notifications Volet" value:nil];
    
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
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Profil" value:nil];
    
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:[UserCoreData getCurrentUser]];
    UINavigationController *navController = (UINavigationController*)self.delegate.rootViewController;
    [self.delegate showRootController:NO];
    [navController pushViewController:profil animated:YES];
}

- (IBAction)clicParametres
{
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Paramètres" value:nil];
    
    MesReglagesViewController *reglages = [[MesReglagesViewController alloc] initWithDDMenuDelegate:self.delegate];
    UINavigationController *navController = (UINavigationController*)self.delegate.rootViewController;
    [self.delegate showRootController:NO];
    [navController pushViewController:reglages animated:YES];
}

- (IBAction)clicEventMissing
{
    EventMissingViewController *eventMissing = [[EventMissingViewController alloc] initWithDDMenuDelegate:self.delegate];
    UINavigationController *navController = (UINavigationController*)self.delegate.rootViewController;
    [self.delegate showRootController:NO];
    [navController pushViewController:eventMissing animated:YES];
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
    
    // Identification du bouton
    BOOL actualitesButton = (sender == self.mesActualites) && (!self.mesActualites.selected);
    BOOL momentsButton = (sender == self.mesMoments) && (!self.mesMoments.selected);
    
    // Google Analytics
    if(actualitesButton) {
        [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Actualités" value:nil];
    }
    else if(momentsButton) {
        [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Moments" value:nil];
    }
    
    // Change TimeLine
    if( actualitesButton || momentsButton ) {
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

- (void)redirectToProfile:(UserClass*)user
{
    if(user) {
        [self.delegate showRootController:NO];
        
        ProfilViewController *profile = [[ProfilViewController alloc] initWithUser:user];
        [self.rootTimeLine.navController pushViewController:profile animated:YES];
    }
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
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Recherche" value:nil];
    
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
        // Google Analytics
        [[[GAI sharedInstance] defaultTracker]
         sendEventWithCategory:@"Timeline"
         withAction:@"Clic Bouton"
         withLabel:@"Clic Volet"
         withValue:nil];
        
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
        //[self loadNotifications];
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
