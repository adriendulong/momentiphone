//
//  BigPhotoViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "BigPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Config.h"
#import "CustomUIImageView.h"
#import "Photos.h"
#import "UserCoreData+Model.h"
#import "MTStatusBarOverlay.h"
#import "Three20/Three20.h"
#import "RotationNavigationControllerViewController.h"

#import "DEFacebookComposeViewController.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@interface BigPhotoViewController () {
    @private
    BOOL backgroundNeedsUpdate;
    NSDateFormatter *dateFormatter;
    enum PhotoViewControllerStyle photoViewStyle;
    BOOL suppressionModeActif;
    
    /*
    // Position boutons Show suppression
    CGFloat trashButtonOriginShow;
    CGFloat likeButtonOriginShow;
    CGFloat facebookButtonOriginShow;
    CGFloat twitterButtonOriginShow;
    CGFloat downloadButtonOriginShow;
    
    // Position boutons Hide suppression
    CGFloat likeButtonOriginHide;
    CGFloat facebookButtonOriginHide;
    CGFloat twitterButtonOriginHide;
    CGFloat downloadButtonOriginHide;
     */
    
    // Action Sheets
    UIActionSheet *deleteActionSheet;
    UIActionSheet *shareActionSheet;
    
    // Animations
    BOOL shouldAnimate;
    
}

@end

@implementation BigPhotoViewController

@synthesize currentUser = _currentUser;
@synthesize moment = _moment;
@synthesize user = _user;
@synthesize rootViewController = _rootViewController;
@synthesize delegate = _delegate;
@synthesize photos = _photos;

@synthesize generalPopupView = _generalPopupView;
@synthesize blackFilterView = _blackFilterView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize backgroundImage = _backgroundImage;

@synthesize photoScrollView = _photoScrollView;
@synthesize selectedIndex = _selectedIndex;

@synthesize auteurLabel = _auteurLabel;
@synthesize dateLabel = _dateLabel;
@synthesize topPhotoView = _topPhotoView;
@synthesize bottomPhotoView = _bottomPhotoView;
@synthesize trashButton = _trashButton;
@synthesize likeButton = _likeButton;
@synthesize facebookButton = _facebookButton;
@synthesize twitterButton = _twitterButton;
@synthesize downloadButton = _downloadButton;
@synthesize closeButton = _closeButton;
@synthesize nextButton = _nextButton;
@synthesize previousButton = _previousButton;
@synthesize likeImageView = _likeImageView;
@synthesize likeNumberLabel = _likeNumberLabel;

#pragma mark - Init

- (id)initWithPhotos:(NSMutableArray *)photos
withRootViewController:(UIViewController *)rootViewController
withDelegate:(PhotoViewController*)photoViewController
{
    self = [super initWithNibName:@"BigPhotoViewController" bundle:nil];
    if(self) {
        self.currentUser = [UserCoreData getCurrentUser];
        self.rootViewController = rootViewController;
        self.delegate = photoViewController;
        self.photos = photos;
        self.selectedIndex = -1;
        suppressionModeActif = YES;
        shouldAnimate = YES;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        dateFormatter.calendar = [NSCalendar currentCalendar];
        dateFormatter.dateFormat = @"d/MM HH:mm";
        
    }
    return self;
}

- (id)initWithMoment:(MomentClass*)moment
          withPhotos:(NSMutableArray*)photos
withRootViewController:(UIViewController *)rootViewController
withDelegate:(PhotoViewController*)photoViewController
{
    self = [self initWithPhotos:photos
         withRootViewController:rootViewController
            withDelegate:photoViewController];
    if(self) {
        self.moment = moment;
        photoViewStyle = PhotoViewControllerStyleComplete;
    }
    return self;
}

- (id)initWithUser:(UserClass*)user
        withPhotos:(NSMutableArray*)photos
withRootViewController:(UIViewController*)rootViewController
withDelegate:(PhotoViewController*)photoViewController
{
    self = [self initWithPhotos:photos
         withRootViewController:rootViewController
            withDelegate:photoViewController];
    if(self) {
        self.user = user;
        photoViewStyle = PhotoViewControllerStyleProfil;
    }
    return self;
}

