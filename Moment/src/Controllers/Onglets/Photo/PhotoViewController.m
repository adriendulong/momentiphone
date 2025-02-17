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
#import "ELCAlbumPickerController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PhotoViewController () {
    @private
    MTStatusBarOverlay *overlayStatusBar;
    CGSize viewSize;
    RotationNavigationControllerViewController *bigPhotoNavigationController;
    BOOL dismissUploadPreparingHUD, isLoadingPhotos;
#ifdef ACTIVE_PRINT_MODE
    BOOL printMode;
#endif
}

@end

@implementation PhotoViewController

@synthesize user = _user;
@synthesize moment = _moment;
@synthesize photos = _photos;
@synthesize rootViewController = _rootViewController;
@synthesize bigPhotoViewController = _bigPhotoViewController;
@synthesize imageShowCase = _imageShowCase;
#ifdef ACTIVE_PRINT_MODE
@synthesize printSelectedCells = _printSelectedCells;
#endif
@synthesize bandeauView = _bandeauView;
@synthesize arrowWhiteView = _arrowWhiteView;
@synthesize nbPhotosToPrintLabel = _nbPhotosToPrintLabel;
@synthesize photosSelectionnesLabel = _photosSelectionnesLabel;
@synthesize panierImgeView = _panierImgeView;

@synthesize picker = _picker;
@synthesize imagePicker = _imagePicker;

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
#ifdef ACTIVE_PRINT_MODE
        printMode = NO;
        self.printSelectedCells = [[NSMutableArray alloc] init];
#endif
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
#ifdef ACTIVE_PRINT_MODE
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
#else
    if(self.style == PhotoViewControllerStyleComplete)
        return index;
    return index - 1;
#endif
}

