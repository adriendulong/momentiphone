//
//  PhotoViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PhotoViewController.h"
#import "MomentClass+Server.h"
#import "Photos.h"
#import "Config.h"
#import "UserClass+Server.h"
#import "ProfilViewController.h"
#import "PrintFormViewController.h"
#import "RotationNavigationControllerViewController.h"

@interface PhotoViewController () {
    @private
    MTStatusBarOverlay *overlayStatusBar;
    CGSize viewSize;
    BOOL printMode;
    RotationNavigationControllerViewController *bigPhotoNavigationController;
}

@end

@implementation PhotoViewController

@synthesize user = _user;
@synthesize moment = _moment;
@synthesize photos = _photos;
@synthesize rootViewController = _rootViewController;
@synthesize bigPhotoViewController = _bigPhotoViewController;
@synthesize imageShowCase = _imageShowCase;
@synthesize printSelectedCells = _printSelectedCells;
@synthesize bandeauView = _bandeauView;
@synthesize arrowWhiteView = _arrowWhiteView;
@synthesize nbPhotosToPrintLabel = _nbPhotosToPrintLabel;
@synthesize photosSelectionnesLabel = _photosSelectionnesLabel;
@synthesize panierImgeView = _panierImgeView;

#pragma mark - Init

- (id)initWithRootViewController:(UIViewController*)rootViewController withSize:(CGSize)size
{
    self = [super initWithNibName:@"PhotoViewController" bundle:nil];
    if(self) {
        
        self.rootViewController = (RootOngletsViewController*)rootViewController;
        viewSize = size;
        
        // Status Bar init
        overlayStatusBar = [MTStatusBarOverlay sharedInstance];
        overlayStatusBar.progress = 0.0;
        printMode = NO;
        self.printSelectedCells = [[NSMutableArray alloc] init];
        bigPhotoNavigationController = nil;
        
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

#pragma mark - Load

- (NSInteger)convertIndexForCurrentStyle:(NSInteger)index
{
    if(self.style == PhotoViewControllerStyleComplete)
    {
        if(index < PHOTOVIEW_PRINT_BUTTON_INDEX)
            return index;
        return index + 1;
    }
    else
    {
        return index - 1;
        //return index;
    }
}

- (void)loadPhotos
{
    // Loader soit à partir du moment soit à partir du user
    id loader = (self.style == PhotoViewControllerStyleComplete)? self.moment : self.user;
        
    [loader getPhotosWithEnded:^(NSArray *photos) {
                
        dispatch_queue_t loadingQueue = dispatch_queue_create("PhotosLoadingQueue", NULL);
        dispatch_async(loadingQueue, ^{
            
            self.photos = photos.mutableCopy;
            [self.imageShowCase updateItemsShowCaseWithSize:[self.photos count]+1];
            
            int i=0;

            for (Photos *p in self.photos) {
                [self loadImageThumbnailWithPhoto:p withEnded:^(UIImage *image) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                                                
                        NSInteger index = ([self.photos indexOfObject:p]+1);
                        
                        // Ajout du bouton print à la 5e position
                        if( (self.style == PhotoViewControllerStyleComplete) && index == PHOTOVIEW_PRINT_BUTTON_INDEX) {
                            [self.imageShowCase addImage:nil atIndex:index isPlusButton:NO isPrintButton:YES];
                        }
                        
                        // Index varie selon le numero de la photo et la page sur laquelle on est (Profil / Onglet)
                        index = [self convertIndexForCurrentStyle:index];
                        // Ajout photo classique
                        [self.imageShowCase addImage:image atIndex:index isPlusButton:NO isPrintButton:NO];
                        if(i == ([self.photos count]-1) ) {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }
                    });
                    
                }];
                i++;
            }
        });
        dispatch_release(loadingQueue);
        
        
        if(self.style == PhotoViewControllerStyleProfil) {
            ProfilViewController *profil = (ProfilViewController*)self.rootViewController;
            [profil updateNbPhotos:[self.photos count]];
        }
        
    }];

}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(viewSize.width, viewSize.height);
    self.view.frame = frame;
     
    // HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    _imageShowCase = [[NLImageShowCase alloc] initWithFrame:self.view.frame];
    _imageShowCase.clipsToBounds = NO;
    self.view.clipsToBounds = NO;
    _imageShowCase.dataSource = self;
    _imageShowCase.photoViewControllerStyle = self.style;
    [_imageShowCase setDeleteMode:NO];;
    
    _imageShowCase.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    if(self.style == PhotoViewControllerStyleComplete) {
        [_imageShowCase addImage:nil atIndex:0 isPlusButton:YES isPrintButton:NO];
    }
    
    _imageShowCase.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    [self.view addSubview:_imageShowCase];
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    // Init Bandeau
    [self initBandeau];
    
    // Loader photos
    [self loadPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBandeauView:nil];
    [self setPanierImgeView:nil];
    [self setNbPhotosToPrintLabel:nil];
    [self setPhotosSelectionnesLabel:nil];
    [self setArrowWhiteView:nil];
    [super viewDidUnload];
}

