//
//  RevivrePhotosCollectionViewController.m
//  Moment
//
//  Created by SkeletonGamer on 25/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RevivrePhotosCollectionViewController.h"
#import "Config.h"
#import "RevivrePartagerViewController.h"
#import "PhotosCollectionCell.h"
#import "PhotosCollectionHeaderSection.h"

@interface RevivrePhotosCollectionViewController ()

@end

@implementation RevivrePhotosCollectionViewController

- (id)initWithDatasource:(NSArray *)datasource moments:(NSArray *)moments timeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [super initWithNibName:@"RevivrePhotosCollectionViewController" bundle:nil];
    if (self) {
        _ds = [NSMutableArray array];
        self.photosToUpload = [NSMutableArray array];
        self.moments = [NSArray arrayWithArray:moments];
        self.timeLine = timeLine;
        self.datasource = [NSMutableArray arrayWithArray:datasource];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_ds && _ds.count == 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Cross.png"]];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Search_EmptyPhoto", nil);
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init Nav bar
    [self initNavigationBar];
    
    if (_ds && _ds.count > 0) {
        [self initFinishButton];
    }
    
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    [self.collectionView registerClass:[PhotosCollectionCell class] forCellWithReuseIdentifier:@"PhotosCollectionCellIdentifier"];
    [self.collectionView registerClass:[PhotosCollectionHeaderSection class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PhotosCollectionHeaderSection"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Revivre Moments Photos Collection"];
    
    [AppDelegate updateActualViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init view components

- (void)initFinishButton
{
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setBackgroundImage:[UIImage imageNamed:@"btn_revivre.png"]
                            forState:UIControlStateNormal];
    
    [finishButton addTarget:self
                     action:@selector(clicFinish)
           forControlEvents:UIControlEventTouchDown];
    
    [finishButton setTitle:@"Envoyer les photos !" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finishButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    finishButton.frame = CGRectMake(14, 0, 292, 42);
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [footerView addSubview:finishButton];
    
    //[self.tableView setTableFooterView:footerView];
}

- (void)initNavigationBar
{
    [CustomNavigationController setBackButtonChevronWithViewController:self];
    [CustomNavigationController setTitle:@"Revivre" withColor:[Config sharedInstance].orangeColor withViewController:self];
    
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
        
        //if(self.events && self.events.count > 0)
        if(self.moments && self.moments.count > 0)
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
        [button addTarget:self action:@selector(clicNext) forControlEvents:UIControlEventTouchUpInside];
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

- (void)clicNext
{
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Terminer Sélection Revivre Moment"];
    
    if (self.photosToUpload.count == 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Cross.png"]];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Search_NoSelectedPhoto", nil);
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    } else {
        
        RevivrePartagerViewController *partagerViewController = [[RevivrePartagerViewController alloc] initWithTimeLine:self.timeLine moments:self.moments photos:self.photosToUpload];
        
        [self.navigationController pushViewController:partagerViewController animated:YES];
    }
}

#pragma mark - Data source

- (void)reloadData
{
    [_ds removeAllObjects];
    [self.photosToUpload removeAllObjects];
    
    if (self.moments) {
        for (MomentClass *moment in self.moments) {
            
            if (moment.momentId) {
                if (moment.dateDebut) {
                    
                    NSDateComponents *momentComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
                                                          NSMonthCalendarUnit | NSYearCalendarUnit fromDate:moment.dateDebut];
                    
                    
                    NSUInteger dayEvent = momentComponents.day;
                    NSUInteger monthEvent = momentComponents.month;
                    NSUInteger yearEvent = momentComponents.year;
                    //NSUInteger hourEvent = momentComponents.hour;
                    //NSUInteger minuteEvent = momentComponents.minute;
                    
                    
                    NSArray *sorted = [_datasource sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        Photo <REPhotoObjectProtocol> *photo1 = obj1;
                        Photo <REPhotoObjectProtocol> *photo2 = obj2;
                        return ![photo1.date compare:photo2.date];
                    }];
                    for (Photo *object in sorted) {
                        Photo <REPhotoObjectProtocol> *photo = (Photo <REPhotoObjectProtocol> *)object;
                        //NSLog(@"photo.assetUrl = %@", [photo.assetUrl absoluteString]);
                        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
                                                        NSMonthCalendarUnit | NSYearCalendarUnit fromDate:photo.date];
                        NSUInteger dayPhoto = [components day];
                        NSUInteger monthPhoto = [components month];
                        NSUInteger yearPhoto = [components year];
                        //NSUInteger hour = [components hour];
                        //NSUInteger minute = [components minute];
                        
                        if (monthPhoto == monthEvent && yearPhoto == yearEvent && dayPhoto == dayEvent) { // && hour == hourEvent && minute == minuteEvent) {
                            
                            Photo *photoCopy = photo.mutableCopy;
                            
                            
                            REPhotoGroup *group = ^REPhotoGroup *{
                                for (REPhotoGroup *group in _ds) {
                                    if (group.month == monthPhoto && group.year == yearPhoto && group.day == dayPhoto && moment.momentId == group.momentId) { // && group.hour == hour && group.minute == minute) {
                                        
                                        //NSLog(@"%@", group.description);
                                        return group;
                                    }
                                }
                                return nil;
                            }();
                            
                            if (group == nil) {
                                
                                group = [[REPhotoGroup alloc] init];
                                
                                [group setName:moment.titre];
                                [group setDay:dayEvent];
                                [group setMonth:monthEvent];
                                [group setYear:yearEvent];
                                //group.hour = hour;
                                //group.minute = minute;
                                [group setMomentId:moment.momentId];
                                [photoCopy setMomentId:moment.momentId];
                                [group.items addObject:photoCopy];
                                [self.photosToUpload addObject:photoCopy];
                                [_ds addObject:group];
                            } else {
                                [photoCopy setMomentId:moment.momentId];
                                [group.items addObject:photoCopy];
                                [self.photosToUpload addObject:photoCopy];
                            }
                        }
                        
                    }
                }
            }
        }
        
        [self.collectionView reloadData];
        
        [self updateNavBar];
    }
}