#pragma mark - View Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    if(shouldAnimate)
    {
        // Top
        CGRect frame = self.topPhotoView.frame;
        frame.origin.y += frame.size.height;
        self.topPhotoView.frame = frame;
        self.topPhotoView.alpha = 0;
        
        // Bottom
        frame = self.bottomPhotoView.frame;
        frame.origin.y -= frame.size.height;
        self.bottomPhotoView.frame = frame;
        self.bottomPhotoView.alpha = 0;
        
        // Next
        frame = self.nextButton.frame;
        frame.origin.x -= frame.size.width/2.0;
        self.nextButton.frame = frame;
        self.nextButton.alpha = 0;
        
        // Prvious
        frame = self.previousButton.frame;
        frame.origin.x += frame.size.width/2.0;
        self.previousButton.frame = frame;
        self.previousButton.alpha = 0;
        
        // Close
        self.closeButton.alpha = 0;
        self.generalPopupView.alpha = 1;
        self.centerPhotoView.alpha = 0;
        self.likeNumberLabel.alpha = 0;
        self.likeImageView.alpha = 0;
        
        // Black Filter
        self.blackFilterView.alpha = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    self.rootViewController.navigationController.navigationBar.hidden = YES;
    
    if(shouldAnimate)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.blackFilterView.alpha = 0.5;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.centerPhotoView.alpha = 1;
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    // Top
                    CGRect frame = self.topPhotoView.frame;
                    frame.origin.y -= frame.size.height;
                    self.topPhotoView.frame = frame;
                    self.topPhotoView.alpha = 1;
                    
                    // Bottom
                    frame = self.bottomPhotoView.frame;
                    frame.origin.y += frame.size.height;
                    self.bottomPhotoView.frame = frame;
                    self.bottomPhotoView.alpha = 1;
                    
                    // Next
                    frame = self.nextButton.frame;
                    frame.origin.x += frame.size.width/2.0;
                    self.nextButton.frame = frame;
                    self.nextButton.alpha = 1;
                    
                    // Previous
                    frame = self.previousButton.frame;
                    frame.origin.x -= frame.size.width/2.0;
                    self.previousButton.frame = frame;
                    self.previousButton.alpha = 1;
                    
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        // Close
                        self.closeButton.alpha = 1;
                        
                        // Like
                        self.likeImageView.alpha = 1;
                        self.likeNumberLabel.alpha = 1;
                        
                    }];
                }];
                
            }];
            
        }];
    }
    else {
        shouldAnimate = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Big Photo";
    
    // Background
    [self updateBackground];
    
    // iPhone 5 support
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = [VersionControl sharedInstance].screenHeight - STATUS_BAR_HEIGHT;
    self.view.frame = frame;
    self.backgroundImageView.frame = frame;
    self.blackFilterView.frame = frame;
    frame = self.generalPopupView.frame;
    frame.origin.y = (self.view.frame.size.height - frame.size.height)/2.0;
    self.generalPopupView.frame = frame;
    [self.view addSubview:self.generalPopupView];
    
    // Scroll View
    self.photoScrollView.contentSize = CGSizeMake([self.photos count]*self.photoScrollView.frame.size.width, self.photoScrollView.frame.size.height);
    
    // Like Number Label Shadow
    [self addShadowToView:self.likeNumberLabel];

    UIFont *font = [[Config sharedInstance] defaultFontWithSize:14];
    self.auteurLabel.font = font;
    self.dateLabel.font = font;
    
    /*
    // Save Position Show Buttons
    trashButtonOriginShow = self.trashButton.frame.origin.x;
    likeButtonOriginShow = self.likeButton.frame.origin.x;
    facebookButtonOriginShow = self.facebookButton.frame.origin.x;
    twitterButtonOriginShow = self.twitterButton.frame.origin.x;
    downloadButtonOriginShow = self.downloadButton.frame.origin.x;
    
    // Save Position Hide Buttons
    CGFloat delta = (320 - 3*self.likeButton.frame.size.width)/3.0;
    likeButtonOriginHide = trashButtonOriginShow;
    facebookButtonOriginHide = likeButtonOriginHide+delta;
    twitterButtonOriginHide = facebookButtonOriginHide+delta;
    downloadButtonOriginHide = twitterButtonOriginHide+delta;
     */
    
    // Clic FullScreen
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullScreen)];
    [self.photoScrollView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPhotoScrollView:nil];
    [self setAuteurLabel:nil];
    [self setDateLabel:nil];
    [self setTopPhotoView:nil];
    [self setTrashButton:nil];
    [self setLikeButton:nil];
    [self setFacebookButton:nil];
    [self setTwitterButton:nil];
    [self setDownloadButton:nil];
    [self setBottomPhotoView:nil];
    [self setCloseButton:nil];
    [self setNextButton:nil];
    [self setPreviousButton:nil];
    [self setBlackFilterView:nil];
    [self setBackgroundImage:nil];
    [self setMoment:nil];
    [self setCurrentUser:nil];
    [self setRootViewController:nil];
    [self setCenterPhotoView:nil];
    [self setGeneralPopupView:nil];
    [self setLikeImageView:nil];
    [self setLikeNumberLabel:nil];
    [self setUser:nil];
    [super viewDidUnload];
}

