//
//  PhotosMultipleSelectionViewController.m
//  Moment
//
//  Created by SkeletonGamer on 27/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PhotosMultipleSelectionViewController.h"
#import "PhotosCollectionCell.h"
#import "PhotosCollectionHeaderSection.h"
#import "Config.h"
#import "CustomToolbar.h"
#import "CustomNavigationBarButton.h"

@interface PhotosMultipleSelectionViewController ()

@end

@implementation PhotosMultipleSelectionViewController

- (id)initWithMoment:(MomentClass *)moment
{
    self = [super initWithNibName:@"PhotosMultipleSelectionViewController" bundle:nil];
    if (self) {
        self.moment = moment;
        self.photosToUpload = [NSMutableArray array];
        self.datasourceAutomatic = [NSMutableArray array];
        self.datasourceComplete = [NSMutableArray array];
        
        
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        self.collectionView.backgroundColor = [UIColor clearColor];
        
        [self.collectionView registerClass:[PhotosCollectionCell class] forCellWithReuseIdentifier:@"PhotosCollectionCellIdentifier"];
        [self.collectionView registerClass:[PhotosCollectionHeaderSection class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PhotosCollectionHeaderSection"];
        
        //self.collectionView.clipsToBounds = YES;
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        // Init Top Toolbar
        [self loadUIToolBar];
        
        
        [self loadPhotos];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init Segmented control
    [self initSegmentedControl];
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    
    if ([VersionControl sharedInstance].supportIOS7) {
        frame.origin.y += TOPBAR_HEIGHT;
    }
    self.view.frame = frame;
    
    
    CGRect frameCollection = self.collectionView.frame;
    if ([VersionControl sharedInstance].supportIOS7) {
        frame.size.height -= TOPBAR_HEIGHT;
    } else {
        frameCollection.origin.y -= STATUS_BAR_HEIGHT;
        frameCollection.size.height += STATUS_BAR_HEIGHT;
    }
    self.collectionView.frame = frameCollection;
    
    
    CGRect frameSegment = self.segmentedControl.frame;
    if ([VersionControl sharedInstance].supportIOS7) {
        frame.size.height -= TOPBAR_HEIGHT;
    } else {
        frameSegment.origin.y -= STATUS_BAR_HEIGHT;
    }
    self.segmentedControl.frame = frameSegment;
    
    [self.segmentedControl addTarget:self
                              action:@selector(onSegmentedControlChanged:)
                    forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([VersionControl sharedInstance].supportIOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                    animated:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Multiple Selection Photos Album"];
    
    [AppDelegate updateActualViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBackWithPhotos
{
    
    if (self.photosToUpload.count > 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_PhotosPreparing", nil);
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self.delegate didDismissAlbumViewController];
        });
    } else {
        
    }
    
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Create UI

- (void)initSegmentedControl
{
    CGRect frame = self.segmentedControl.frame;
    [self.segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 47)];
    
    NSDictionary *textAttributesNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont boldSystemFontOfSize:16], UITextAttributeFont,
                                          [UIColor whiteColor], UITextAttributeTextColor, nil];
    [self.segmentedControl setTitleTextAttributes:textAttributesNormal forState:UIControlStateNormal];
    
    NSDictionary *textAttributesSelected = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont boldSystemFontOfSize:16], UITextAttributeFont,
                                            [UIColor whiteColor], UITextAttributeTextColor, nil];
    [self.segmentedControl setTitleTextAttributes:textAttributesSelected forState:UIControlStateSelected];
    
    
    /* Unselected background */
    UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"tab_unselect.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.segmentedControl setBackgroundImage:unselectedBackgroundImage
                                     forState:UIControlStateNormal
                                   barMetrics:UIBarMetricsDefault];
    
    /* Selected background */
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
}

