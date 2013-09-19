//
//  PhotoCollectionViewController.m
//  PhotoCollection
//
//  Created by SkeletonGamer on 18/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PhotoCollectionViewController.h"
#import "PhotoCollectionPlusCell.h"
#import "PhotoCollectionCell.h"
#import "MomentClass+Server.h"
#import "ProfilViewController.h"
#import "PhotoDownloader.h"
#import "RotationNavigationControllerViewController.h"
#import "Config.h"

@interface PhotoCollectionViewController () {
    @private
    //BOOL isFirstLoading;
    BOOL reachedEndPage;
    MTStatusBarOverlay *overlayStatusBar;
    CGSize viewSize;
    RotationNavigationControllerViewController *bigPhotoNavigationController;
    BOOL dismissUploadPreparingHUD, isLoadingPhotos;
#ifdef ACTIVE_PRINT_MODE
    BOOL printMode;
#endif
}

@end

@implementation PhotoCollectionViewController

#pragma mark - Init

- (id)initWithRootViewController:(UIViewController*)rootViewController withSize:(CGSize)size
{
    self = [super initWithNibName:@"PhotoCollectionViewController" bundle:nil];
    if(self) {
        
        self.rootViewController = (RootOngletsViewController*)rootViewController;
        self.pageNumber = 1;
        reachedEndPage = NO;
        //isFirstLoading = YES;
        
        // Status Bar init
        overlayStatusBar = [MTStatusBarOverlay sharedInstance];
        overlayStatusBar.progress = 0.0;
        
        // Loader photos
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadPhotosFromPage:self.pageNumber];
        });
    }
    return self;
}

- (id)initWithMoment:(MomentClass *)moment
withRootViewController:(UIViewController *)rootViewController
            withSize:(CGSize)size;
{
    self = [self initWithRootViewController:rootViewController withSize:size];
    if(self) {
        self.moment = moment;
        self.style = PhotoViewControllerStyleComplete;
    }
    return self;
}

- (id)initWithUser:(UserClass *)user
withRootViewController:(UIViewController *)rootViewController
          withSize:(CGSize)size
{
    self = [self initWithRootViewController:rootViewController withSize:size];
    if(self) {
        self.user = user;
        self.style = PhotoViewControllerStyleProfil;
    }
    return self;
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsView {
    [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Photo"];
}

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Photos"
     withAction:action
     withLabel:label
     withValue:value];
}