#pragma mark - ScrollView Delegate

- (void)updateBackground
{    
    // Capture d'écran
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow frame];
    
    UIGraphicsBeginImageContextWithOptions( rect.size ,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect contentRect;
    if ([[VersionControl sharedInstance] isRetina]) {
        // Retina
        contentRect = CGRectMake(0, 2*STATUS_BAR_HEIGHT, 2*rect.size.width, 2*(rect.size.height-STATUS_BAR_HEIGHT));
        //contentRect = CGRectMake(0, 2*TOPBAR_HEIGHT, 2*rect.size.width, 2*(rect.size.height - TOPBAR_HEIGHT));
    } else {
        // Not Retina
        contentRect = CGRectMake(0, STATUS_BAR_HEIGHT, rect.size.width, (rect.size.height - STATUS_BAR_HEIGHT));
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([capturedScreen CGImage], contentRect );
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    self.backgroundImage = croppedImage;
    self.backgroundImageView.image = croppedImage;
    backgroundNeedsUpdate = NO;
         
}

- (NSInteger)convertIndexFromParentView:(NSInteger)indexFromParentView
{
    if(photoViewStyle == PhotoViewControllerStyleComplete) {
        return indexFromParentView-1;
    }
    return indexFromParentView;
}

-(void)showViewAtIndex:(NSInteger)index fromParent:(BOOL)fromParent
{
    if(backgroundNeedsUpdate)
       [self updateBackground];
    
    if(fromParent)
        index = [self convertIndexFromParentView:index];
    
    if( (index < [self.photos count]) && (index >= 0) ) {
        
        Photos *photo = (Photos*)self.photos[index];
        if(!photo.imageOriginal) {
            [self addIndexToScrollView:index];
        }
        [self scrollToIndex:index animated:YES];
        
        self.nextButton.enabled = (self.selectedIndex < [self.photos count]-1);
        self.previousButton.enabled = (self.selectedIndex > 0);
        
        // Update bottom
        // Si on est owner ou taken_by de la photo -> droit de supprimer        
        BOOL secondCondition = (photoViewStyle == PhotoViewControllerStyleComplete)? ([self.moment.owner.userId isEqualToNumber:self.currentUser.userId]) : NO;
        
        if(  [self.currentUser.userId isEqualToNumber:photo.owner.userId] || secondCondition ) {
            [self showSuppressionMode];
        }
        // Impossible de supprimer
        else {
            [self hideSuppressionMode];
        }
        
    }
    
}

- (void)hideSuppressionMode
{
    if(suppressionModeActif)
    {
        suppressionModeActif = NO;
        
        /*
        
        __block CGRect frame = self.likeButton.frame;
        
        // Animation
        [UIView animateWithDuration:0.3 animations:^{
            
            // Cacher bouton
            self.trashButton.alpha = 0;
            
        } completion:^(BOOL finished) {
           
            self.trashButton.hidden = YES;
            
            [UIView animateWithDuration:0.1 animations:^{
                
                // Like
                frame.origin.x = likeButtonOriginHide;
                self.likeButton.frame = frame;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.1 animations:^{
                    
                    // FB
                    frame = self.facebookButton.frame;
                    frame.origin.x = facebookButtonOriginHide;
                    self.facebookButton.frame = frame;
                    
                } completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:0.1 animations:^{
                        
                        // Twitter
                        frame = self.twitterButton.frame;
                        frame.origin.x = twitterButtonOriginHide;
                        self.twitterButton.frame = frame;
                        
                    } completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.1 animations:^{
                            
                            // Download
                            frame = self.downloadButton.frame;
                            frame.origin.x = downloadButtonOriginHide;
                            self.downloadButton.frame = frame;
                            
                        }];
                        
                    }];
                    
                }];
                
            }];
            
        }];
        
        */
        
        // Changer Picto
        UIImage *image = [UIImage imageNamed:@"report_photo"];
        [self.trashButton setImage:image forState:UIControlStateNormal];
        [self.trashButton setImage:image forState:UIControlStateHighlighted];
    }
}

- (void)showSuppressionMode
{
    if(!suppressionModeActif)
    {
        suppressionModeActif = YES;
        
        /*
        __block CGRect frame = self.likeButton.frame;
        
        // Animation
        [UIView animateWithDuration:0.1 animations:^{
            
            // Download
            frame = self.downloadButton.frame;
            frame.origin.x = downloadButtonOriginShow;
            self.downloadButton.frame = frame;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                // Twitter
                frame = self.twitterButton.frame;
                frame.origin.x = twitterButtonOriginShow;
                self.twitterButton.frame = frame;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.1 animations:^{
                    
                    
                    // FB
                    frame = self.facebookButton.frame;
                    frame.origin.x = facebookButtonOriginShow;
                    self.facebookButton.frame = frame;
                    
                } completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:0.1 animations:^{
                        
                        // Like
                        frame = self.likeButton.frame;
                        frame.origin.x = likeButtonOriginShow;
                        self.likeButton.frame = frame;
                        
                    } completion:^(BOOL finished) {
                        
                        self.trashButton.hidden = NO;
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            // Trash
                            self.trashButton.alpha = 1;
                        }];
                        
                    }];
                    
                }];
                
            }];
            
        }];
        */
        
        // Changer Picto
        UIImage *image = [UIImage imageNamed:@"trash_photo"];
        [self.trashButton setImage:image forState:UIControlStateNormal];
        [self.trashButton setImage:image forState:UIControlStateHighlighted];
    }
}

- (void)addIndexToScrollView:(NSInteger)index
{
    Photos *photo = (Photos*)self.photos[index];
    
    CustomUIImageView *imageView = [[CustomUIImageView alloc] init];
    imageView.frame = CGRectMake( index*self.photoScrollView.frame.size.width,0, self.photoScrollView.frame.size.width, self.photoScrollView.frame.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.photoScrollView addSubview:imageView];
    
    [imageView setImage:photo.imageOriginal imageString:photo.urlOriginal withSaveBlock:^(UIImage *image) {
        photo.imageOriginal = image;
    }];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    [self.photoScrollView scrollRectToVisible:CGRectMake(index*self.photoScrollView.frame.size.width, 0, self.photoScrollView.frame.size.width, self.photoScrollView.frame.size.height) animated:animated];
    self.selectedIndex = index;
    
    Photos *photo = (Photos*)self.photos[index];
    self.auteurLabel.text = photo.owner.formatedUsername;
    
    // Date    
    self.dateLabel.text = [dateFormatter stringFromDate:photo.date];
    [self updateLikeNumber:photo.nbLike];
}

- (void)updateLikeNumber:(NSInteger)nbLike
{
    if(nbLike > 0) {
        self.likeNumberLabel.hidden = NO;
        self.likeImageView.hidden = NO;
        self.likeNumberLabel.text = [NSString stringWithFormat:@"%d", nbLike];
        [self.likeNumberLabel sizeToFit];
    }
    else {
        self.likeNumberLabel.hidden = YES;
        self.likeImageView.hidden = YES;
    }
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Photos"
     withAction:action
     withLabel:label
     withValue:value];
}