#pragma mark - Image Showcase Protocol
- (CGSize)imageViewSizeInShowcase:(NLImageShowCase *) imageShowCase
{
    // Complete Style
    if(self.style == PhotoViewControllerStyleComplete)
        return CGSizeMake(95, 95);
    
    // Profil Style
    return CGSizeMake(115, 115);
    
}
- (CGFloat)imageLeftOffsetInShowcase:(NLImageShowCase *) imageShowCase
{
    // Complete Style
    if(self.style == PhotoViewControllerStyleComplete)
        return 9.0f;
    
    // Profil Style
    return 7.0f;
}

- (CGFloat)imageTopOffsetInShowcase:(NLImageShowCase *) imageShowCase
{
    return 9.0f;
}
- (CGFloat)rowSpacingInShowcase:(NLImageShowCase *) imageShowCase
{
    return 7.0f;
}
- (CGFloat)columnSpacingInShowcase:(NLImageShowCase *) imageShowCase
{
    return 7.0f;
}

// Index réelle (dans le tableau des photos NSArray <Photos*>
- (NSInteger)convertIndexForDataForCurrentStyle:(NSInteger)index
{
    switch (self.style) {
        case PhotoViewControllerStyleComplete:
            if(index>=PHOTOVIEW_PRINT_BUTTON_INDEX-1)
                return index-1;
            return index;
            break;
            
        case PhotoViewControllerStyleProfil:
            return index;
            break;
    }
}