#pragma mark - Setter
- (void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = datasource;
    
    [self reloadData];
}

#pragma mark - UICollectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_ds.count == 0) return 0;
    
    if ([self collectionView:self.collectionView numberOfItemsInSection:_ds.count - 1] == 0) {
        return _ds.count - 1;
    }
    
    return _ds.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    REPhotoGroup *group = (REPhotoGroup *)[_ds objectAtIndex:section];
    return group.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotosCollectionCellIdentifier";
    PhotosCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.photoView.userInteractionEnabled = YES;
    cell.photoView.tag = indexPath.item;
    
    REPhotoGroup *group = (REPhotoGroup *)[_ds objectAtIndex:indexPath.section];
    Photo <REPhotoObjectProtocol> *photo = (Photo *)[group.items objectAtIndex:indexPath.item];
    
    [cell.photoView setImage:photo.thumbnail];
    [cell setPhoto:photo];

    if ([self.photosToUpload containsObject:photo]) {
        cell.circleCheck.image = [UIImage imageNamed:@"picto_check.png"];
    } else {
        cell.circleCheck.image = [UIImage imageNamed:@"picto_uncheck.png"];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotosCollectionCell *selectedCell = (PhotosCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //NSLog(@"%@", selectedCell.photo.description);
    
    if ([self.photosToUpload containsObject:selectedCell.photo]) {
        //NSLog(@"La photo est sélectionnée. On la supprime !");
        [self.photosToUpload removeObject:selectedCell.photo];
        selectedCell.circleCheck.image = [UIImage imageNamed:@"picto_uncheck.png"];
    } else {
        //NSLog(@"La photo n'est pas sélectionnée. On l'ajoute !");
        [self.photosToUpload addObject:selectedCell.photo];
        selectedCell.circleCheck.image = [UIImage imageNamed:@"picto_check.png"];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(kind == UICollectionElementKindSectionHeader)
    {
        PhotosCollectionHeaderSection *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PhotosCollectionHeaderSection" forIndexPath:indexPath];
        
        headerView.backgroundColor = [UIColor clearColor];
        
        REPhotoGroup *group = (REPhotoGroup *)[_ds objectAtIndex:indexPath.section];
        
        headerView.titleSection.textColor = [UIColor whiteColor];
        headerView.titleSection.font = [[Config sharedInstance] defaultFontWithSize:16];
        headerView.titleSection.text = group.name;
        headerView.titleSection.backgroundColor = [UIColor clearColor];
        
        return headerView;
    }
    
    return nil;
}

@end
