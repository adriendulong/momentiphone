//
//  InvitePresentsTableViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InvitePresentsTableViewController.h"
#import "InvitePresentsTableViewCell.h"
#import "InvitePresentsEmptyCell.h"
#import "MomentClass+Server.h"

#define cellHeight 70

@interface InvitePresentsTableViewController () {
    @private
    BOOL isEmpty;
    CGFloat emptyCellSize;
}

@end

@implementation InvitePresentsTableViewController

@synthesize navController = _navController;
@synthesize owner = _owner;
@synthesize moment = _moment;
@synthesize invites = _invites;
@synthesize adminAuthorisation = _adminAuthorisation;

- (id)initWithOwner:(UserClass*)owner
         withMoment:(MomentClass*)moment
   withInvitedUsers:(NSArray*)invites
withAdminAuthoristion:(BOOL)adminAuthorisation
navigationController:(UINavigationController*)navController
{
    self = [super initWithNibName:@"InvitePresentsTableViewController" bundle:nil];
    if(self) {
        self.owner = owner;
        self.moment = moment;
        self.invites = invites;
        isEmpty = !(self.invites && [self.invites count] > 0);
        self.adminAuthorisation = adminAuthorisation;
        self.navController = navController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iPhone 5 support
    [self.tableView sizeToFit];
    emptyCellSize = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT - 49;
        
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int taille = [self.invites count];
    
    // Empty Cell
    if(taille == 0) {
        isEmpty = YES;
        tableView.scrollEnabled = NO;
        return 1;
    }
    
    // Normal Cell
    if(isEmpty) {
        isEmpty = NO;
        tableView.scrollEnabled = YES;
    }
    
    return taille;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    
    // Empty
    if(isEmpty) {
        CellIdentifier = @"InvitePresentsEmptyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[InvitePresentsEmptyCell alloc] initWithSize:emptyCellSize reuseIdentifier:CellIdentifier];
        }
        return cell;
    }
    
    // User
    UserClass *user = self.invites[indexPath.row][@"user"];
    
    // Cell ID
    CellIdentifier = [NSString stringWithFormat:@"InvitePresentsTableViewCell_%@_%@_%@_%@", user.userId, user.facebookId, user.nom, user.prenom];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[InvitePresentsTableViewCell alloc]
                initWithAttributes:self.invites[indexPath.row]
                withIndex:indexPath.row
                withAdmin:self.adminAuthorisation
                withDelegate:self
                reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmpty)
        return emptyCellSize;
    return cellHeight;
}

#pragma mark - InvitePresentsTableViewController Delegate

- (void)updateUserAtRow:(NSInteger)row asAdmin:(BOOL)admin withEnded:( void (^) (BOOL success) )block
{
    [self.moment updateUserWithIdAsAdmin:[[self.invites[row][@"user"] userId] intValue] withEnded:block];
}

@end
