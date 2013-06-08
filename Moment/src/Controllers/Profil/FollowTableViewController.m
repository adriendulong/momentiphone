//
//  FollowTableViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FollowTableViewController.h"
#import "FollowTableViewCell.h"
#import "UserClass+Server.h"
#import "Config.h"

@interface FollowTableViewController () {
    @private
    CGRect tempFrame;
    BOOL isEmpty;
}

@end

@implementation FollowTableViewController

@synthesize owner = _owner;
@synthesize users = _users;
@synthesize style = _style;
@synthesize navController = _navController;

- (id)initWithOwner:(UserClass*)owner
          withFrame:(CGRect)frame
          withStyle:(enum FollowTableViewStyle)style
    navigationController:(UINavigationController*)navController
{
    self = [super initWithNibName:@"FollowTableViewController" bundle:nil];
    if(self) {
        self.users = @[];
        self.owner = owner;
        tempFrame = frame;
        self.style = style;
        self.navController = navController;
        isEmpty = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = tempFrame;
    self.tableView.frame = self.view.frame;
    
    // Load
    [self loadUsersList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setUsers:nil];
    [self setNavController:nil];
    [self setOwner:nil];
    [super viewDidUnload];
}

#pragma mark - Load

- (void)loadUsersListWithEnded:(void (^) (void))block
{
    if(!block)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
    }
    
    switch (self.style) {
            
            // Load Follows
        case FollowTableViewStyleFollow: {
            
            [self.owner getFollowsWithEnded:^(NSArray *follows) {
                
                self.users = follows;
                [self.tableView reloadData];
                
                if(block)
                    block();
                else
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            
        }  break;
            
            // Load Followers
        case FollowTableViewStyleFollower: {
            
            [self.owner getFollowersWithEnded:^(NSArray *followers) {
                                
                self.users = followers;
                [self.tableView reloadData];
                
                if(block)
                    block();
                else
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            
        }   break;
    }
}

- (void)loadUsersList {
    [self loadUsersListWithEnded:nil];
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
    int taille = [self.users count];
    if(taille == 0) {
        isEmpty = YES;
        tableView.scrollEnabled = NO;
        return 1;
    }
    isEmpty = NO;
    tableView.scrollEnabled = YES;
    return taille;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse Identifier --> unique id of cell
    NSString *reuseIdentifier = nil;
    UITableViewCell *cell = nil;
    
    // Empty
    if(isEmpty)
    {
        reuseIdentifier = @"FollowTableViewController_EmptyCell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            CGRect frame = cell.frame;
            frame.size = tableView.frame.size;
            cell.frame = frame;
            UILabel *label = [[UILabel alloc] init];
            label.text = (self.style == FollowTableViewStyleFollow) ? NSLocalizedString(@"FollowTableViewController_Follows_EmptyCellLabel", nil) : NSLocalizedString(@"FollowTableViewController_Followers_EmptyCellLabel", nil);
            label.backgroundColor = [UIColor clearColor];
            label.font = [[Config sharedInstance] defaultFontWithSize:14];
            label.textColor = [Config sharedInstance].textColor;
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            frame = cell.frame;
            frame.size.width -= 30;
            frame.origin.x = (cell.frame.size.width - frame.size.width)/2.0;
            frame.origin.y = 0;
            label.frame = frame;
            [cell addSubview:label];
        }
        
    }
    else
    {
        reuseIdentifier = [NSString stringWithFormat:@"FollowTableViewCell_%d_%d_%@_%@", self.style, indexPath.row, [self.users[indexPath.row] prenom], [self.users[indexPath.row] nom]];
        
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        if(cell == nil)
        {
            // Create
            cell = [[FollowTableViewCell alloc]
                    initWithUser:self.users[indexPath.row]
                    withIndex:indexPath.row
                    reuseIdentifier:reuseIdentifier
                    navigationController:self.navController];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmpty)
        return tableView.frame.size.height;
    return 50.0f;
}


@end