#pragma mark - View manager

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Google Analytics
    [self sendGoogleAnalyticsView];
    
    [AppDelegate updateActualViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iPhone 5 Support
    // View frame
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading_Photos", nil);
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.photos = [NSMutableArray array];
    
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    //self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    /* Uncomment this block to use nib-based cells */
    //UINib *cellNib = [UINib nibWithNibName:@"PhotoCollectionPlusCell" bundle:nil];
    //[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"PhotoCollectionPlusCellIdentifier"];
    /* end of nib-based cells block */
    
    /* uncomment this block to use subclassed cells */
    [self.collectionView registerClass:[PhotoCollectionPlusCell class] forCellWithReuseIdentifier:@"PhotoCollectionPlusCellIdentifier"];
    [self.collectionView registerClass:[PhotoCollectionCell class] forCellWithReuseIdentifier:@"PhotoCollectionCellIdentifier"];
    /* end of subclass-based cells block */
    
    // Configure layout
    //UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //[flowLayout setItemSize:CGSizeMake(200, 200)];
    //[flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    //[self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
     [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
     
     [self.imageDownloadsInProgress removeAllObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - UICollectionView delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photos count]+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item == 0) {
        
        static NSString *CellIdentifier = @"PhotoCollectionPlusCellIdentifier";
        PhotoCollectionPlusCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIImage *normal = [UIImage imageNamed:@"bouton_plus_photo_surface.png"];
        UIImage *enfonce = [UIImage imageNamed:@"bouton_plus_photo_enfonce.png"];
        
        [cell.plusButton setImage:normal forState:UIControlStateNormal];
        [cell.plusButton setImage:enfonce forState:UIControlStateSelected];
        [cell.plusButton setImage:enfonce forState:UIControlStateHighlighted];
        [cell.plusButton addTarget:self action:@selector(showPhotoActionSheet) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        
        static NSString *CellIdentifier = @"PhotoCollectionCellIdentifier";
        PhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Photos *photo = [self.photos objectAtIndex:indexPath.item-1];
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!photo.imageThumbnail)
        {
            if (self.collectionView.dragging == NO && self.collectionView.decelerating == NO)
            {
                [self startIconDownload:photo forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.photoView.image = [UIImage imageNamed:@"cover_defaut.png"];
            cell.photoView.contentMode = UIViewContentModeScaleAspectFill;
            cell.photoView.clipsToBounds = YES;
        }
        else
        {
            //NSLog(@"photo.urlThumbnail = %@",photo.urlThumbnail);
            cell.photoView.image = photo.imageThumbnail;
            cell.photoView.contentMode = UIViewContentModeScaleAspectFill;
            cell.photoView.clipsToBounds = YES;
        }
     
        return cell;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item > 0) {
        
        if([self.photos count] > 0)
        {
            
            PhotoCollectionCell *selectedCell = (PhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
            
            UIView *overlayCell = [[UIView alloc] initWithFrame:selectedCell.frame];
            [overlayCell setBackgroundColor:[UIColor grayColor]];
            [overlayCell setAlpha:0.5];
            
            [collectionView addSubview:overlayCell];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [overlayCell removeFromSuperview];
            });
            
            
            // Google Analytics
            [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Photo" value:nil];
            
            // Afficher Big Photo
            [self.bigPhotoViewController showViewAtIndex:indexPath.item-1 fromParent:YES];
            //[self.rootViewController presentViewController:self.bigPhotoViewController animated:NO completion:nil];
            self.navigationController.navigationBar.hidden = YES;
            
            if(!bigPhotoNavigationController)
                bigPhotoNavigationController = [[RotationNavigationControllerViewController alloc] initWithRootViewController:self.bigPhotoViewController];
            
            bigPhotoNavigationController.activeRotation = NO;
            bigPhotoNavigationController.navigationBar.hidden = YES;
            [self.rootViewController presentViewController:bigPhotoNavigationController animated:NO completion:nil];
        }
    }
}

#pragma mark - Collection cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(Photos *)photo forIndexPath:(NSIndexPath *)indexPath
{
    PhotoDownloader *photoDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (photoDownloader == nil)
    {
        photoDownloader = [[PhotoDownloader alloc] init];
        photoDownloader.photo = photo;
        [photoDownloader setCompletionHandler:^{
            
            PhotoCollectionCell *cell = (PhotoCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.photoView.image = photo.imageThumbnail;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:photoDownloader forKey:indexPath];
        [photoDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([self.photos count] > 0)
    {
        NSArray *visibleItems = [self.collectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visibleItems)
        {
            if (indexPath.item > 0) {
                
                Photos *photo = [self.photos objectAtIndex:indexPath.item-1];
                
                if (!photo.imageThumbnail)
                    // Avoid the app icon download if the app already has an icon
                {
                    [self startIconDownload:photo forIndexPath:indexPath];
                }
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
    {
        // then we are at the end
        
        if (!reachedEndPage) {
            self.pageNumber = self.pageNumber+1;
            [self loadPhotosFromPage:self.pageNumber];
        }
        
    }/* else if (scrollOffset == 0)
    {
        // then we are at the top
    }*/
}

#pragma mark - Loading Photo pages

- (void)loadPhotosFromPage:(int)pageNumber
{    
    //isLoadingPhotos = YES;
    
    // Loader soit à partir du moment soit à partir du user
    id loader = (self.style == PhotoViewControllerStyleComplete)? self.moment : self.user;
    
    [loader getPhotosFromPage:pageNumber withEnded:^(NSArray *photos) {
        
        dispatch_queue_t loadingQueue = dispatch_queue_create("PhotosLoadingQueue", NULL);
        dispatch_async(loadingQueue, ^{
            
            if (photos.count == 0) {
                reachedEndPage = YES;
            } else {
                [self.photos addObjectsFromArray:photos];
                
                if (self.pageNumber > 1) {
                    // Augmenter taille de la scroll view de la big photo
                    CGSize size = self.bigPhotoViewController.photoScrollView.contentSize;
                    size.width = [self.photos count]*self.bigPhotoViewController.photoScrollView.frame.size.width;
                    self.bigPhotoViewController.photoScrollView.contentSize = size;
                    
                    // Update BigPhoto Background
                    [self.bigPhotoViewController updateBackground];
                }
            }
        });
        dispatch_release(loadingQueue);
        
        
        if(self.style == PhotoViewControllerStyleProfil) {
            ProfilViewController *profil = (ProfilViewController*)self.rootViewController;
            [profil updateNbPhotos:[self.photos count]];
        }
        
        
        [self.collectionView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }];
    
}

#pragma mark - Plus button

-(void)clicPlusButton
{
    // Si on est invité, on peux ajouter une photo
    // User State
    enum UserState state = self.moment.state.intValue;
    if(state == 0) {
        state = ([self.moment.owner.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]) ? UserStateOwner : UserStateNoInvited;
    }
    if(
       (
        (
         (self.moment.privacy.intValue == MomentPrivacyFriends)||(self.moment.privacy.intValue == MomentPrivacySecret))
        && (state != UserStateNoInvited)
        ) ||
       (self.moment.privacy.intValue == MomentPrivacyOpen)
       )
    {
        
        // Google Analytics
        [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Ajout" value:nil];
        
        [self showPhotoActionSheet];
    }
    // Pas le droit d'ajouter une photo
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PhotoViewController_AlertView_NoPermissionAddPhoto_Title", nil)
                                    message:NSLocalizedString(@"PhotoViewController_AlertView_NoPermissionAddPhoto_Message", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                          otherButtonTitles:nil]
         show];
    }
}

- (void)showPhotoActionSheet {
    // Add Picture
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"ActionSheet_PeekPhoto_Title", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"ActionSheet_PeekPhoto_Button_Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  NSLocalizedString(@"ActionSheet_PeekPhoto_Button_PhotoLibrary", nil),
                                  NSLocalizedString(@"ActionSheet_PeekPhoto_Button_Camera", nil),
                                  nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

#pragma mark - Getters

- (BigPhotoViewController*)bigPhotoViewController {
    if(!_bigPhotoViewController) {
        
        // On est dans les onglets
        if(self.style == PhotoViewControllerStyleComplete) {
            _bigPhotoViewController = [[BigPhotoViewController alloc]
                                       initWithMoment:self.moment
                                       withPhotos:self.photos
                                       withRootViewController:self.rootViewController
                                       withDelegate:self];
        }
        // On est dans le profil
        else {
            _bigPhotoViewController = [[BigPhotoViewController alloc]
                                       initWithUser:self.user
                                       withPhotos:self.photos
                                       withRootViewController:self.rootViewController
                                       withDelegate:self];
        }
        
        // Init view before any action on it (call loadView and viewDidLoad)
        [_bigPhotoViewController.view setNeedsDisplay];
    }
    return _bigPhotoViewController;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    // Choix de la source de la photo
    
    switch (buttonIndex) {
            
        // Albums Photo
        case 0: {
            
            // Google Analytics
            [self sendGoogleAnalyticsEvent:@"Clic ActionSheet" label:@"Choix Album" value:nil];
            
            // Create the an album controller and image picker
            
            if (self.imagePicker == nil) {
                ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
                ELCImagePickerController *imagePickerController = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
                imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
                imagePickerController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
                albumController.parent = imagePickerController;
                imagePickerController.delegate = self;
                
                self.imagePicker = imagePickerController;
                
                // Present modally
                [self performSelector:@selector(getImagePickers:) withObject:@[self.imagePicker, self.rootViewController, @YES] afterDelay:0.1];
            } else {
                [self performSelector:@selector(dismissImagePickers:) withObject:@[self.rootViewController, @YES] afterDelay:0.1];
            }
        }
            break;
            
        // Camera
        case 1: {
            
            // Google Analytics
            [self sendGoogleAnalyticsEvent:@"Clic ActionSheet" label:@"Choix Appareil Photo" value:nil];
            
            if (self.picker == nil) {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.delegate = self;
                
                self.picker = imagePickerController;
                
                [self performSelector:@selector(getImagePickers:) withObject:@[self.picker, self.rootViewController, @YES] afterDelay:0.1];
            } else {
                [self performSelector:@selector(dismissImagePickers:) withObject:@[self.rootViewController, @YES] afterDelay:0.1];
            }
        }
            break;
    }
}

#pragma mark - Modal View methods

- (void)getImagePickers:(NSArray *)parameters
{
    [parameters[1] presentViewController:parameters[0] animated:parameters[2] completion:nil];
}

- (void)dismissImagePickers:(NSArray *)parameters
{
    [parameters[0] dismissViewControllerAnimated:parameters[1] completion:nil];
    
    if ([self.picker isEqual:parameters[0]]) {
        //NSLog(@"C'était un picker normal.");
        self.picker = nil;
    } else if ([self.imagePicker isEqual:parameters[0]]) {
        //NSLog(@"C'était un picker ELC.");
        self.imagePicker = nil;
    }
}

#pragma mark - ELCImagePickerControllerDelegate

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    //NSLog(@"elcImagePickerController | didFinishPickingMediaWithInfo");
    
    [self performSelector:@selector(dismissImagePickers:) withObject:@[self.rootViewController, @YES]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_UploadPreparing", nil);
    
    dismissUploadPreparingHUD = NO;
    
    self.mediaInfo = info.copy;
    info = nil;
    
    //[NSThread detachNewThreadSelector:@selector(stackImages:) toTarget:self withObject:@[info, picker]];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        //
        //NSLog(@"stackImages in thread now...");
        [self stackImages:@[self.mediaInfo, picker]];
    });
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    //NSLog(@"elcImagePickerControllerDidCancel");
    [self performSelector:@selector(dismissImagePickers:) withObject:@[self.rootViewController, @YES] afterDelay:0.1];
}

#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Dismiss
    [self performSelector:@selector(dismissImagePickers:) withObject:@[self.rootViewController, @YES]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_UploadPreparing", nil);
    
    dismissUploadPreparingHUD = NO;
    
    self.mediaInfo = info.copy;
    info = nil;
    
    NSLog(@"self.mediaInfo = %@", self.mediaInfo);
    
    //[NSThread detachNewThreadSelector:@selector(stackImages:) toTarget:self withObject:@[info, picker]];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        //
        //NSLog(@"stackImages in thread now...");
        [self stackImages:@[self.mediaInfo, picker]];
    });
}

- (void)stackImages:(NSArray *)parameters
{
    id mediaInfoArray = [parameters objectAtIndex:0];
    id picker = [parameters objectAtIndex:1];
    
    __block NSMutableArray *images = [NSMutableArray arrayWithCapacity:[mediaInfoArray count]];
    
    
    //NSLog(@"mediaInfoArray = %@",mediaInfoArray);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *photosPath = [documentsDirectory stringByAppendingPathComponent:@"PhotosCache"];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:photosPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:photosPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    
    // Load From Library
    if([picker isMemberOfClass:[ELCImagePickerController class]]) {
        
        //NSLog(@"Library | N° of Photos = %i",[mediaInfoArray count]);
        for( NSDictionary *attributes in mediaInfoArray ) {
            
            //NSLog(@"attributes = %@", attributes);
            
            // Resize Image
            //[images addObject:[[Config sharedInstance] imageWithMaxSize:attributes[@"UIImagePickerControllerOriginalImage"] maxSize:PHOTO_MAX_SIZE]];
            
            //NSData *imageData = UIImagePNGRepresentation([[Config sharedInstance] imageWithMaxSize:attributes[@"UIImagePickerControllerOriginalImage"] maxSize:PHOTO_MAX_SIZE]);
            NSData *imageData = UIImageJPEGRepresentation([[Config sharedInstance] imageWithMaxSize:attributes[@"UIImagePickerControllerOriginalImage"] maxSize:PHOTO_MAX_SIZE], 0.8);
            
            NSString *imageName = [NSString stringWithFormat:@"Photo_%f.png",[[NSDate date] timeIntervalSince1970]];
            
            NSString* fullPathToPhoto = [photosPath stringByAppendingPathComponent:imageName];
            //NSLog(@"Library | fullPathToFile = %@",fullPathToPhoto);
            
            [imageData writeToFile:fullPathToPhoto atomically:NO];
            imageData = nil;
            [images addObject:fullPathToPhoto];
        }
        
        mediaInfoArray = nil;
        self.mediaInfo = nil;
    }
    // Load from Camera
    else {
        
        UIImageWriteToSavedPhotosAlbum(mediaInfoArray[@"UIImagePickerControllerOriginalImage"], nil, nil, nil);
        
        NSLog(@"mediaInfoArray = %@",mediaInfoArray);
        
        // Get your image.
        NSData *imageData = UIImageJPEGRepresentation([[Config sharedInstance] imageWithMaxSize:mediaInfoArray[@"UIImagePickerControllerOriginalImage"] maxSize:PHOTO_MAX_SIZE], 0.8);
        
        NSString *imageName = [NSString stringWithFormat:@"Camera_%f.png",[[NSDate date] timeIntervalSince1970]];
        
        NSString *fullPathToPhoto = [photosPath stringByAppendingPathComponent:imageName];
        //NSLog(@"Camera | fullPathToFile = %@",fullPathToPhoto);
        
        [imageData writeToFile:fullPathToPhoto atomically:NO];
        imageData = nil;
        [images addObject:fullPathToPhoto];
        
        mediaInfoArray = nil;
        self.mediaInfo = nil;
    }
    
    if (images.count > 0) {
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            //
            //NSLog(@"images count first = %i",images.count);
            
            [self prepareForSendingToServer:images];
            
            images = nil;
        });
    }
}

- (void)prepareForSendingToServer:(NSMutableArray *)images
{
    
    //NSLog(@"prepareForSendingToServer...");
    //NSLog(@"images = %@",images);
    //NSLog(@"images count = %i",images.count);
    
    // ----- Envoi au Server -----
    
    // Disable the idle timer
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    int totalImages = [images count];
    //NSLog(@"totalImages = %i",totalImages);
    
    // Préload cadres des images
    //NSInteger nouvelleTaille = [self.photos count] + totalImages + 1; // Anciennes + Nouvelle + PLUS_BUTTON
#ifdef ACTIVE_PRINT_MODE
    //nouvelleTaille += (nouvelleTaille > PHOTOVIEW_PRINT_BUTTON_INDEX)? 1 : 0; // Si on atteint PRINT, on ajoute
#endif
    
    
    overlayStatusBar.progress = 0;
    __block NSInteger actualIndex = 0;
    __block NSInteger actualIndexForViewManipulation = 0;
    
    dismissUploadPreparingHUD = YES;
    
    [self.moment sendArrayOfPhotos:images withStart:^(NSString *photoPath) {
        
        // Message d'upload d'une unique photo
        if(totalImages == 1) {
            //NSLog(@"Message d'upload d'une unique photo");
            
            [overlayStatusBar postMessage:NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil)];
            
        }
        // Premier Status d'un envoi multiple
        else if([images indexOfObject:photoPath] == 0) {
            //NSLog(@"Premier Status d'un envoi multiple");
            
            [overlayStatusBar postMessage:
             [NSString stringWithFormat:@"%@ 1/%d", NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil),totalImages]
             ];
        }
        
        runOnMainQueuePhotoCollectionWithoutDeadlocking(^{
            if (dismissUploadPreparingHUD) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        });
        
    } withProgression:^(CGFloat progress) {
        
        // Status Bar Progression d'une unique photo
        //if(totalImages == 1)
        overlayStatusBar.progress = progress;
        
        // Status bar envoi partiel
        //else {
        //overlayStatusBar.progress = (actualIndex + (progress/totalImages))/totalImages;
        //}
        
    } withTransition:^(Photos *photo) {
        
        // Erreur d'envoi
        if(!photo) {
            //NSLog(@"Erreur d'envoi");
            [overlayStatusBar
             postImmediateErrorMessage:NSLocalizedString(@"Error_Send_Photo", nil)
             duration:2
             animated:YES];
        }
        // Success
        else
        {
            // Il faut forcer l'appel dans le Thread Principal pour que l'UI puisse être modifié
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.photos insertObject:photo atIndex:0];
                [self.collectionView reloadData];
            });
            
            // Indique la photo actuelle si il y a plusieurs photos
            if(totalImages > 1 && actualIndex+1 < totalImages) {
                actualIndex++;
                NSString *string = nil;
                string = [NSString stringWithFormat:@"%@ %d/%d", NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil), actualIndex+1, totalImages];
                
                overlayStatusBar.progress = 0;
                [overlayStatusBar postMessage:string];
            }
            
            // Incrémentation de l'index
            actualIndexForViewManipulation++;
            
            // Si on est sur la page de chargement de photo
            /*UIViewController *actualViewController = [AppDelegate actualViewController];
            if(actualViewController == self) {
                // Scroll to top
                UIScrollView *scrollView = self.imageShowCase.scrollView;
                [scrollView scrollRectToVisible:CGRectMake(0, 0, 320, scrollView.frame.size.height) animated:YES];
                
            }*/
            
            // Save photo and update view
            //[self.photos insertObject:photo atIndex:(actualIndexForViewManipulation-1)];
            
            //NSLog(@"loadImageThumbnailWithPhoto starting...");
            /*[self loadImageThumbnailWithPhoto:photo withEnded:^(UIImage *image) {
                
                NSInteger index = [self convertIndexForCurrentStyle:actualIndexForViewManipulation];
                
                if (image) {
                    // Update Photo View
                    [self.imageShowCase addImage:image atIndex:index isPlusButton:NO isPrintButton:NO];
                    
                    // Augmenter taille de la scroll view de la big photo
                    CGSize size = self.bigPhotoViewController.photoScrollView.contentSize;
                    size.width = [self.photos count]*self.bigPhotoViewController.photoScrollView.frame.size.width;
                    self.bigPhotoViewController.photoScrollView.contentSize = size;
                    
                    // Update BigPhoto Background
                    [self.bigPhotoViewController updateBackground];
                }
            }];*/
            
            //NSLog(@"On reload la vue...");
            [self.rootViewController.infoMomentViewController reloadData];
        }
        
    } withEnded:^ {
        [images removeAllObjects];
        
        // Status Bar Finished
        [overlayStatusBar postFinishMessage:NSLocalizedString(@"StatusBarOverlay_Photo_UploadEnded", nil) duration:2];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        
        // Activate the idle timer
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }];
}

#pragma Dispatch methods

void runOnMainQueuePhotoCollectionWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