- (void)imageClicked:(NLImageShowCase *)imageShowCase imageShowCaseCell:(NLImageShowCaseCell *)imageShowCaseCell;
{
    
    // Plus Button
    if( (self.style == PhotoViewControllerStyleComplete) && (imageShowCaseCell.index == 0) && imageShowCaseCell.isSpecial )
    {
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
    //  Print Button
    else if( (self.style == PhotoViewControllerStyleComplete) && (imageShowCaseCell.index == PHOTOVIEW_PRINT_BUTTON_INDEX) && imageShowCaseCell.isSpecial )
    {

        // Désactiver Print Mode
        if(printMode) {
            [self desactiverPrintMode];
        }
        // Activer Mode Print
        else {
            [self activerPrintMode];
        }
        
        
    }
    // Classic Button
    else {
        
        if(printMode)
        {
            NSInteger index = [self convertIndexForDataForCurrentStyle:imageShowCaseCell.index];
            
            // Ajouter/Retirer Mémoire
            if(imageShowCaseCell.printSelected)
                [self.printSelectedCells removeObject:self.photos[index]]; // Retirer
            else
                [self.printSelectedCells addObject:self.photos[index]]; // Ajouter
            
            // Afficher/Cacher Check
            [imageShowCaseCell togglePrintSelect];
            
            // Update Bandeau
            [self updateBandeau];
        }
        else
        {
            // Afficher Big Photo
            [self.bigPhotoViewController showViewAtIndex:imageShowCaseCell.index fromParent:YES];
            //[[VersionControl sharedInstance] presentModalViewController:self.bigPhotoViewController fromRoot:self.rootViewController animated:NO];
            self.navigationController.navigationBar.hidden = YES;
            
            if(!bigPhotoNavigationController)
                bigPhotoNavigationController = [[RotationNavigationControllerViewController alloc] initWithRootViewController:self.bigPhotoViewController];
            
            bigPhotoNavigationController.activeRotation = NO;
            bigPhotoNavigationController.navigationBar.hidden = YES;
            [[VersionControl sharedInstance] presentModalViewController:bigPhotoNavigationController fromRoot:self.rootViewController animated:NO];
            
            //[self.rootViewController.timeLine.navController pushViewController:self.bigPhotoViewController animated:NO];
        }
        
    }
}

- (void)imageTouchLonger:(NLImageShowCase *)imageShowCase imageIndex:(NSInteger)index;
{
}

#pragma mark - Bandeau

- (void)activerPrintMode
{
    if(!printMode)
    {
        printMode = YES;
        
        // Afficher bandeau
        [self afficherBandeau];
        
        // Changer aspet print button
        [[self.imageShowCase.itemsInShowCase[PHOTOVIEW_PRINT_BUTTON_INDEX] mainImage] setSelected:YES];
    }
}

- (void)desactiverPrintMode
{
    if(printMode)
    {
        printMode = NO;
        
        // Cacher check
        for( NLImageShowCaseCell *cell in self.imageShowCase.itemsInShowCase ) {
            if(cell.printSelected)
                [cell togglePrintSelect];
        }
        
        // Vider Photos
        [self.printSelectedCells removeAllObjects];
        
        // Cacher bandeau
        [self cacherBandeau];
        
        // Changer aspet print button
        [[self.imageShowCase.itemsInShowCase[PHOTOVIEW_PRINT_BUTTON_INDEX] mainImage] setSelected:NO];
    }
}

- (void)initBandeau
{
    if(self.style == PhotoViewControllerStyleComplete)
    {
        CGRect frame = self.bandeauView.frame;
        frame.origin.x = 0;
        frame.origin.y = -frame.size.height;
        self.bandeauView.frame = frame;
        [self.view addSubview:self.bandeauView];
        
        self.bandeauView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_panier"]];
        self.bandeauView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self.photosSelectionnesLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
        self.nbPhotosToPrintLabel.font = [[Config sharedInstance] defaultFontWithSize:16];
        
        // Clic
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicBandeau)];
        [self.bandeauView addGestureRecognizer:tap];
    }
}

- (void)updateBandeau
{
    NSInteger count = [self.printSelectedCells count];
    
    // Phrase
    if(count > 1)
        self.photosSelectionnesLabel.text = NSLocalizedString(@"PhotoViewController_Bandeau_photosSelectionneesLabel_Pluriel", nil);
    else
        self.photosSelectionnesLabel.text = NSLocalizedString(@"PhotoViewController_Bandeau_photosSelectionneesLabel_Singulier", nil);
    [self.photosSelectionnesLabel sizeToFit];
    CGRect frame = self.photosSelectionnesLabel.frame;
    frame.origin.y =  (self.bandeauView.frame.size.height - frame.size.height)/2.0;
    self.photosSelectionnesLabel.frame = frame;
    
    // Nb
    self.nbPhotosToPrintLabel.text = [NSString stringWithFormat:@"%d", count];
    [self.nbPhotosToPrintLabel sizeToFit];
    frame = self.nbPhotosToPrintLabel.frame;
    frame.origin.y = (self.bandeauView.frame.size.height - frame.size.height)/2.0;
    self.nbPhotosToPrintLabel.frame = frame;
    
    // Centrer
    CGFloat origin = self.panierImgeView.frame.origin.x + self.panierImgeView.frame.size.width;
    frame.origin.x = ( origin + self.arrowWhiteView.frame.origin.x - (frame.size.width + self.photosSelectionnesLabel.frame.size.width + 5) )/2.0;
    self.nbPhotosToPrintLabel.frame = frame;
    frame = self.photosSelectionnesLabel.frame;
    frame.origin.x = self.nbPhotosToPrintLabel.frame.origin.x + self.nbPhotosToPrintLabel.frame.size.width + 5;
    self.photosSelectionnesLabel.frame = frame;    
}

