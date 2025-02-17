//
//  ImporterFBViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ImporterFBViewController.h"
#import "FacebookManager.h"
#import "ImporterFBTableViewCell.h"
#import "CreationFicheViewController.h"
#import "InfoMomentViewController.h"
#import "MomentClass+Server.h"
#import "Config.h"

@interface ImporterFBViewController () {
    @private
    BOOL isEmpty;
    CGFloat emptyCellSize;
}

@end

@implementation ImporterFBViewController

@synthesize events = _events;
@synthesize moments = _moments;
@synthesize timeLine = _timeLine;

- (id)initWithTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [super initWithNibName:@"ImporterFBViewController" bundle:nil];
    if(self) {
        self.timeLine = timeLine;
    }
    return self;
}

- (void)loadEvents
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading_FBEvents", nil);
    hud.detailsLabelText = NSLocalizedString(@"MBProgressHUD_Loading_FBEvents_2", nil);
    
    __block int pass = 0;
    
    [MomentClass importFacebookEventsWithEnded:^(NSArray *events, NSArray *moments) {
        pass++;
        
        if (events && moments) {
            
            int nbEvent = events.count;
            
            if (nbEvent > 0) {
                
                if (nbEvent > 1) {
                    [[MTStatusBarOverlay sharedInstance]
                     postFinishMessage:[NSString stringWithFormat:NSLocalizedString(@"StatusBarOverlay_ImportFacebookEvent_several", nil), nbEvent]
                     duration:2 animated:YES];
                } else {
                    [[MTStatusBarOverlay sharedInstance]
                     postFinishMessage:[NSString stringWithFormat:NSLocalizedString(@"StatusBarOverlay_ImportFacebookEvent", nil), nbEvent]
                     duration:2 animated:YES];
                }
                
                for (MomentClass *moment in moments) {
                    
                    for (FacebookEvent *e in events) {
                        
                        if ([e.eventId isEqualToString:moment.facebookId]) {
                            
                            [[FacebookManager sharedInstance] createUsersFromFacebookInvited:e.invited withEnded:^(NSArray *users) {
                                if (users != nil && users.count > 0) {
                                    [moment inviteNewGuest:users withEnded:nil];
                                }
                            }];
                        }
                    }
                }
            }
            
            // Save
            self.events = events;
            self.moments = moments;
            
            [self.tableView reloadData];
            [self.timeLine reloadData];
        }
        // Tableau vide retourné -> Aucun Event n'a été renvoyé par Facebook
        else if(events && events.count == 0) {
            [[MTStatusBarOverlay sharedInstance]
             postFinishMessage:NSLocalizedString(@"StatusBarOverlay_ImportFacebookEvent_noResult", nil)
             duration:2 animated:YES];
        }
        else {
            if (pass > 1) {
                [[MTStatusBarOverlay sharedInstance] postImmediateErrorMessage:NSLocalizedString(@"StatusBarOverlay_LoadingFailure", nil)
                 duration:2 animated:YES];
            }
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Navigation bar
    [CustomNavigationController setBackButtonWithViewController:self];
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame= frame;
    self.tableView.frame = frame;
    emptyCellSize = frame.size.height;
    
    // Load Events
    [self loadEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setEvents:nil];
    [self setMoments:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Ajout Event Facebook"];
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
    int taille = [self.events count];
    if(taille == 0) {
        isEmpty = YES;
        self.tableView.scrollEnabled = NO;
        return 1;
    }
    isEmpty = NO;
    self.tableView.scrollEnabled = YES;
    return taille;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    UITableViewCell *cell = nil;
    
    if(isEmpty)
    {
        CellIdentifier = @"ImporterFBEmptyTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            CGRect frame = cell.frame;
            frame.size.width = self.tableView.frame.size.width;
            frame.size.height = emptyCellSize;
            cell.frame = frame;
            
            UILabel *emptyLabel = [[UILabel alloc] init];
            emptyLabel.text = NSLocalizedString(@"ImporterFBViewController_EmptyLabel", nil);
            emptyLabel.font = [[Config sharedInstance] defaultFontWithSize:15];
            emptyLabel.textColor = [Config sharedInstance].textColor;
            emptyLabel.backgroundColor = [UIColor clearColor];
            emptyLabel.numberOfLines = 0;
            emptyLabel.textAlignment = NSTextAlignmentCenter;
            frame = cell.frame;
            frame.size.width -= 20;
            frame.origin.x = (cell.frame.size.width - frame.size.width)/2.0f;
            frame.origin.y = (emptyCellSize - frame.size.height)/2.0f;
            emptyLabel.frame = frame;
            
            [cell addSubview:emptyLabel];
        }
        
    }
    else
    {
        FacebookEvent *event = self.events[indexPath.row];
        CellIdentifier = [NSString stringWithFormat:@"ImporterFBViewController_%@", event.eventId];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ImporterFBTableViewCell alloc] initWithFacebookEvent:event withIndex:indexPath.row reuseIdentifier:CellIdentifier];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!isEmpty)
    {
        //MomentClass *moment = [MomentCoreData requestMomentWithFacebookEvent:event];
        MomentClass *moment = self.moments[indexPath.row];
        
        // Owner / Admin --> Edition
        if(moment.state.intValue == UserStateAdmin || ([moment.owner.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]) ) {
            CreationFicheViewController *editViewController = [[CreationFicheViewController alloc] initWithUser:[UserCoreData getCurrentUser] withMoment:moment withTimeLine:nil];
            [self.navigationController pushViewController:editViewController animated:YES];
        }
        // Autre --> Info Moment
        else {
            
            // Root
            RootOngletsViewController *rootViewController = [[RootOngletsViewController alloc]
                                                             initWithMoment:moment
                                                             withOnglet:OngletInfoMoment
                                                             withTimeLine:self.timeLine];
            
            [self.navigationController pushViewController:rootViewController animated:YES];
        }
    }
}

@end
