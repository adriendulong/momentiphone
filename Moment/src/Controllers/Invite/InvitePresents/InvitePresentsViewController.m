//
//  InvitePresentsViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InvitePresentsViewController.h"

#import "InviteAddViewController.h"
#import "CustomNavigationController.h"
#import "ProfilViewController.h"

#import "UserClass+Server.h"
#import "MomentClass+Server.h"

#define HeaderHeight 49

@interface InvitePresentsViewController ()

@end

@implementation InvitePresentsViewController

@synthesize owner = _owner;
@synthesize moment = _moment;
@synthesize invites = _invites;

@synthesize selectedOnglet = _selectedOnglet;
@synthesize comingTableViewController = _comingTableViewController;
@synthesize unknownTableViewController = _unknownTableViewController;
@synthesize maybeTableViewController = _maybeTableViewController;

@synthesize segmentedControl = _segmentedControl;
@synthesize scrollView = _scrollView;

#pragma mark - Init

- (id)initWithOwner:(UserClass*)owner withMoment:(MomentClass *)moment
{
    self = [super initWithNibName:@"InvitePresentsViewController" bundle:nil];
    if(self) {
        self.owner = owner;
        self.moment = moment;
    }
    return self;
}


- (void)initNavigationBar
{
    // ------ Navigation Bar init
    [CustomNavigationController setBackButtonWithViewController:self];
    
    if((self.moment.state.intValue == UserStateAdmin) || ([self.moment.owner.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]))
    {
        // Remove space at right
        UIBarButtonItem *positiveSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        positiveSpace.width = 7;
        
        UIImage *image = [UIImage imageNamed:@"btn_topbar_plus"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,image.size.width, 44)];
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clicInviteMore) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        self.navigationItem.rightBarButtonItems = @[positiveSpace, item];
    }
    
}

- (void)loadContent
{
    // -------- Loading
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
    
    [self.moment getInvitedUsersWithEnded:^(NSDictionary *invites) {
        
        if(invites) {
            self.invites = invites;
            
            // Construction listes
            NSMutableArray *comingList = [[NSMutableArray alloc] init];
            [comingList addObjectsFromArray:self.invites[@"coming"]];
            if(self.invites[@"owner"])
                [comingList addObject:self.invites[@"owner"]];
            [comingList addObjectsFromArray:self.invites[@"admin"]];
            
            // Authorisation
            BOOL authotisation = ((self.moment.state.intValue == UserStateAdmin)||([self.moment.owner.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]));
            
            // Création ViewControllers
            self.comingTableViewController = [[InvitePresentsTableViewController alloc]
                                              initWithOwner:self.owner
                                              withMoment:self.moment
                                              withInvitedUsers:comingList
                                              withAdminAuthoristion:authotisation
                                              navigationController:self.navigationController];
            
            self.maybeTableViewController = [[InvitePresentsTableViewController alloc]
                                             initWithOwner:self.owner
                                             withMoment:self.moment
                                             withInvitedUsers:[NSArray arrayWithArray:self.invites[@"maybe"]]
                                             withAdminAuthoristion:NO
                                             navigationController:self.navigationController];
            
            self.unknownTableViewController = [[InvitePresentsTableViewController alloc]
                                               initWithOwner:self.owner
                                               withMoment:self.moment
                                               withInvitedUsers:[NSArray arrayWithArray:self.invites[@"unknown"]]
                                               withAdminAuthoristion:NO
                                               navigationController:self.navigationController];
            
            // Update tableView
            [self addOngletView:self.comingTableViewController.view rank:InvitePresentsOngletComing];
            [self addOngletView:self.unknownTableViewController.view rank:InvitePresentsOngletUnknown];
            [self addOngletView:self.maybeTableViewController.view rank:InvitePresentsOngletMaybe];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvitePresentsViewController_AlertView_LoadingFail_Title", nil)
                    message:NSLocalizedString(@"InvitePresentsViewController_AlertView_LoadingFail_Message", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                              otherButtonTitles:nil]
             show];
        }
        
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Bar
    [self initNavigationBar];
    
    // iPhone 5 support
    self.view.frame = CGRectMake(0, 0, 320, [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT );
    self.scrollView.frame = CGRectMake(0, HeaderHeight, 320, self.view.frame.size.height - HeaderHeight );
    
    // Segmented Control
    self.segmentedControl = [[CustomSegmentedControl alloc] initWithFrame:CGRectMake(-5, 10, 320, 30)];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    // Update Scroll View Size
    self.scrollView.contentSize = CGSizeMake(320*3, self.scrollView.frame.size.height);
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    [self scrollToOnglet:InvitePresentsOngletComing animated:NO];
    
    // Loading
    [self loadContent];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Util

- (void)placerView:(UIView*)view toOnglet:(enum InvitePresentsOnglet)onglet
{
    CGRect frame = view.frame;
    frame.origin.x = onglet*320;
    frame.origin.y = 0;
    frame.size.height = self.scrollView.frame.size.height;
    view.frame = frame;
}

- (void)addOngletView:(UIView*)view rank:(enum InvitePresentsOnglet)rank
{
    [self placerView:view toOnglet:rank];
    [self.scrollView addSubview:view];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( !((int)scrollView.contentOffset.x%320) ) {
        NSInteger select = scrollView.contentOffset.x/320;
        [self.segmentedControl setSelectedSegmentIndex:select animated:YES];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollToOnglet:(enum InvitePresentsOnglet)onglet animated:(BOOL)animated
{
    // Scroll
    [self.scrollView scrollRectToVisible:CGRectMake(onglet*320, 0, 320, self.scrollView.frame.size.height) animated:animated];
        
    // Update selected onglet
    self.selectedOnglet = onglet;
}

#pragma mark - Actions

- (void)clicInviteMore {
    InviteAddViewController *inviteViewController = [[InviteAddViewController alloc] initWithOwner:self.owner withMoment:self.moment];
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

- (void)segmentedControlChangedValue {
    [self scrollToOnglet:self.segmentedControl.selectedSegmentIndex animated:YES];
}

@end
