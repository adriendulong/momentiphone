//
//  Cagnotte3ViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Cagnotte3ViewController.h"
#import "ProfilViewController.h"
#import "Config.h"
#import "Cagnotte3TableViewCell.h"
#import "UserClass+Server.h"
#import "Cagnotte4ViewController.h"

@interface Cagnotte3ViewController () {
    @private
    BOOL isEmpty;
}
@end

@implementation Cagnotte3ViewController

@synthesize parametres = _parametres;
@synthesize invites = _invites;
@synthesize users = _users;
@synthesize bandeauView = _bandeauView;
@synthesize bandeauLabel = _bandeauLabel;
@synthesize tableView = _tableView;
@synthesize inviteAllButton = _inviteAllButton;

- (id)initParametres:(NSMutableDictionary *)parametres
{
    self = [super initWithNibName:@"Cagnotte3ViewController" bundle:nil];
    if (self) {
        self.parametres = parametres;
        self.invites = [[NSMutableArray alloc] init];
        isEmpty = YES;
        
        [CustomNavigationController setBackButtonWithViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    frame = self.tableView.frame;
    frame.origin.y = 98;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.tableView.frame = frame;
    
    // Bandeau
    self.bandeauView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_panier"]];
    self.bandeauView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicBandeau)];
    [self.bandeauView addGestureRecognizer:tap];
    
    // Load
    [self loadInvites];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setInviteAllButton:nil];
    [self setParametres:nil];
    [self setInvites:nil];
    [self setBandeauLabel:nil];
    [self setBandeauView:nil];
    [super viewDidUnload];
}

#pragma mark - Cagnotte 3 Delegate

- (void)clicProfile:(UserClass*)user {
    if(user) {
        ProfilViewController *profile = [[ProfilViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:profile animated:YES];
    }
}

- (void)toggleSwitch:(BOOL)on user:(UserClass*)user {
    if(user)
    {
        if(on) {
            if(![self.invites containsObject:user])
                [self.invites addObject:user];
        }
        else {
            [self.invites removeObject:user];
        }
        
        // Find user in array and update
        for(NSMutableDictionary *dico in self.users) {
            if(dico[@"user"] && [user isEqual:dico[@"user"]]) {
                dico[@"switch"] = @(on);
                break;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int taille = [self.users count];
    if(taille == 0) {
        isEmpty = YES;
        self.tableView.scrollEnabled = NO;
        self.inviteAllButton.enabled = NO;
        return 1;
    }
    isEmpty = NO;
    self.tableView.scrollEnabled = YES;
    self.inviteAllButton.enabled = YES;
    return taille;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *CellIdentifier = nil;
    if(isEmpty) {
        CellIdentifier = @"Cagnotte3TableViewCell_Empty";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = cell.frame;
            frame.size = self.tableView.frame.size;
            cell.frame = frame;
            
            UILabel *label = [[UILabel alloc] init];
            label.text = NSLocalizedString(@"Cagnotte3ViewController_EmptyCell", nil);
            label.backgroundColor = [UIColor clearColor];
            label.font = [[Config sharedInstance] defaultFontWithSize:14];
            label.textColor = [Config sharedInstance].textColor;
            [label sizeToFit];
            frame = label.frame;
            frame.origin.x = (cell.frame.size.width - frame.size.width)/2.0;
            frame.origin.y = (cell.frame.size.height - frame.size.height)/4.0;
            label.frame = frame;
            [cell addSubview:label];
        }
    }
    else {
        
        NSMutableDictionary* user = self.users[indexPath.row];
        // Cell ID
        CellIdentifier = [NSString stringWithFormat:@"Cagnotte3TableViewCell_%@", [user[@"user"] userId]];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[Cagnotte3TableViewCell alloc] initWithUser:user
                                                       delegate:self
                                                          index:indexPath.row
                                                reuseIdentifier:CellIdentifier];
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmpty)
        return self.tableView.frame.size.height;
    
    return 50.0f;
}

#pragma mark - Load

- (void)loadInvites
{
    // -------- Loading
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);

    [UserClass getInvitedUsersToMoment:self.parametres[@"moment"] withAdminEncapsulation:NO withEnded:^(NSDictionary *invites) {
        
        if(invites) {
            
            // Construction listes
            NSMutableArray *comingList = [[NSMutableArray alloc] init];
            [comingList addObjectsFromArray:invites[@"coming"]];
            if(invites[@"owner"])
                [comingList addObject:invites[@"owner"]];
            [comingList addObjectsFromArray:invites[@"admin"]];
            
            // Encapsulation des users dans dictionnaire avec les attributs:
            // - "user" -> UserClass
            // - "switch" -> BOOL -> indique si le user est déjà ajouté ou non
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[comingList count]];
            for(UserClass *user in comingList) {
                if(user)
                    [array addObject:@{@"user":user, @"switch":@(NO)}.mutableCopy];
            }
            
            self.users = array;
            [self.tableView reloadData];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvitePresentsViewController_AlertView_LoadingFail_Title", nil)
                                        message:NSLocalizedString(@"InvitePresentsViewController_AlertView_LoadingFail_Message", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                              otherButtonTitles:nil]
             show];
        }
        
    }];
}

#pragma mark - Actions

- (void)clicBandeau {
    if([self.invites count] > 0) {
        self.parametres[@"participants"] = self.invites;
        
        Cagnotte4ViewController *lastStep = [[Cagnotte4ViewController alloc] initWithParametres:self.parametres];
        [self.navigationController pushViewController:lastStep animated:YES];
    }
}

- (IBAction)clicSelectAll {
    
    if(!isEmpty)
    {
        NSInteger count = [self.users count];
        for(unsigned short int i = 0; i<count; i++) {
            
            Cagnotte3TableViewCell *cell = (Cagnotte3TableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            if(!cell.switchButton.on) {
                
                NSMutableDictionary *dico = self.users[i];
                dico[@"switch"] = @(YES);
                
                if( dico[@"user"] && ![self.invites containsObject:dico[@"user"]]) {
                    [self.invites addObject:dico[@"user"]];
                }
                
                [cell.switchButton setOn:YES animated:YES];
            }
        }
    }
}

@end
