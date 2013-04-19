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


- (id)initWithMoment:(MomentClass*)moment withOnglet:(enum OngletRank)onglet
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
                    self.moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes];
                    self.photoViewController.moment = moment;
                    self.infoMomentViewController.moment = moment;
                    self.chatViewController.moment = moment;
                    [self.infoMomentViewController reloadData];
                }];
            }
        }
        
        self.user = [UserCoreData getCurrentUser];
        self.selectedOnglet = onglet;
        viewHeight = [[VersionControl sharedInstance] screenHeight] - TOPBAR_HEIGHT;
        self.shouldShowInviteViewController = NO;
        //self.timeLine = timeLine;
        
        // Update state (Unknown -> Maybe)
        if(self.moment.state.intValue == UserStateUnknown) {
            [self.moment updateCurrentUserState:UserStateWaiting withEnded:nil];
        }
        
    }
    return self;
}

- (void)updateShouldShowInviteViewController {
    NSLog(@"update show invite");
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
            self.infoButton.selected = YES;
            self.chatButton.selected = NO;
            self.photoButton.selected = NO;
            break;
            
        case OngletChat:
            self.infoButton.selected = NO;
            self.chatButton.selected = YES;
            self.photoButton.selected = NO;
            break;
            
        case OngletPhoto:
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
            if(!_photoViewController)
                [self addOngletView:self.photoViewController.view rank:OngletPhoto];
            if(!_chatViewController)
                [self addOngletView:self.chatViewController.view rank:OngletChat];
             
            break;
            
        case OngletPhoto:
            if(!_photoViewController)
                [self addOngletView:self.photoViewController.view rank:onglet];
            break;
            
        case OngletChat:
            if(!_chatViewController)
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
            break;
        case OngletPhoto:
            if(!_photoViewController)
                [self addOngletView:self.photoViewController.view rank:onglet];
            [AppDelegate updateActualViewController:self.photoViewController];
            break;
        case OngletChat:
            if(!_chatViewController)
                [self addOngletView:self.chatViewController.view rank:onglet];
            [AppDelegate updateActualViewController:self.chatViewController];
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

#pragma mark - NavigationBar Buttons Actions

- (IBAction)clicNavigationBarButtonInfos {
    //NSLog(@"NavigationBar Button Infos");
            
    [self addAndScrollToOnglet:OngletInfoMoment];
}

- (IBAction)clicNavigationBarButtonPhoto {
    //NSLog(@"NavigationBar Button Photo");
    
    // Si on passe passe par l'onglet info, on l'alloue
    if( self.selectedOnglet == OngletChat )
        [self addOnglet:OngletInfoMoment];
    
    [self addAndScrollToOnglet:OngletPhoto];
}

- (IBAction)clicNavigationBarButtonChat {
    //NSLog(@"NavigationBar Button Tchat");
     
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
}

- (void)viewWillDisappear:(BOOL)animated
{
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
        NSInteger select = scrollView.contentOffset.x/320;
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

@end
