//
//  RevivreImportFBViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RevivreImportFBViewController.h"
#import "FacebookManager.h"
#import "RevivreImportFBTableViewCell.h"
#import "CreationFicheViewController.h"
#import "InfoMomentViewController.h"
#import "MomentClass+Server.h"
#import "Config.h"
#import "REPhotoCollectionController.h"
#import "ThumbnailView.h"
#import "Photo.h"

@interface RevivreImportFBViewController () {
    @private
    BOOL isEmpty;
    CGFloat emptyCellSize;
}

@end

@implementation RevivreImportFBViewController

@synthesize eventsValid = _eventsValid;
@synthesize eventsMaybe = _eventsMaybe;
//@synthesize moments = _moments;
@synthesize timeLine = _timeLine;
@synthesize selectedRowsValid = _selectedRowsValid;
@synthesize selectedRowsMaybe = _selectedRowsMaybe;

@synthesize segmentedControl = _segmentedControl;

- (id)initWithTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [super initWithNibName:@"RevivreImportFBViewController" bundle:nil];
    if(self) {
        self.timeLine = timeLine;
    }
    return self;
}

- (void)loadEvents
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading_FBEvents", nil);
    hud.detailsLabelText = NSLocalizedString(@"MBProgressHUD_Loading_FBEvents_3", nil);
    
    __block int pass = 0;
        
        
    [MomentClass getOldFacebookEventsWithEnded:^(NSArray *eventsValid, NSArray *eventsMaybe) {
        pass++;
        
        if (eventsValid || eventsMaybe) {
            
            int nbEvent = eventsValid.count+eventsMaybe.count;
            
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
            }
            
            NSMutableArray *eventsValidWithNumberInvited = [NSMutableArray arrayWithCapacity:eventsValid.count];
            
            for (FacebookEvent *e in eventsValid) {
                [[FacebookManager sharedInstance] getNumberInvitedInFacebookEvent:e withEnded:^(FacebookEvent *eventModif) {
                    
                    if (eventModif) {
                        //NSLog(@"eventModif = %@",eventModif.numberInvited);
                        [eventsValidWithNumberInvited addObject:eventModif];
                    } else {
                        [eventsValidWithNumberInvited addObject:e];
                    }
                    
                    if (eventsValidWithNumberInvited.count == eventsValid.count) {
                        
                        // Save
                        self.eventsValid = eventsValidWithNumberInvited;
                        self.eventsMaybe = eventsMaybe;
                        
                        for (FacebookEvent *e in self.eventsValid) {
                            if (e.numberInvited.integerValue < 200) {
                                [self.selectedRowsValid addObject:e];
                            }
                        }
                        
                        //[self.tableView setEditing:YES animated:YES];
                        [self.tableView reloadData];
                        
                        [self updateNavBar];
                    }
                }];
            }
        }
        // Tableau vide retourné -> Aucun Event n'a été renvoyé par Facebook
        else if(eventsValid.count == 0 && eventsMaybe.count == 0) {
            
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

- (void)initSegmentedControl
{    
    CGRect frame = self.segmentedControl.frame;
    [self.segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 47)];
    
    NSDictionary *textAttributesNormal = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16], UITextAttributeFont, [UIColor clearColor], UITextAttributeTextShadowColor, nil];
    [self.segmentedControl setTitleTextAttributes:textAttributesNormal forState:UIControlStateNormal];
    
    NSDictionary *textAttributesSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16], UITextAttributeFont, [UIColor clearColor], UITextAttributeTextShadowColor, nil];
    [self.segmentedControl setTitleTextAttributes:textAttributesSelected forState:UIControlStateSelected];
    
    
    /* Unselected background */
    //UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"segment_background_unselected"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"tab_unselect.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.segmentedControl setBackgroundImage:unselectedBackgroundImage
                                     forState:UIControlStateNormal
                                   barMetrics:UIBarMetricsDefault];
    
    /* Selected background */
    //UIImage *selectedBackgroundImage = [[UIImage imageNamed:@"segment_background_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *selectedBackgroundImage = [[UIImage imageNamed:@"tab_select.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.segmentedControl setBackgroundImage:selectedBackgroundImage
                                     forState:UIControlStateSelected
                                   barMetrics:UIBarMetricsDefault];
    
    /* Image between segment selected on the left and unselected on the right */
    UIImage *leftSelectedImage = [[UIImage imageNamed:@"tab_left_select.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.segmentedControl setDividerImage:leftSelectedImage
                       forLeftSegmentState:UIControlStateSelected
                         rightSegmentState:UIControlStateNormal
                                barMetrics:UIBarMetricsDefault];
    
    /* Image between segment selected on the right and unselected on the left */
    UIImage *rightSelectedImage = [[UIImage imageNamed:@"tab_right_select.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.segmentedControl setDividerImage:rightSelectedImage
                       forLeftSegmentState:UIControlStateNormal
                         rightSegmentState:UIControlStateSelected
                                barMetrics:UIBarMetricsDefault];
    
    /* Image between two unselected segments */
    /*UIImage *bothUnselectedImage = [[UIImage imageNamed:@"segment_middle_unselected"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 0, 15, 0)];
    [self.segmentedControl setDividerImage:bothUnselectedImage
                       forLeftSegmentState:UIControlStateNormal
                         rightSegmentState:UIControlStateNormal
                                barMetrics:UIBarMetricsDefault];*/
    
    /* Image between two selected segments */
    /*UIImage *bothSelectedImage = [[UIImage imageNamed:@"segment_middle_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 0, 15, 0)];
    [self.segmentedControl setDividerImage:bothSelectedImage
                       forLeftSegmentState:UIControlStateSelected
                         rightSegmentState:UIControlStateSelected
                                barMetrics:UIBarMetricsDefault];*/
}

- (void)initNavigationBar
{
    [CustomNavigationController setBackButtonChevronWithViewController:self];
    [CustomNavigationController setTitle:@"Revivre" withColor:[UIColor blackColor] withViewController:self];
    
    CGRect frameButton = CGRectMake(0,0,90,43);
    
    // 2e bouton
    UIButton *secondButton = [[UIButton alloc] initWithFrame:frameButton];
    UIBarButtonItem *secondBarButton = [[UIBarButtonItem alloc] initWithCustomView:secondButton];
    
    // Set buttons
    self.navigationItem.rightBarButtonItems = @[secondBarButton];
    
    [self updateNavBar];
}

- (void)updateNavBar
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    
    if(buttons.count == 1)
    {
        NSString *normal = [NSString stringWithFormat:NSLocalizedString(@"Next", nil)];
        UIColor *colorEnable = [Config sharedInstance].orangeColor;
        UIColor *colorDisabled = [Config sharedInstance].textColor;
        BOOL secondButtonEnable = NO;
        
        // Second Button
        UIButton *button = (UIButton*)[buttons[0] customView];
        
        int allEvents = self.eventsValid.count+self.eventsMaybe.count;
        
        if(allEvents > 0)
        {
            secondButtonEnable = YES;
            
            [self removeSubviewsOfView:button];
            
            [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, 90, 43)];
        }
        
        // Update
        [button.titleLabel setFont:[[Config sharedInstance] defaultFontWithSize:16]];
        [button setTitle:normal forState:UIControlStateNormal];
        [button setTitleColor:colorDisabled forState:UIControlStateDisabled];
        [button setTitleColor:colorEnable forState:UIControlStateNormal];
        [button.titleLabel setTextAlignment:NSTextAlignmentRight];
        [button removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(getPhotoFromCameraRoll) forControlEvents:UIControlEventTouchUpInside];
        [button setEnabled:secondButtonEnable];
    }
    
}