#pragma mark - Actions

- (IBAction)clicClose {    
    [UIView animateWithDuration:0.3 animations:^{
        self.generalPopupView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.blackFilterView.alpha = 0;
        } completion:^(BOOL finished) {
            self.rootViewController.navigationController.navigationBar.hidden = NO;
            backgroundNeedsUpdate = YES;
            [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self.rootViewController animated:NO];
            //[self.navigationController popViewControllerAnimated:NO];
        }];
    }];
}

- (IBAction)clicNext {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Suivant" value:nil];
    
    [self showViewAtIndex:self.selectedIndex+1 fromParent:NO];
    if(self.selectedIndex == [self.photos count]-1)
        self.nextButton.enabled = NO;
    if( (!self.previousButton.enabled) && (self.selectedIndex > 0) )
        self.previousButton.enabled = YES;
    else if(self.selectedIndex == 0)
        self.previousButton.enabled = NO;
}

- (IBAction)clicPrevious {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Précédent" value:nil];
    
    [self showViewAtIndex:self.selectedIndex-1 fromParent:NO];
    if(self.selectedIndex == 0)
        self.previousButton.enabled = NO;
    if( (!self.nextButton.enabled) && (self.selectedIndex < [self.photos count]-1) )
        self.nextButton.enabled = YES;
    else if(self.selectedIndex == [self.photos count]-1)
        self.nextButton.enabled = NO;
}