- (void)loadUIToolBar
{
    UIImage *buttonCloseTitle = [[Config sharedInstance] imageFromText:NSLocalizedString(@"AlertView_Button_Cancel", nil) withColor:[Config sharedInstance].orangeColor andFont:[[Config sharedInstance] defaultFontWithSize:20]];
    UIImage *buttonOKTitle = [[Config sharedInstance] imageFromText:NSLocalizedString(@"AlertView_Button_OK", nil) withColor:[Config sharedInstance].orangeColor andFont:[[Config sharedInstance] defaultFontWithSize:20]];
    
    UIButton *buttonClose;
    UIButton *buttonOK;
    if ([VersionControl sharedInstance].supportIOS7) {
        buttonClose = [[CustomNavigationBarButton alloc] initWithFrame:CGRectMake(0, 0, buttonCloseTitle.size.width, buttonCloseTitle.size.height) andIsLeftButton:YES];
        buttonOK = [[CustomNavigationBarButton alloc] initWithFrame:CGRectMake(0, 0, buttonCloseTitle.size.width, buttonCloseTitle.size.height) andIsLeftButton:NO];

    } else {
        buttonClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonCloseTitle.size.width, buttonCloseTitle.size.height)];
        buttonOK = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonOKTitle.size.width, buttonOKTitle.size.height)];
    }
    
    [buttonClose setImage:buttonCloseTitle forState:UIControlStateNormal];
    [buttonClose setImage:buttonCloseTitle forState:UIControlStateSelected];
    [buttonClose addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:buttonClose];
    
    [buttonOK setImage:buttonOKTitle forState:UIControlStateNormal];
    [buttonOK setImage:buttonOKTitle forState:UIControlStateSelected];
    [buttonOK addTarget:self action:@selector(goBackWithPhotos) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *OKButton = [[UIBarButtonItem alloc] initWithCustomView:buttonOK];
    
    int pixelY = 0;
    
    UIBarButtonItem *flexibleSpaceLeft;
    if ([VersionControl sharedInstance].supportIOS7) {
        pixelY = STATUS_BAR_HEIGHT;
    }
    
    
    CustomToolbar *toolbar = [[CustomToolbar alloc] init];
    toolbar.frame = CGRectMake(0, pixelY, self.view.frame.size.width, NAVIGATION_BAR_HEIGHT);
    toolbar.backgroundColor = [UIColor clearColor];
    
    if ([VersionControl sharedInstance].supportIOS7) {
        
        flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        flexibleSpaceLeft.width = toolbar.frame.size.width-(buttonClose.frame.size.width+buttonOK.frame.size.width);
    } else {
        flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    
    
    [toolbar setItems:[NSArray arrayWithObjects:closeButton, flexibleSpaceLeft, OKButton, nil] animated:NO];
    
    [self.view addSubview:toolbar];
}

- (void)updateNavBar
{
    NSArray *buttons = self.toolbar.items;
    
    NSString *normal = [NSString stringWithFormat:NSLocalizedString(@"AlertView_Button_OK", nil)];
    UIColor *colorEnable = [Config sharedInstance].orangeColor;
    UIColor *colorDisabled = [Config sharedInstance].textColor;
    BOOL secondButtonEnable = NO;
    
    // Second Button
    UIButton *button;
    if ([VersionControl sharedInstance].supportIOS7) {
        button = (CustomNavigationBarButton *)[buttons[2] customView];
    } else {
        button = (UIButton *)[buttons[2] customView];
    }
    CGRect buttonFrame = button.frame;
    
    if(self.photosToUpload && self.photosToUpload.count > 0)
    {
        secondButtonEnable = YES;
        
        [self removeSubviewsOfView:button];
        
        [button setFrame:CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y, buttonFrame.size.width, buttonFrame.size.height)];
    } else {
        [self setNavBarSecondButtonEnable:NO];
    }
    
    // Update
    [button.titleLabel setFont:[[Config sharedInstance] defaultFontWithSize:20]];
    [button setTitle:normal forState:UIControlStateNormal];
    [button setTitleColor:colorDisabled forState:UIControlStateDisabled];
    [button setTitleColor:colorEnable forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:NSTextAlignmentRight];
    [button removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(goBackWithPhotos) forControlEvents:UIControlEventTouchUpInside];
    [button setEnabled:secondButtonEnable];
    
}

