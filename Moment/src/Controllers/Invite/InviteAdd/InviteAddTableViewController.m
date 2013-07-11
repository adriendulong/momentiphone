//
//  InviteAddTableViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InviteAddTableViewController.h"
#import "InviteAddTableViewCell.h"
#import "CustomNavigationController.h"
#import "InviteAddTableViewCellEmpty.h"

#import "AddressBookManager.h"
#import "FacebookManager.h"

#import "Config.h"
#import "UserClass+Server.h"
#import "UserClass+Mapping.h"

#define headerSize 100

@interface InviteAddTableViewController () {
    @private
    CGFloat emptyCellSize;
    BOOL isEmpty;
    
    BOOL notifSelectedFriends;
}

@end

@implementation InviteAddTableViewController

@synthesize owner = _owner;
@synthesize delegate = _delegate;

@synthesize inviteTableViewStyle = _inviteTableViewStyle;
@synthesize friends = _friends;
@synthesize visibleFriends = _visibleFriends;

- (id)initWithOwner:(UserClass*)owner withDelegate:(UIViewController <InviteAddViewControllerDelegate> *)delegate withStyle:(enum InviteAddTableViewControllerStyle)style
{
    self = [super initWithNibName:@"InviteAddTableViewController" bundle:nil];
    if(self) {
        self.owner = owner;
        self.friends = @[];
        self.visibleFriends = self.friends;
        self.inviteTableViewStyle = style;
        self.delegate = delegate;
        notifSelectedFriends = (style != InviteAddTableViewControllerFavorisStyle);
        isEmpty = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iPhone 5 support
    //self.tableView.frame = CGRectMake(0,0,320, [VersionControl sharedInstance].screenHeight - 58 );
    [self.tableView sizeToFit];
    emptyCellSize = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT - headerSize;
    
    /*
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.canCancelContentTouches = YES;
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    self.friends = nil;
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
    NSInteger nb = [self.visibleFriends count];
    if(nb == 0) {
        isEmpty = YES;
        return 1;
    }
    isEmpty = NO;
    return nb;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    
    // Empty Cell
    if(isEmpty) {
        CellIdentifier = @"InviteAddTableViewCellEmpty";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
            cell = [[InviteAddTableViewCellEmpty alloc] initWithSize:emptyCellSize
                                                     reuseIdentifier:CellIdentifier
                                                               style:self.inviteTableViewStyle];
        return cell;
    }
    
    
    // User
    UserClass *user = self.visibleFriends[indexPath.row][@"user"];
    UITableViewCell *cell = nil;
    
    // Si on est en train de créé un user
    if( !(user.userId || user.facebookId || user.nom || user.prenom) ) {
        // On recréé les cellules à chaque fois
        cell = [[InviteAddTableViewCell alloc] initWithUser:user
                                                  withStyle:indexPath.row%2
                                   withNavigationController:self.delegate.navigationController
                                            reuseIdentifier:CellIdentifier];
    }
    else
    {
        // Cell ID
        CellIdentifier = [NSString stringWithFormat:@"InviteAddTableViewCell_%@_%@_%@_%@_%@_%@", user.userId, user.facebookId, user.prenom, user.nom, user.email, user.numeroMobile];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[InviteAddTableViewCell alloc] initWithUser:user
                                                      withStyle:indexPath.row%2
                                       withNavigationController:self.delegate.navigationController
                                                reuseIdentifier:CellIdentifier];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Maintenir la sélection lors de la recherche
    if(!isEmpty) {
        BOOL isSelected = [((NSDictionary*)self.visibleFriends[indexPath.row])[@"isSelected"] boolValue];
        [cell setSelected:isSelected animated:YES];
        [cell setUserInteractionEnabled:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmpty)
        return emptyCellSize;
    return 70.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!isEmpty) {
        
        NSMutableDictionary *person = self.visibleFriends[indexPath.row];
        
        // Si on est sur une personne ajoutée manuellement
        if(person[@"newUser"])
        {
            // On est en train de l'ajouter
            if(![person[@"isSelected"] boolValue])
            {
                // Email
                if([person[@"newUser"] isEqualToString:@"email"]){
                    
                    // Valide ?
                    if([[Config sharedInstance] isValidEmail:[(UserClass*)person[@"user"] email]]) {
                        // Ajout
                        person[@"isSelected"] = @(YES);
                        NSMutableArray *friends = self.friends.mutableCopy;
                        [friends addObject:person];
                        self.friends = friends;
                        [self.delegate addNewSelectedFriend:person[@"user"] notif:YES];
                        // Vide la barre de recherche
                        [self.delegate.searchTextField setText:@""];
                        self.visibleFriends = friends;
                        [self.tableView reloadData];
                    }
                    else {
                        // Invalide
                        [[[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"InviteAddViewController_NewUser_Invalide_Title", nil)
                          message:NSLocalizedString(@"InviteAddViewController_NewUser_Invalide_Email", nil)
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                          otherButtonTitles:nil]
                         show];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    }
                    
                }
                // Phone
                else {
                    
                    // Valide ?
                    NSString *phone = [(UserClass*)person[@"user"] numeroMobile];
                    NSString *formattedNum = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if([[Config sharedInstance] isValidPhoneNumber:formattedNum]) {
                        
                        // Numéro de Mobile
                        if([[Config sharedInstance] isMobilePhoneNumber:formattedNum forceValidation:YES]) {
                            // Ajout
                            person[@"isSelected"] = @(YES);
                            NSMutableArray *friends = self.friends.mutableCopy;
                            [friends addObject:person];
                            self.friends = friends;
                            [self.delegate addNewSelectedFriend:person[@"user"] notif:YES];
                            // Vide la barre de recherche
                            [self.delegate.searchTextField setText:@""];
                            self.visibleFriends = friends;
                            [self.tableView reloadData];
                        }
                        else {
                            // Invalide
                            [[[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"InviteAddViewController_NewUser_Invalide_Title", nil)
                              message:NSLocalizedString(@"InviteAddViewController_NewUser_Invalide_Phone_Mobile", nil)
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                              otherButtonTitles:nil]
                             show];
                            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                        }
                        
                    }
                    else {
                        // Invalide
                        [[[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"InviteAddViewController_NewUser_Invalide_Title", nil)
                          message:NSLocalizedString(@"InviteAddViewController_NewUser_Invalide_Phone", nil)
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                          otherButtonTitles:nil]
                         show];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    }
                    
                }
            }
        }
        // Sinon, si on selectionne le user si il n'est pas déjà selectionné
        else if(![person[@"isSelected"] boolValue]) {
            //NSLog(@"Select Cell %d", indexPath.row);
            person[@"isSelected"] = @(YES);
            [self.delegate addNewSelectedFriend:person[@"user"] notif:notifSelectedFriends];
        }
    }
}

- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!isEmpty) {
        
        NSMutableDictionary *person = self.visibleFriends[indexPath.row];
        
        if([person[@"isSelected"] boolValue]) {
            //NSLog(@"deselect Cell %d", indexPath.row);
            person[@"isSelected"] = @(NO);
            [self.delegate removeSelectedFriend:person[@"user"]];
        }
    }
}

- (NSArray*)arrayOfUsersWithSelectAttribute:(NSArray*)list
{
    NSMutableArray *attributes = [[NSMutableArray alloc] initWithCapacity:[list count]];
    for( UserClass* user in list ) {
        [attributes addObject:@{@"user":user, @"isSelected":@(NO)}.mutableCopy];
    }
    return attributes;
}
 
- (void)loadFriendsList
{
    if([self.friends count] == 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
        
        switch (self.inviteTableViewStyle) {
                
            case InviteAddTableViewControllerContactStyle: {
                [AddressBookManager accesAddressBookListWithCompletionHandler:^(NSArray *list) {
                    if(list) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // Convert As MutableDictionnary Array @{"user":user, "isSelected":@(selected)}
                            self.friends = [self arrayOfUsersWithSelectAttribute:list];
                            
                            // Update Tableau des friends affichés
                            [self updateVisibleFriends:self.friends];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    }
                }];
                break;
            }
                
                
            case InviteAddTableViewControllerFacebookStyle: {
                
                [[FacebookManager sharedInstance] getFriendsWithEnded:^(NSArray *friends) {
                    self.friends = [self arrayOfUsersWithSelectAttribute:friends];
                    [self updateVisibleFriends:self.friends];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
                break;
            }
                
                
            case InviteAddTableViewControllerFavorisStyle: {
                
                [UserClass getFavorisUsersWithEnded:^(NSArray *favoris) {
                    if(favoris) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.friends = [self arrayOfUsersWithSelectAttribute:favoris];
                            [self updateVisibleFriends:self.friends];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    }
                }];
                
                break;
            }
                
        }
    }
}

- (void)updateVisibleFriends:(NSArray*)updatedArray {
    self.visibleFriends = updatedArray;
    [self.tableView reloadData];
}

@end