- (IBAction)clicTrash {
    
    // Delete Photo
    if(suppressionModeActif)
    {
        if(!deleteActionSheet)
        {
            deleteActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"BigPhotoViewController_DeleteActionSheet_Title", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                              destructiveButtonTitle:NSLocalizedString(@"BigPhotoViewController_DeleteActionSheet_Delete", nil)
                                                   otherButtonTitles:nil];
            deleteActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            
        }
        
        [deleteActionSheet showInView:self.view];
    }
    // Report Photo
    else
    {
        if([MFMailComposeViewController canSendMail])
        {
            // URL
            NSString *urlPhoto = ((Photos*)self.photos[self.selectedIndex]).uniqueURL;
            
            // Email Subject
            NSString *emailTitle = @"Moment - Reporter Photo";
            // Email Content
            NSMutableString *messageBody = [NSMutableString stringWithFormat:@"<p>Bonjour,</p><p>Je souhaiterais faire enlever cette photo car :</p><p></p><br><br><p>URL de la photo : <a href=\"%@\">%@</a> </p>", urlPhoto, urlPhoto];
            
            if(self.moment.uniqueURL) {
                [messageBody appendFormat:@"<p>URL De l'event : <a href=\"%@\">%@</a></p>", self.moment.uniqueURL, self.moment.titre];
            }
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:YES];
            [mc setToRecipients:@[kParameterContactMail]];
            
            // Present mail view controller on screen
            [[VersionControl sharedInstance] presentModalViewController:mc fromRoot:self animated:YES];
        }
        else
        {
            NSLog(@"mail composer fail");
            
            [[[UIAlertView alloc] initWithTitle:@"Envoi impossible"
                                        message:@"Votre appareil ne supporte pas l'envoi d'email"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
        }
        
    }
    
}