- (void)setNavBarSecondButtonEnable:(BOOL)enable
{
    NSArray *buttons = self.toolbar.items;
    UIButton *button;
    if ([VersionControl sharedInstance].supportIOS7) {
        button = (CustomNavigationBarButton *)[buttons[2] customView];
    } else {
        button = (UIButton *)[buttons[2] customView];
    }
    
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

#pragma mark - Segmented control

- (void)onSegmentedControlChanged:(UISegmentedControl *)sender {
    
    // reload data based on the new index
    [self.collectionView reloadData];
}

#pragma mark - Load photos

-(void)loadPhotos
{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if (self.datasourceAutomatic.count == 0) {
        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            @autoreleasepool {
                if (group) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            
                            NSDate *photoDate = (NSDate *)[result valueForProperty:ALAssetPropertyDate];
                            
                            if (self.moment.dateDebut && self.moment.dateFin) {
                                
                                if ([Config date:photoDate isBetweenDate:self.moment.dateDebut andDate:self.moment.dateFin]) {
                                    
                                    Photo *photo = [[Photo alloc] init];
                                    photo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                                    photo.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                                    photo.date = photoDate;
                                    photo.momentId = self.moment.momentId;
                                    photo.isSelected = YES;
                                    
                                    if (![self.datasourceAutomatic containsObject:photo]) {
                                        
                                        [self.datasourceAutomatic addObject:photo];
                                        [self.delegate addPhotoToUpload:photo];
                                        
                                        if (![self.photosToUpload containsObject:photo]) {
                                            [self.photosToUpload addObject:photo];
                                        }
                                    }
                                }
                                
                            } else if (self.moment.dateDebut && !self.moment.dateFin) {
                                NSDate *dateFin = [self.moment.dateDebut dateByAddingTimeInterval:60*60*24*1];
                                
                                if ([Config date:photoDate isBetweenDate:self.moment.dateDebut andDate:dateFin]) {
                                    
                                    Photo *photo = [[Photo alloc] init];
                                    photo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                                    photo.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                                    photo.date = photoDate;
                                    photo.momentId = self.moment.momentId;
                                    photo.isSelected = YES;
                                    
                                    if (![self.datasourceAutomatic containsObject:photo]) {
                                        
                                        [self.datasourceAutomatic addObject:photo];
                                        [self.delegate addPhotoToUpload:photo];
                                        
                                        if (![self.photosToUpload containsObject:photo]) {
                                            [self.photosToUpload addObject:photo];
                                        }
                                    }
                                }
                            }
                        }
                    }];
                }
            }
            
            if (self.datasourceAutomatic.count == 0) {
                self.segmentedControl.selectedSegmentIndex = 1;
            }
            
            [self.collectionView reloadData];
            [self updateNavBar];
        } failureBlock:^(NSError *error) {
            NSLog(@"Failed.");
        }];
    }
    
    if (self.datasourceComplete.count == 0) {
        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            @autoreleasepool {
                if (group) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            
                            NSDate *photoDate = (NSDate *)[result valueForProperty:ALAssetPropertyDate];
                            
                            if (self.moment.dateDebut && self.moment.dateFin) {
                                
                                if (![Config date:photoDate isBetweenDate:self.moment.dateDebut andDate:self.moment.dateFin]) {
                                    
                                    Photo *photo = [[Photo alloc] init];
                                    photo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                                    photo.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                                    photo.date = photoDate;
                                    photo.momentId = self.moment.momentId;
                                    photo.isSelected = YES;
                                    
                                    if (![self.datasourceComplete containsObject:photo]) {
                                        
                                        [self.datasourceComplete addObject:photo];
                                    }
                                }
                                
                            } else if (self.moment.dateDebut && !self.moment.dateFin) {
                                NSDate *dateFin = [self.moment.dateDebut dateByAddingTimeInterval:60*60*24*1];
                                
                                if (![Config date:photoDate isBetweenDate:self.moment.dateDebut andDate:dateFin]) {
                                    
                                    Photo *photo = [[Photo alloc] init];
                                    photo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                                    photo.assetUrl = [result valueForProperty:ALAssetPropertyAssetURL];
                                    photo.date = photoDate;
                                    photo.momentId = self.moment.momentId;
                                    photo.isSelected = YES;
                                    
                                    if (![self.datasourceComplete containsObject:photo]) {
                                        
                                        [self.datasourceComplete addObject:photo];
                                    }
                                }
                            }
                        }
                    }];
                }
            }
            
            [self.collectionView reloadData];
            [self updateNavBar];
        } failureBlock:^(NSError *error) {
            NSLog(@"Failed.");
        }];
    }
}

#pragma mark - UICollectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return  self.datasourceAutomatic.count;
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        return  self.datasourceComplete.count;
    }
    
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotosCollectionCellIdentifier";
    PhotosCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.photoView.userInteractionEnabled = YES;
    cell.photoView.tag = indexPath.item;
    
    Photo *photo;
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        photo = (Photo *)[self.datasourceAutomatic objectAtIndex:indexPath.item];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        photo = (Photo *)[self.datasourceComplete objectAtIndex:indexPath.item];
    }
    
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
        [self.delegate removePhotoToUpload:selectedCell.photo];
    } else {
        //NSLog(@"La photo n'est pas sélectionnée. On l'ajoute !");
        [self.photosToUpload addObject:selectedCell.photo];
        selectedCell.circleCheck.image = [UIImage imageNamed:@"picto_check.png"];
        [self.delegate addPhotoToUpload:selectedCell.photo];
    }
    
    if (self.photosToUpload.count == 0 || self.photosToUpload.count == 1) {
        [self updateNavBar];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(kind == UICollectionElementKindSectionHeader)
    {
        PhotosCollectionHeaderSection *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PhotosCollectionHeaderSection" forIndexPath:indexPath];
        
        headerView.backgroundColor = [UIColor clearColor];
        
        headerView.titleSection.textColor = [UIColor whiteColor];
        headerView.titleSection.font = [[Config sharedInstance] defaultFontWithSize:16];
        headerView.titleSection.text = @"Pellicule";//group.name;
        headerView.titleSection.backgroundColor = [UIColor clearColor];
        
        return headerView;
    }
    
    return nil;
}

@end
