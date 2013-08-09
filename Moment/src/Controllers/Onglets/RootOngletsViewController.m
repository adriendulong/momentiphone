//
//  RootOngletsViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "RootOngletsViewController.h"
#import "InviteAddViewController.h"
#import "UserCoreData+Model.h"
#import "MomentClass+Server.h"
#import "Config.h"

@implementation RootOngletsViewController

@synthesize moment = _moment;
@synthesize user = _user;
@synthesize selectedOnglet = _selectedOnglet;

@synthesize navBarRigthButtonsView = _navBarRigthButtonsView;
@synthesize infoButton = _infoButton;
@synthesize chatButton = _chatButton;
@synthesize photoButton = _photoButton;

@synthesize photoViewController = _photoViewController;
@synthesize infoMomentViewController = _infoMomentViewController;
@synthesize chatViewController = _chatViewController;

@synthesize scrollView = _scrollView;

@synthesize roundRectButtonPopTipView = _roundRectButtonPopTipView;
@synthesize poptipChat = _poptipChat, poptipPhotos = _poptipPhotos;


- (id)initWithMoment:(MomentClass*)moment
          withOnglet:(enum OngletRank)onglet
        withTimeLine:(UIViewController <TimeLineDelegate>*)timeLine;
{
    self = [super initWithNibName:@"RootOngletsViewController" bundle:nil];
    if(self) {
        
        self.moment = moment;
        
        // Si les infos du moment sont incompletes -> on les retélécharge
        if( !(self.moment && self.moment.momentId && self.moment.titre && self.moment.adresse && self.moment.descriptionString) )
        {
            if(self.moment.momentId)
            {
                [MomentClass getInfosMomentWithId:self.moment.momentId.intValue withEnded:^(NSDictionary *attributes) {
                    
                    if (attributes != nil) {
                        self.moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes];
                        self.photoViewController.moment = self.moment;
                        self.infoMomentViewController.moment = self.moment;
                        self.chatViewController.moment = self.moment;
                        [self.infoMomentViewController reloadData];
                    }
                }];
            }
        }
        
        self.user = [UserCoreData getCurrentUser];
        self.selectedOnglet = onglet;
        viewHeight = [[VersionControl sharedInstance] screenHeight] - TOPBAR_HEIGHT;
        self.shouldShowInviteViewController = NO;
        self.timeLine = timeLine;
        
        // Update state (Unknown -> Maybe)
        if(self.moment.state.intValue == UserStateUnknown) {
            [self.moment updateCurrentUserState:UserStateWaiting withEnded:nil];
        }
        
    }
    return self;
}

- (void)updateShouldShowInviteViewController {
    //NSLog(@"update show invite");
    self.shouldShowInviteViewController = YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
}