- (IBAction)clicLike {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading_updateLikeCount", nil);
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Like" value:nil];
    
    Photos *photo = self.photos[self.selectedIndex];
    
    [photo likeRequestWithEnded:^(NSInteger nbLikes) {
        [self updateLikeNumber:nbLikes];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)clicFacebook {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Partage Facebook" value:nil];
    
    // Paramètres
    Photos *photo = self.photos[self.selectedIndex];
    UIImage *image = photo.imageOriginal;
    NSString *initialText = [NSString stringWithFormat:@"Bon Moment @%@ !\n", self.moment.titre];
    NSURL *url = [NSURL URLWithString:photo.uniqueURL];
    
    // iOS 6 -> Social Framework
    if ( (NSClassFromString(@"SLComposeViewController") != nil) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbSheet setInitialText:initialText];
        [fbSheet addImage:image];
        [fbSheet addURL:url];
        
        //[self presentViewController:fbSheet animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:fbSheet fromRoot:self animated:YES];
    }
    // iOS 5
    else
    {
        /*
        DEFacebookComposeViewControllerCompletionHandler completionHandler = ^(DEFacebookComposeViewControllerResult result) {
            switch (result) {
                case DEFacebookComposeViewControllerResultCancelled:
                    NSLog(@"Facebook Result: Cancelled - iOS 5");
                    break;
                case DEFacebookComposeViewControllerResultDone:
                    NSLog(@"Facebook Result: Sent - iOS 5");
                    break;
            }
            
            [self dismissModalViewControllerAnimated:YES];
        };
         */
        
        DEFacebookComposeViewController *facebookViewComposer = [[DEFacebookComposeViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [facebookViewComposer setInitialText:initialText];
        [facebookViewComposer addImage:image];
        [facebookViewComposer addURL:url];
        //facebookViewComposer.completionHandler = completionHandler;
        //[self presentViewController:facebookViewComposer animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:facebookViewComposer fromRoot:self animated:YES];
    }
    
}

- (IBAction)clicTwitter {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Partage Twitter" value:nil];
    
    // Paramètres
    Photos *photo = self.photos[self.selectedIndex];
    UIImage *image = photo.imageOriginal;
    
    // Limitation à 140 caractères max
    NSInteger defaultNBMaxCarac = 140;
    NSInteger nbMaxCarac = photo.uniqueURL ? (defaultNBMaxCarac - photo.uniqueURL.length) : defaultNBMaxCarac;
    NSMutableString *initialText = [[[Config sharedInstance] twitterShareTextForMoment:self.moment nbMaxCaracters:nbMaxCarac]
                                    mutableCopy];
    
#ifdef HASHTAG_ENABLE
    // Hashtag
    if(self.moment.hashtag && (self.moment.hashtag.length <= (nbMaxCarac - initialText.length)))
        [initialText appendFormat:@" #%@", self.moment.hashtag];
#endif
    
    // URL
    NSURL *url = [NSURL URLWithString:photo.uniqueURL];
    
    // iOS 6 -> Social Framework
    if( (NSClassFromString(@"SLComposeViewController") != nil) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:initialText];
        [tweetSheet addImage:image];
        [tweetSheet addURL:url];
        
        //[self presentViewController:tweetSheet animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:tweetSheet fromRoot:self animated:YES];
    }
    // iOS 5 -> Twitter Framework
    else
    {
        TWTweetComposeViewController *twitterViewComposer = [[TWTweetComposeViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [twitterViewComposer setInitialText:initialText];
        [twitterViewComposer addImage:image];
        [twitterViewComposer addURL:url];
        
        //[self presentViewController:twitterViewComposer animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:twitterViewComposer fromRoot:self animated:YES];
    }
    
}

- (IBAction)clicDownload {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Téléchargement" value:nil];
    
    Photos *p = self.photos[self.selectedIndex];
    UIImageWriteToSavedPhotosAlbum(p.imageOriginal, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// Completion Hander For Saving image
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo
{
    [[MTStatusBarOverlay sharedInstance]
     postImmediateFinishMessage:NSLocalizedString(@"PhotoViewController_DownloadPhoto_success", nil)
     duration:1
     animated:YES];
}

#pragma mark - Util

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.masksToBounds  = NO;
}

#pragma mark - UIActionSheet Delegate

// Index réelle (dans le tableau des photos NSArray <Photos*>
- (NSInteger)convertIndexForDataForCurrentStyle:(NSInteger)index
{
    if(self.delegate.style == PhotoViewControllerStyleComplete)
        index = index + 1;
    
#ifdef ACTIVE_PRINT_MODE
    if(index>=PHOTOVIEW_PRINT_BUTTON_INDEX)
        index = index+1;
#endif
    
    return index;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet == deleteActionSheet)
    {
        if(buttonIndex == 0)
        {
            Photos *photo = (Photos*)self.photos[self.selectedIndex];
            
            // Delete From Server
            [photo deletePhotoWithEnded:^(BOOL success) {
                
                // -- Success
                if(success)
                {
                    // Remove
                    [self.photos removeObject:photo];
                    
                    // Update Delegate
                    // ------------ > Il faut convertir l'index
                    
                    int index = [self convertIndexForDataForCurrentStyle:self.selectedIndex];
                    [self.delegate.imageShowCase deleteImage:self.delegate.imageShowCase.itemsInShowCase[index] imageIndex:index];
                    
                    NSInteger count = [self.photos count];
                    NSInteger deleteIndex;

                    deleteIndex = (photoViewStyle == PhotoViewControllerStyleComplete) ? count+1 : count;
#ifdef ACTIVE_PRINT_MODE
                    deleteIndex = (deleteIndex>=PHOTOVIEW_PRINT_BUTTON_INDEX)?deleteIndex+1 : deleteIndex;
#endif
                    [self.delegate.imageShowCase updateItemsShowCaseWithSize:deleteIndex];
                    //[self updateBackground];
                    
                    // Scroll or close
                    if(count > 0) {
                        
                        // Scroll Left
                        if(self.selectedIndex >= count) {
                            [self clicPrevious];
                        }
                        // Scroll Right
                        else {
                            [self scrollToIndex:(self.selectedIndex+1) animated:YES];
                            self.selectedIndex--;
                            if(self.selectedIndex == [self.photos count]-1)
                                self.nextButton.enabled = NO;
                            if( (!self.previousButton.enabled) && (self.selectedIndex > 0) )
                                self.previousButton.enabled = YES;
                            else if(self.selectedIndex == 0)
                                self.previousButton.enabled = NO;

                        }
                    
                    }
                    // Close
                    else {
                        [self clicClose];
                    }
                    
                    self.delegate.photos = self.photos;
                }
                // -- Fail
                else {
                    [[[UIAlertView alloc]
                      initWithTitle:NSLocalizedString(@"BigPhotoViewController_DeleteFailAlertView_Title", nil)
                      message:NSLocalizedString(@"BigPhotoViewController_DeleteFailAlertView_Message", nil)
                      delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                      otherButtonTitles:nil]
                     show];
                }
                
            }];

        }
    }
}

#pragma mark - Full Screen

- (FullScreenPhotoViewController*)fullScreenViewController {
    if(!_fullScreenViewController) {
        
        NSString *titre = nil;
        if(self.moment && self.moment.titre) {
            titre = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"FullScreenPhotoViewController_Titre_PhotosOf" , nil), self.moment.titre];
        }
        else if(self.user) {
            if(self.user.prenom && self.user.nom) {
                titre = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"FullScreenPhotoViewController_Titre_PhotosOf" , nil) ,self.user.prenom, self.user.nom];
            }
            else if(self.user.prenom || self.user.nom) {
                if(self.user.prenom)
                    titre = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"FullScreenPhotoViewController_Titre_PhotosOf" , nil), self.user.prenom];
                else
                    titre = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"FullScreenPhotoViewController_Titre_PhotosOf" , nil), self.user.nom];
            }
        }
        else {
            titre = NSLocalizedString(@"FullScreenPhotoViewController_TitreDefaut", nil);
        }
        
        _fullScreenViewController = [[FullScreenPhotoViewController alloc] initWithTitle:titre withPhotos:self.photos delegate:self];
    }
    return _fullScreenViewController;
}

- (void)showFullScreen {
    
    //RotationNavigationControllerViewController *nav = [[RotationNavigationControllerViewController alloc] initWithRootViewController:self.fullScreenViewController];
    //[[[UIApplication sharedApplication] keyWindow] addSubview:nav.view];
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Plein écran" value:nil];
    
    shouldAnimate = NO;
    ((RotationNavigationControllerViewController*)self.navigationController).activeRotation = YES;
    [self.fullScreenViewController showPhoto:self.photos[self.selectedIndex]];
    [self.navigationController pushViewController:self.fullScreenViewController animated:NO];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            
            [[[UIAlertView alloc] initWithTitle:@"Erreur d'envoi"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
            
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self animated:YES];
}


@end