- (void)setNavBarSecondButtonEnable:(BOOL)enable
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    UIButton *button = (UIButton*)[buttons[0] customView];
    
    [button setEnabled:enable];
}

- (void)removeSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if (subviews.count != 0) {
        for (UIView *subview in subviews) {
            
            if (![[[subview class] description] isEqualToString:@"UIButtonLabel"]) {
                [subview removeFromSuperview];
            }
        }
    }
}

#pragma mark - Actions

- (void)showPhotoCollectionController:(NSArray *)datasource
{
    NSMutableSet *set = [NSMutableSet setWithArray:self.selectedRowsValid];
    [set addObjectsFromArray:self.selectedRowsMaybe];
    
    NSArray *allSelectedEvents = set.allObjects;
    
    [MomentClass createMomentFromFBEvents:allSelectedEvents withEnded:^(NSArray *events, NSArray *moments) {
        
        [MomentClass getMomentFromFBEvents:allSelectedEvents withEnded:^(NSArray *events, NSArray *moments) {
            if (events && moments) {
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                if (!datasource || datasource.count == 0) {
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Cross.png"]];
                    hud.labelText = NSLocalizedString(@"MBProgressHUD_Search_EmptyPhoto", nil);
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                } else {
                    
                    REPhotoCollectionController *photoCollectionController = [[REPhotoCollectionController alloc] initWithDatasource:datasource
                                                                                                                             moments:moments
                                                                                                                            timeLine:self.timeLine
                                                                                                               andThumbnailViewClass:[ThumbnailView class]];
                    
                    [self.navigationController pushViewController:photoCollectionController animated:YES];
                }
            }
        }];
    }];
}