- (void)afficherBandeau
{
    [self updateBandeau];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect frame = self.imageShowCase.frame;
        frame.size.height -= self.bandeauView.frame.size.height;
        frame.origin.y += self.bandeauView.frame.size.height;
        self.imageShowCase.frame = frame;
        frame.origin.y = 0;
        self.imageShowCase.scrollView.frame = frame;
        
        frame = self.bandeauView.frame;
        frame.origin.y = 0;
        self.bandeauView.frame = frame;
        
    }];
}

- (void)cacherBandeau
{
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect frame = self.imageShowCase.frame;
        frame.size.height = viewSize.height;
        frame.origin.y = 0;
        self.imageShowCase.frame = frame;
        self.imageShowCase.scrollView.frame = frame;
        
        frame = self.bandeauView.frame;
        frame.origin.y = -frame.size.height;
        self.bandeauView.frame = frame;
        
    }];
}

- (void)clicBandeau
{
    if([self.printSelectedCells count] > 0) {
        PrintFormViewController *form = [[PrintFormViewController alloc] initWithPhotosToPrint:self.printSelectedCells];
        [self.rootViewController.timeLine.navController pushViewController:form animated:YES];
        
        [self performSelector:@selector(desactiverPrintMode) withObject:nil afterDelay:1];
    }
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
    
    switch (buttonIndex) {
        case 0: {
            QBImagePickerController *picker = [[QBImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsMultipleSelection = YES;
            picker.filterType = QBImagePickerFilterTypeAllPhotos;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:picker];
            
            [[VersionControl sharedInstance] presentModalViewController:navigationController fromRoot:self.rootViewController animated:YES];
        }
            break;
            
        case 1:{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [[VersionControl sharedInstance] presentModalViewController:picker fromRoot:self.rootViewController animated:YES];
        }
            break;
            
    }
    
    
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    // Dismiss
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self.rootViewController animated:YES];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    // Load From Library
    if([imagePickerController isMemberOfClass:[QBImagePickerController class]]) {
        
        // Conversion
        NSArray *mediaInfoArray = (NSArray *)info;

        for( NSDictionary *attributes in mediaInfoArray ){
            
            // Resize Image if needed
            UIImage *imageCropped = [[Config sharedInstance] imageWithMaxSize:attributes[@"UIImagePickerControllerOriginalImage"] maxSize:PHOTO_MAX_SIZE];
            
            [images addObject:imageCropped];
        }
    }
    // Load from Camera
    else {
        UIImage *image = [[Config sharedInstance] imageWithMaxSize:info[@"UIImagePickerControllerOriginalImage"] maxSize:PHOTO_MAX_SIZE];
        [images addObject:image];
    }
    
    // ----- Evoi au Server -----
    int totalImages = [images count];
    
    // Péload cadres des images
    NSInteger nouvelleTaille = [self.photos count] + totalImages + 1; // Anciennes + Nouvelle + PLUS_BUTTON
    nouvelleTaille += (nouvelleTaille > PHOTOVIEW_PRINT_BUTTON_INDEX)? 1 : 0; // Si on atteint PRINT, on ajoute
    [self.imageShowCase updateItemsShowCaseWithSize:nouvelleTaille];
    
    overlayStatusBar.progress = 0;
    __block NSInteger actualIndex = 0;
    [self.moment sendArrayOfPhotos:images withStart:^(UIImage *photo) {
        
        // Message d'upload d'une unique photo
        if(totalImages == 1) {
            
            [overlayStatusBar postMessage:NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil)];
            
        }
        // Premier Status d'un envoi multiple
        else if([images indexOfObject:photo] == 0) {
            
            [overlayStatusBar postMessage:
             [NSString stringWithFormat:@"%@ 1/%d", NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil),totalImages]
             ];
        }
        
    } withProgression:^(CGFloat progress) {
                
        // Status Bar Progression d'une unique photo
        if(totalImages == 1)
            overlayStatusBar.progress = progress;
        // Status bar envoi partiel
        else {
            overlayStatusBar.progress = (actualIndex + (progress/totalImages))/totalImages;
        }
        
    } withTransition:^(Photos *photo) {
        
        // Erreur d'envoi
        if(!photo) {
            [overlayStatusBar postImmediateErrorMessage:@"Erreur d'envoi de la photo"
                                               duration:1
                                               animated:YES];
        }
        // Success
        else
        {
            // Indique la photo actuelle si il y a plusieurs photos
            if(totalImages > 1 && actualIndex+1 < totalImages) {
                actualIndex++;
                NSString *string = nil;
                string = [NSString stringWithFormat:@"%@ %d/%d", NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil), actualIndex+1, totalImages];
                
                [overlayStatusBar postMessage:string];
                //overlayStatusBar.progress = (float)index/totalImages;
            }
            
            // Si on est sur la page de chargement de photo
            UIViewController *actualViewController = [AppDelegate actualViewController];
            if(actualViewController == self) {
                // Scroll to bottom
                UIScrollView *scrollView = self.imageShowCase.scrollView;
                [scrollView scrollRectToVisible:CGRectMake(0, scrollView.contentSize.height - scrollView.frame.size.height, 320, scrollView.frame.size.height) animated:YES];
                
            }
            
            
            // Save photo and update view
            [self.photos addObject:photo];
            [self loadImageThumbnailWithPhoto:photo withEnded:^(UIImage *image) {
                
                
                NSInteger index = [self.photos count];
                index = [self convertIndexForCurrentStyle:index];
                
                // Update Photo View
                [self.imageShowCase addImage:image atIndex:index isPlusButton:NO isPrintButton:NO];
                
                // Augmenter taille de la scroll view de la big photo
                CGSize size = self.bigPhotoViewController.photoScrollView.contentSize;
                size.width += self.bigPhotoViewController.photoScrollView.frame.size.width;
                self.bigPhotoViewController.photoScrollView.contentSize = size;
                
                // Update Vue InfoMoment
                [self.rootViewController.infoMomentViewController reloadData];
                
                // Update BigPhoto Background
                [self.bigPhotoViewController updateBackground];
                
            }];
        }
        
    } withEnded:^ {
        
        // Status Bar Finished
        [overlayStatusBar postFinishMessage:NSLocalizedString(@"StatusBarOverlay_Photo_UploadEnded", nil) duration:1];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        
    }];
}