- (void)loadPhotos
{
    
    isLoadingPhotos = YES;
    
    // Loader soit à partir du moment soit à partir du user
    id loader = (self.style == PhotoViewControllerStyleComplete)? self.moment : self.user;
        
    [loader getPhotosWithEnded:^(NSArray *photos) {
                
        dispatch_queue_t loadingQueue = dispatch_queue_create("PhotosLoadingQueue", NULL);
        dispatch_async(loadingQueue, ^{
            
            self.photos = photos.mutableCopy;
            NSInteger size = (self.style == PhotoViewControllerStyleComplete) ? [self.photos count]+1 : [self.photos count];
            [self.imageShowCase updateItemsShowCaseWithSize:size];
            
            int i=0;

            for (Photos *p in self.photos) {
                //NSLog(@"Photos = %@", p);
                
                [self loadImageThumbnailWithPhoto:p withEnded:^(UIImage *image) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                                                
                        NSInteger index = ([self.photos indexOfObject:p]+1);
                        
#ifdef ACTIVE_PRINT_MODE
                        // Ajout du bouton print à la 5e position
                        if( (self.style == PhotoViewControllerStyleComplete) && index == PHOTOVIEW_PRINT_BUTTON_INDEX) {
                            [self.imageShowCase addImage:nil atIndex:index isPlusButton:NO isPrintButton:YES];
                        }
#endif
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
            
            isLoadingPhotos = NO;
        });
        dispatch_release(loadingQueue);
        
        
        if(self.style == PhotoViewControllerStyleProfil) {
            ProfilViewController *profil = (ProfilViewController*)self.rootViewController;
            [profil updateNbPhotos:[self.photos count]];
        }
        
    }];

}

- (void)updateIndexesAfterDeletetion
{
   /* NSInteger size = [self.photos count];
    // Adapter taille
    if(self.style == PhotoViewControllerStyleComplete)
    {
        size++;
#ifdef ACTIVE_PRINT_MODE
        if( (index >= PHOTOVIEW_PRINT_BUTTON_INDEX) {
            size++;
        }
#endif
     }
    */

    // Update des index
    NSArray *cells = self.imageShowCase.itemsInShowCase;
    NSInteger i = 0;
    for(NLImageShowCaseCell *c in cells) {
        c.index = i;
        i++;
    }
    
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
#ifdef ACTIVE_PRINT_MODE
    [self initBandeau];
#endif
    
    dismissUploadPreparingHUD = NO;
    isLoadingPhotos = NO;
    
    // Loader photos
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadPhotos];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    /*if ([self.imagePicker isViewLoaded]) {
        NSLog(@"imagePicker est loaded");        
        
        [self performSelector:@selector(dismissImagePickers:) withObject:@[self.imagePicker, @YES] afterDelay:0.1];
    }
    
    if ([self.picker isViewLoaded]) {
        NSLog(@"picker est loaded");
        
        [self performSelector:@selector(dismissImagePickers:) withObject:@[self.picker, @YES] afterDelay:0.1];
    }
    
    //[self performSelector:@selector(dismissImagePickers:) withObject:@[self.imagePicker, @YES] afterDelay:0.1];*/
}

- (void)viewDidUnload {
    [self setBandeauView:nil];
    [self setPanierImgeView:nil];
    [self setNbPhotosToPrintLabel:nil];
    [self setPhotosSelectionnesLabel:nil];
    [self setArrowWhiteView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sendGoogleAnalyticsView];
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
#ifdef ACTIVE_PRINT_MODE
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
#endif
    return index;
}

- (void)imageClicked:(NLImageShowCase *)imageShowCase imageShowCaseCell:(NLImageShowCaseCell *)imageShowCaseCell;
{
    
    // Plus Button
    if( (self.style == PhotoViewControllerStyleComplete) && (imageShowCaseCell.index == 0) && imageShowCaseCell.isSpecial )
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
            
            if ([self uploadAlreadyInProgress]) {
                UIAlertView *uploadAlreadyInProgress = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PhotoViewController_AlertView_UploadAlreadyInProgress_Title", nil)
                                            message:NSLocalizedString(@"PhotoViewController_AlertView_UploadAlreadyInProgress_Message", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                  otherButtonTitles:nil];
                
                [uploadAlreadyInProgress show];
            } else if (isLoadingPhotos) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PhotoViewController_AlertView_PhotoLoading_Title", nil)
                                            message:NSLocalizedString(@"PhotoViewController_AlertView_PhotoLoading_Message", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                  otherButtonTitles:nil] show];
            } else {
                // Google Analytics
                [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Ajout" value:nil];
                                
                [self showPhotoActionSheet];
            }
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
    //  Print Button
    else if( (self.style == PhotoViewControllerStyleComplete) && (imageShowCaseCell.index == PHOTOVIEW_PRINT_BUTTON_INDEX) && imageShowCaseCell.isSpecial )
    {
    #ifdef ACTIVE_PRINT_MODE
        // Désactiver Print Mode
        if(printMode) {
            [self desactiverPrintMode];
        }
        // Activer Mode Print
        else {
            [self activerPrintMode];
        }
    #endif
        
        
    }
    // Classic Button
    else {
        
#ifdef ACTIVE_PRINT_MODE
        if(printMode)
        {
            // Google Analytics
            [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Photos sélectionnées" value:@([self.printSelectedCells count])];
            
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
#endif
            // Blindage
            NSInteger i;
            if(self.style == PhotoViewControllerStyleComplete)
                i = imageShowCaseCell.index-1;
            else
                i = imageShowCaseCell.index;
            
            if([self.photos count] > i)
            {
                // Google Analytics
                [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Photo" value:nil];
                
                // Afficher Big Photo
                [self.bigPhotoViewController showViewAtIndex:imageShowCaseCell.index fromParent:YES];
                //[self.rootViewController presentViewController:self.bigPhotoViewController animated:NO completion:nil];
                self.navigationController.navigationBar.hidden = YES;
                
                if(!bigPhotoNavigationController)
                    bigPhotoNavigationController = [[RotationNavigationControllerViewController alloc] initWithRootViewController:self.bigPhotoViewController];
                
                bigPhotoNavigationController.activeRotation = NO;
                bigPhotoNavigationController.navigationBar.hidden = YES;
                [self.rootViewController presentViewController:bigPhotoNavigationController animated:NO completion:nil];
            }
            
            
            //[self.rootViewController.timeLine.navController pushViewController:self.bigPhotoViewController animated:NO];
#ifdef ACTIVE_PRINT_MODE
        }
#endif
        
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

- (void)imageTouchLonger:(NLImageShowCase *)imageShowCase imageIndex:(NSInteger)index;
{
}

#pragma mark - Bandeau

#ifdef ACTIVE_PRINT_MODE
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
#endif

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
    
    // Choix de la soirce de la photo
    
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

#pragma mark - Photo Cache

- (BOOL)uploadAlreadyInProgress
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *photosPath = [documentsDirectory stringByAppendingPathComponent:@"PhotosCache"];
    
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *theError = nil;
    
    BOOL isDir;
    BOOL exists = [fileMgr fileExistsAtPath:photosPath isDirectory:&isDir];
    
    if (exists) {
        if (isDir) {
            if (theError == nil) {
                NSArray *listOfFiles = [fileMgr contentsOfDirectoryAtPath:photosPath error:nil];
                //NSLog(@"listOfFiles: %@", listOfFiles);
                
                if (listOfFiles && listOfFiles.count > 0) {
                    //NSLog(@"PhotosCache n'est pas vide. Un upload est déjà en cours...");
                    
                    return YES;
                } else {
                    NSLog(@"PhotosCache est vide ! L'upload est possible !");
                    
                    return NO;
                }
            } else {
                NSLog(@"PhotosCache: %@ | Error: %@",photosPath, theError);
            }
        }
    } else {
        return NO;
    }
    
    return nil;
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
    NSInteger nouvelleTaille = [self.photos count] + totalImages + 1; // Anciennes + Nouvelle + PLUS_BUTTON
#ifdef ACTIVE_PRINT_MODE
    nouvelleTaille += (nouvelleTaille > PHOTOVIEW_PRINT_BUTTON_INDEX)? 1 : 0; // Si on atteint PRINT, on ajoute
#endif    
    
    // Il faut forcer l'appel dans le Thread Principal pour que l'UI puisse être modifié
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageShowCase updateItemsShowCaseWithSize:nouvelleTaille atStart:YES];
    });
    
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
        
        runOnMainQueueWithoutDeadlocking(^{
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
            UIViewController *actualViewController = [AppDelegate actualViewController];
            if(actualViewController == self) {
                // Scroll to top
                UIScrollView *scrollView = self.imageShowCase.scrollView;
                [scrollView scrollRectToVisible:CGRectMake(0, 0, 320, scrollView.frame.size.height) animated:YES];
                
            }
            
            // Save photo and update view
            [self.photos insertObject:photo atIndex:(actualIndexForViewManipulation-1)];
            
            //NSLog(@"loadImageThumbnailWithPhoto starting...");
            [self loadImageThumbnailWithPhoto:photo withEnded:^(UIImage *image) {
                
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
            }];
            
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

- (void)loadImageThumbnailWithPhoto:(Photos*)photo withEnded:(void (^) (UIImage*image))block
{
    CustomUIImageView *imageView = [[CustomUIImageView alloc] init];
    [imageView setImage:photo.imageThumbnail imageString:photo.urlThumbnail withSaveBlock:^(UIImage *image) {
        
        photo.imageThumbnail = image;
        
        if(block)
            block(image);
        
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertView *alert;
    
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_Title", nil)
                                           message:error.localizedDescription
                                          delegate:nil
                                 cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                 otherButtonTitles:nil];
        [alert show];
    }
    
}

#pragma Dispatch methods

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
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