- (void)getPhotoFromCameraRoll
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Search_Photo", nil);
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *datasource = [[NSMutableArray alloc] init];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            @autoreleasepool {
                if (group) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            Photo *photo = [[Photo alloc] init];
                            photo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                            photo.date = [result valueForProperty:ALAssetPropertyDate];
                            photo.isSelected = YES;
                            
                            if([VersionControl sharedInstance].supportIOS6) {
                                photo.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                            } else {
                                photo.assetUrl = result.defaultRepresentation.url;
                            }
                            
                            [datasource addObject:photo];
                        }
                    }];
                } else {
                    [self performSelectorOnMainThread:@selector(showPhotoCollectionController:) withObject:datasource waitUntilDone:NO];
                }
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Failed.");
        }];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init Nav bar
    [self initNavigationBar];
    
    // Init Segmented control
    [self initSegmentedControl];
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame= frame;
    self.tableView.frame = frame;
    emptyCellSize = frame.size.height;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    // Load Events
    [self loadEvents];
    
    self.tableView.allowsSelection = YES;
    
    //self.selectedRows = [NSMutableArray array];
    
    
    [self.segmentedControl addTarget:self
                              action:@selector(onSegmentedControlChanged:)
                    forControlEvents:UIControlEventValueChanged];
    
    self.selectedRowsValid = [NSMutableArray array];
    self.selectedRowsMaybe = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Revivre Event Facebook"];
    
    [AppDelegate updateActualViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setEventsValid:nil];
    [self setEventsMaybe:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

#pragma mark - Segmented control

- (void)onSegmentedControlChanged:(UISegmentedControl *)sender {
    // lazy load data for a segment choice (write this based on your data)
    //[self loadSegmentData:self.segmentedControl.selectedSegmentIndex];
    
    // reload data based on the new index
    [self.tableView reloadData];
    
    /*// reset the scrolling to the top of the table view
    if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int taille = 0;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        taille = self.eventsValid.count;
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        taille = self.eventsMaybe.count;
    }
    
    // Return the number of rows in the section.
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
        CellIdentifier = @"RevivreImportFBTableViewCell";
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
            emptyLabel.textAlignment = ([VersionControl sharedInstance].supportIOS6) ? NSTextAlignmentCenter : UITextAlignmentCenter;
            frame = cell.frame;
            frame.size.width -= 20;
            frame.origin.x = (cell.frame.size.width - frame.size.width)/2.0f;
            frame.origin.y = (emptyCellSize - frame.size.height)/2.0f;
            emptyLabel.frame = frame;
            
            [cell addSubview:emptyLabel];
            
            //cell.selectionStyle = ([self.selectedRows containsObject:indexPath] ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleNone);
        }
        
    }
    else
    {
        FacebookEvent *event;
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            event = self.eventsValid[indexPath.row];
        } else if (self.segmentedControl.selectedSegmentIndex == 1) {
            event = self.eventsMaybe[indexPath.row];
        }
        
        CellIdentifier = [NSString stringWithFormat:@"RevivreImportFBTableViewCell_%@", event.eventId];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[RevivreImportFBTableViewCell alloc] initWithFacebookEvent:event withIndex:indexPath.row reuseIdentifier:CellIdentifier];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0f;
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /\*if(!isEmpty)
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
    }*\/
    
    //NSLog(@"Selected rows = %@", [self.tableView indexPathsForSelectedRows]);
    
    /\*if ([self.selectedRows containsObject:indexPath]) {
        [self.selectedRows removeObject:indexPath];
    } else {
        [self.selectedRows addObject:indexPath];
    }*\/
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FacebookEvent *event = nil;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        event = self.eventsValid[indexPath.row];
        
        if ([self.selectedRowsValid containsObject:event]) {
            [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
            [self.selectedRowsValid removeObject:event];
        } else {
            [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.selectedRowsValid addObject:event];
        }
        
        //NSLog(@"self.selectedRowsValid.count = %i",self.selectedRowsValid.count);
        
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        event = self.eventsMaybe[indexPath.row];
        
        if ([self.selectedRowsMaybe containsObject:event]) {
            [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
            [self.selectedRowsMaybe removeObject:event];
        } else {
            [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.selectedRowsMaybe addObject:event];
        }
        
        //NSLog(@"self.selectedRowsMaybe.count = %i",self.selectedRowsMaybe.count);
    }
}

@end