- (void)loadImageThumbnailWithPhoto:(Photos*)photo withEnded:(void (^) (UIImage*image))block
{
    CustomUIImageView *imageView = [[CustomUIImageView alloc] init];
    [imageView setImage:photo.imageThumbnail imageString:photo.urlThumbnail withSaveBlock:^(UIImage *image) {
        
        photo.imageThumbnail = image;
        
        if(block)
            block(image);
        
    }];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    // Dismiss
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self.rootViewController animated:YES];
}

- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController
{
    // Label "Sélectionner toutes les photos"
    return NSLocalizedString(@"MutlipleImagePickerViewController_SelectAll", nil);
}

- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController
{
    // Label "Déselectionner toutes les photos"
    return NSLocalizedString(@"MutlipleImagePickerViewController_DeselectAll", nil);
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    // Label "%d Photos"
    return [NSString stringWithFormat:NSLocalizedString(@"MutlipleImagePickerViewController_NumberOfPhotos", nil), numberOfPhotos];
}
/*
- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:NSLocalizedString(@"MutlipleImagePickerViewController_NumberOfVideos", nil), numberOfVideos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:NSLocalizedString(@"MutlipleImagePickerViewController_NumberOfPhotosAndVideos", nil), numberOfPhotos, numberOfVideos];
}
*/


@end