- (void)selectNavigationBarButton:(enum OngletRank)rank
{
    switch (rank) {
        case OngletInfoMoment:
            
            // Google Analytics
            [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Icone Infos" value:nil];
            
            self.infoButton.selected = YES;
            self.chatButton.selected = NO;
            self.photoButton.selected = NO;
            break;
            
        case OngletChat:
            
            // Google Analytics
            [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Icone Chat" value:nil];
            
            self.infoButton.selected = NO;
            self.chatButton.selected = YES;
            self.photoButton.selected = NO;
            break;
            
        case OngletPhoto:
            
            // Google Analytics
            [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Icone Photos" value:nil];
            
            self.infoButton.selected = NO;
            self.chatButton.selected = NO;
            self.photoButton.selected = YES;
            break;
    }
    
}

#pragma mark - Util

- (void)placerView:(UIView*)view toOnglet:(enum OngletRank)onglet
{
    CGRect frame = view.frame;
    frame.origin.x = onglet*320;
    view.frame = frame;
}

- (void)addOngletView:(UIView*)view rank:(enum OngletRank)rank
{
    [self placerView:view toOnglet:rank];
    [self.scrollView addSubview:view];
}

- (void)addOnglet:(enum OngletRank)onglet
{
    // On préload la vue du milieu
    if(!_infoMomentViewController)
        [self addOngletView:self.infoMomentViewController.view rank:OngletInfoMoment];
    
    switch (onglet) {
            
        case OngletInfoMoment:
            /*
            if(!_infoMomentViewController)
                [self addOngletView:self.infoMomentViewController.view rank:OngletInfoMoment];
             */
            
            // Préload Vue de Droite et Gauche
            if( (!_photoViewController) || (![self.photoViewController.view isDescendantOfView:self.scrollView]) )
                [self addOngletView:self.photoViewController.view rank:OngletPhoto];
            if( (!_chatViewController) || (![self.chatViewController.view isDescendantOfView:self.scrollView]) )
                [self addOngletView:self.chatViewController.view rank:OngletChat];
             
            break;
            
        case OngletPhoto:
            if( (!_photoViewController) || (![self.photoViewController.view isDescendantOfView:self.scrollView]) )
                [self addOngletView:self.photoViewController.view rank:onglet];
            break;
            
        case OngletChat:
            if( (!_chatViewController) || (![self.chatViewController.view isDescendantOfView:self.scrollView]) )
                [self addOngletView:self.chatViewController.view rank:onglet];
            break;
    }
}

- (void)scrollToOnglet:(enum OngletRank)onglet animated:(BOOL)animated
{
    [self.scrollView scrollRectToVisible:CGRectMake(onglet*320, 0, 320, viewHeight) animated:animated];
    
    // On garde une trace de la vue sur laquelle on est pour une redirection lors d'une push notifiation
    switch (onglet) {
        case OngletInfoMoment:
            if(!_infoMomentViewController)
                [self addOngletView:self.infoMomentViewController.view rank:onglet];
            [AppDelegate updateActualViewController:self.infoMomentViewController];
            [self.infoMomentViewController sendGoogleAnalyticsView];
            break;
        case OngletPhoto:
            if(!_photoViewController)
                [self addOngletView:self.photoViewController.view rank:onglet];
            [AppDelegate updateActualViewController:self.photoViewController];
            [self.photoViewController sendGoogleAnalyticsView];
            break;
        case OngletChat:
            if(!_chatViewController)
                [self addOngletView:self.chatViewController.view rank:onglet];
            [AppDelegate updateActualViewController:self.chatViewController];
            [self.chatViewController sendGoogleAnalyticsView];
            break;
    }
    
}

- (void)automaticScroll
{
    [self scrollToOnglet:self.selectedOnglet animated:YES];
}

- (void)addAndScrollToOnglet:(enum OngletRank)onglet
{
    [self selectNavigationBarButton:onglet];
    [self addOnglet:onglet];
    self.selectedOnglet = onglet;
    [self automaticScroll];
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Infos"
     withAction:action
     withLabel:label
     withValue:value];
}

#pragma mark - NavigationBar Buttons Actions

- (IBAction)clicNavigationBarButtonInfos {
    //NSLog(@"NavigationBar Button Infos");
            
    [self addAndScrollToOnglet:OngletInfoMoment];
}

- (IBAction)clicNavigationBarButtonPhoto {
    //NSLog(@"NavigationBar Button Photo");
    
    if (self.poptipPhotos) {
        [self dismissPopTipViewPhotosAnimated:YES];
    }
    
    // Si on passe passe par l'onglet info, on l'alloue
    if( self.selectedOnglet == OngletChat ) {
        [self addOnglet:OngletInfoMoment];
    }
    
    [self addAndScrollToOnglet:OngletPhoto];
}

- (IBAction)clicNavigationBarButtonChat {
    //NSLog(@"NavigationBar Button Tchat");
    
    if (self.poptipChat) {
        [self dismissPopTipViewChatAnimated:YES];
    }
    
    // Si on passe passe par l'onglet info, on l'alloue
    if( self.selectedOnglet == OngletPhoto )
        [self addOnglet:OngletInfoMoment];
    
    [self addAndScrollToOnglet:OngletChat];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // NavigationBar initialisation
    [self initNavigationBar];
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    self.scrollView.frame = frame;
    
    // ScrollView
    self.scrollView.contentSize = CGSizeMake(3*320, viewHeight);
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"] ];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self scrollToOnglet:self.selectedOnglet animated:NO];
    [self addOnglet:self.selectedOnglet];    
    
    //Premier lancement de l'application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasRunOncePopTipOnMoment = [defaults boolForKey:@"hasRunOncePopTipOnMoment"];
    
    if (!hasRunOncePopTipOnMoment)
    {
        [self showPopTipViewPhotos];
        [self hasRunOncePopTipOnMoment];
    }
}

- (void)hasRunOncePopTipOnMoment
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasRunOncePopTipOnMoment = [defaults boolForKey:@"hasRunOncePopTipOnMoment"];
    
    if (!hasRunOncePopTipOnMoment)
    {
        [defaults setBool:YES forKey:@"hasRunOncePopTipOnMoment"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.shouldShowInviteViewController) {
        self.shouldShowInviteViewController = NO;
        InviteAddViewController *inviteViewController = [[InviteAddViewController alloc] initWithOwner:self.user withMoment:self.moment];
        [self.navigationController pushViewController:inviteViewController animated:NO];
    }
    [self.infoMomentViewController reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.roundRectButtonPopTipView)
    {
        NSLog(@"roundRectButtonPopTipView activée ! On la vire...");
        [self dismissAnyPopTipViewAnimated:YES];
    }
    
    [self.scrollView endEditing:YES];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Setters & Getters

- (InfoMomentViewController*)infoMomentViewController {
    if(!_infoMomentViewController) {
        _infoMomentViewController = [[InfoMomentViewController alloc] initWithMoment:self.moment withRootViewController:self];
    }
    return _infoMomentViewController;
}

- (PhotoViewController*)photoViewController {
    
    if(!_photoViewController) {
        _photoViewController = [[PhotoViewController alloc]
                                initWithMoment:self.moment
                                withRootViewController:self
                                withSize:self.scrollView.frame.size];
    }
    return _photoViewController;
}

- (ChatViewController*)chatViewController {
    if(!_chatViewController) {
        _chatViewController = [[ChatViewController alloc] initWithMoment:self.moment withRootViewController:self];
    }
    return _chatViewController;
}

#pragma mark - UIScrollView Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
     const int marge = 30;
     
     // selec*32O <= x <= marge + selec*32O
     BOOL bordGauche = (self.selectedOnglet*320 + 1 < scrollView.contentOffset.x) && (scrollView.contentOffset.x < marge + self.selectedOnglet*320 - 1);
     // 320$(selec+1) - marge <= x <= 320*(selec+1)
     BOOL bordDroit = (320*(self.selectedOnglet+1) - marge + 1 < scrollView.contentOffset.x ) && (scrollView.contentOffset.x < 320*(self.selectedOnglet+1) - 1);
     
     if(bordDroit)
     NSLog(@"bordDroit");
     if(bordGauche)
     NSLog(@"bordGauche");
     
     // Si on est sur la droite ou la gauche d'un écran
     if( (bordDroit && (self.selectedOnglet < 2)) || (bordGauche && (self.selectedOnglet>0)) ) {
     
     NSInteger select = bordDroit? self.selectedOnglet+1 : self.selectedOnglet-1;
     [self addAndScrollToOnglet:select];
     
     // Si le bouton expand de la vue info moment est encore développé, on le referme
     if( (self.selectedOnglet != OngletInfoMoment) && (self.infoMomentViewController.expandButton.isShowed) ) {
     [self.infoMomentViewController.expandButton hideButtons];
     }
     
     }
     */
    
    if( !((int)scrollView.contentOffset.x%320) ) {
        
        // Next Onglet
        NSInteger select = scrollView.contentOffset.x/320;
        
        // Google Analytics
        switch (self.selectedOnglet) {
            case OngletInfoMoment:
                if(select == OngletPhoto) {
                    [self sendGoogleAnalyticsEvent:@"Swipe" label:@"Swipe Infos vers Photo" value:nil];
                } else if(select == OngletChat) {
                    [self sendGoogleAnalyticsEvent:@"Swipe" label:@"Swipe Infos vers Chat" value:nil];
                }
                break;
                
            case OngletChat:
                if(select == OngletInfoMoment)
                    [self sendGoogleAnalyticsEvent:@"Swipe" label:@"Swipe Chat vers Infos" value:nil];
                break;
                
            case OngletPhoto:
                if(select == OngletInfoMoment)
                    [self sendGoogleAnalyticsEvent:@"Swipe" label:@"Swipe Photo vers Infos" value:nil];
                break;
        }
        
        // Change Onglet
        [self addAndScrollToOnglet:select];
        
        // Si le bouton expand de la vue info moment est encore développé, on le referme
        if( (self.selectedOnglet != OngletInfoMoment) && (self.infoMomentViewController.expandButton.isShowed) ) {
            [self.infoMomentViewController.expandButton hideButtons];
        }
    }
    /*
    // Si on est en train de scroller
    else
    {
        // Si on scroll vers le Chat
        if(scrollView.contentOffset.x > 2*320)
            [self addOnglet:OngletChat];
        // Si on scroll vers les photos
        else if(scrollView.contentOffset.x < 320)
            [self addOnglet:OngletPhoto];
    }
    */
    
    [scrollView endEditing:YES];
}

#pragma mark CMPopTipView
- (void)spawnPopTipViewWithFrame:(CGRect)frame withMessage:(NSString *)message andBackgroundColor:(UIColor *)bgColor andBorderColor:(UIColor *)bdColor andTextColor:(UIColor *)txtColor andFontSize:(CGFloat)fontsize
{
    // Toggle popTipView when a standard UIButton is pressed
    if (nil == self.roundRectButtonPopTipView) {
        CMPopTipView *poptipview = [[CMPopTipView alloc] initWithMessage:message];
        poptipview.delegate = self;
        poptipview.backgroundColor = bgColor;
        poptipview.textFont = [[Config sharedInstance] defaultFontWithSize:fontsize];
        poptipview.textColor = txtColor;
        poptipview.borderColor = bdColor;
        poptipview.has3DStyle = NO;
        poptipview.hasShadow = YES;
        
        UIView *spawnView = [[UIView alloc] initWithFrame:frame];
        spawnView.backgroundColor = [UIColor redColor];
        
        [self.view addSubview:spawnView];
        
        self.roundRectButtonPopTipView = poptipview;
        
        [self.roundRectButtonPopTipView presentPointingAtView:spawnView inView:self.view animated:YES];
    }
    else {
        // Dismiss
        [self dismissAnyPopTipViewAnimated:YES];
    }
}

- (void)showPopTipViewPhotos
{
    [self spawnPopTipViewWithFrame:CGRectMake(183, -44, 46, 44)
                       withMessage:NSLocalizedString(@"RootOngletsViewController_PopTipViewPhotos_Message", nil)
                andBackgroundColor:[UIColor colorWithHex:0xE7E7E7]
                    andBorderColor:[UIColor colorWithHex:0xC1C1C1]
                      andTextColor:[UIColor colorWithHex:0xD28000]
                       andFontSize:12];
    
    self.poptipPhotos = YES;
    [self.roundRectButtonPopTipView autoDismissAnimated:YES atTimeInterval:5];
}
- (void)showPopTipViewChat
{
    [self spawnPopTipViewWithFrame:CGRectMake(298, -44, 46, 44)
                       withMessage:NSLocalizedString(@"RootOngletsViewController_PopTipViewChat_Message", nil)
                andBackgroundColor:[UIColor colorWithHex:0xE7E7E7]
                    andBorderColor:[UIColor colorWithHex:0xC1C1C1]
                      andTextColor:[UIColor colorWithHex:0xD28000]
                       andFontSize:12];
    
    self.poptipChat = YES;
    [self.roundRectButtonPopTipView autoDismissAnimated:YES atTimeInterval:5];
}

- (void)dismissPopTipViewPhotosAnimated:(BOOL)animated
{
    [self.roundRectButtonPopTipView dismissAnimated:animated];
    self.roundRectButtonPopTipView = nil;
    
    self.poptipPhotos = NO;
    
    [self showPopTipViewChat];
}

- (void)dismissPopTipViewChatAnimated:(BOOL)animated
{
    if (self.roundRectButtonPopTipView) {
        [self.roundRectButtonPopTipView dismissAnimated:animated];
        self.roundRectButtonPopTipView = nil;
        
        self.poptipChat = NO;
    }
}

- (void)dismissAnyPopTipViewAnimated:(BOOL)animated
{
    if (self.roundRectButtonPopTipView) {
        [self.roundRectButtonPopTipView dismissAnimated:animated];
        self.roundRectButtonPopTipView = nil;
        
        self.poptipPhotos = NO;
        self.poptipChat = NO;
    }
}

#pragma mark CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    // User can tap CMPopTipView to dismiss it
    
    if (self.poptipPhotos) {
        [self dismissPopTipViewPhotosAnimated:YES];
    } else if (!self.poptipPhotos && self.poptipChat) {
        [self dismissPopTipViewChatAnimated:YES];
    } else {
        [self dismissAnyPopTipViewAnimated:YES];
    }
}

@end
