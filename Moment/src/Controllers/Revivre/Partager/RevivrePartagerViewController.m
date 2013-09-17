//
//  RevivrePartagerViewController.m
//  Moment
//
//  Created by SkeletonGamer on 03/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RevivrePartagerViewController.h"
#import "Config.h"
#import "MomentClass+Server.h"
#import "MomentCoreData+Model.h"
#import "Photo.h"

@interface RevivrePartagerViewController (){
@private
    MTStatusBarOverlay *overlayStatusBar;
    BOOL dismissUploadPreparingHUD;
}
@end

@implementation RevivrePartagerViewController

//@synthesize events = _events;
@synthesize moments = _moments;
@synthesize timeLine = _timeLine;

@synthesize titleLabel = _titleLabel;
@synthesize contentView = _contentView;

@synthesize sendToFaceBookFriendsButton = _sendToFaceBookFriendsButton;
@synthesize tweetToFollowersButton = _tweetToFollowersButton;
@synthesize sendSMSButton = _sendSMSButton;
@synthesize backToTheTimeLineButton = _backToTheTimeLineButton;

@synthesize photos = _photos;
@synthesize photosInCahe = _photosInCahe;

#pragma mark - View Init

- (id)initWithTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
                moments:(NSArray *)moments
                photos:(NSArray *)photos
{
    self = [super initWithNibName:@"RevivrePartagerViewController" bundle:nil];
    if(self) {
        self.timeLine = timeLine;
        self.moments = [NSArray arrayWithArray:moments];
        self.photos = [NSArray arrayWithArray:photos];
        self.photosInCahe = [NSMutableArray arrayWithCapacity:photos.count];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate updateActualViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Finish Revivre Moments";
    
    
    // Status Bar init
    overlayStatusBar = [MTStatusBarOverlay sharedInstance];
    overlayStatusBar.progress = 0.0;
    
    dismissUploadPreparingHUD = NO;
    
    
    self.contentView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    // Navigation Bar
    [CustomNavigationController customToolBarWithLogo:[UIImage imageNamed:@"logo.png"] withViewController:self];
    
    
    
    [self.sendToFaceBookFriendsButton setBackgroundImage:[UIImage imageNamed:@"btn_facebook.png"]
                                          forState:UIControlStateNormal];
    
    [self.sendToFaceBookFriendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendToFaceBookFriendsButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    
    [self.tweetToFollowersButton setBackgroundImage:[UIImage imageNamed:@"btn_twitter.png"]
                                                forState:UIControlStateNormal];
    
    [self.tweetToFollowersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.tweetToFollowersButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    
    [self.sendSMSButton setBackgroundImage:[UIImage imageNamed:@"btn_sms.png"]
                                                forState:UIControlStateNormal];
    
    [self.sendSMSButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendSMSButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    
    [self.backToTheTimeLineButton setBackgroundImage:[UIImage imageNamed:@"btn_revivre.png"]
                                                forState:UIControlStateNormal];
    
    [self.backToTheTimeLineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backToTheTimeLineButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.backToTheTimeLineButton addTarget:self action:@selector(returnToTimeLine) forControlEvents:UIControlEventTouchUpInside];
    
    
    if ([[VersionControl sharedInstance] isIphone5]) {
        
        // Bouton Facebook
        CGRect frame = self.sendToFaceBookFriendsButton.frame;
        frame.origin.y += 46;
        [self.sendToFaceBookFriendsButton setFrame:frame];
        
        // Bouton Twitter
        frame = self.tweetToFollowersButton.frame;
        frame.origin.y += 46;
        [self.tweetToFollowersButton setFrame:frame];
        
        // Bouton SMS
        frame = self.sendSMSButton.frame;
        frame.origin.y += 46;
        [self.sendSMSButton setFrame:frame];
        
        // Bouton TimeLine
        frame = self.backToTheTimeLineButton.frame;
        frame.origin.y += 46;
        [self.backToTheTimeLineButton setFrame:frame];
    }
    
    
    
    
    if([[VersionControl sharedInstance] supportIOS6]) {
        
        //SUBTITLE
        [self.titleLabel setFont:[[Config sharedInstance] defaultFontWithSize:14]];
        
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
        [titleText addAttribute:NSFontAttributeName value:[[Config sharedInstance] defaultFontWithSize:18] range:NSMakeRange(0, 1)];
        [titleText addAttribute:NSFontAttributeName value:[[Config sharedInstance] defaultFontWithSize:18] range:NSMakeRange(91, 1)];
        [self.titleLabel setAttributedText:titleText];
        
    } else {
        
        //SUBTITLE
        TTTAttributedLabel *titleText = [[TTTAttributedLabel alloc] initWithFrame:self.titleLabel.frame];
        [titleText setFont:[[Config sharedInstance] defaultFontWithSize:14]];
        //[subTitleText setTextColor:[UIColor orangeColor]];
        
        [titleText setText:self.titleLabel.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // 1 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:18 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:18 onRange:NSMakeRange(91, 1)];
            
            return mutableAttributedString;
        }];
    }
    
    if (self.photos && self.photos > 0) {
        
        /*dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            //
            
            [self stackImages:self.photos];
        });*/
        
        [self stackImages:self.photos];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSendToFaceBookFriendsButton:nil];
    [self setTweetToFollowersButton:nil];
    [self setSendSMSButton:nil];
    [self setBackToTheTimeLineButton:nil];
    [self setTitleLabel:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (void)returnToTimeLine {
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Clic on Return TimeLine"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    UIViewController *actualView = [AppDelegate actualViewController];
    
    if ([actualView isKindOfClass:[RootTimeLineViewController class]]) {
        RootTimeLineViewController *rootTimeline = (RootTimeLineViewController *)actualView;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:rootTimeline.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Reoading_Moments", nil);
        
        [rootTimeline.privateTimeLine reloadDataWithWaitUntilFinished:YES withEnded:^(BOOL success) {
            [MBProgressHUD hideHUDForView:rootTimeline.view animated:YES];
        }];
    }
}

#pragma mark - Upload Photos

- (void)getUIImageFromAssetURL:(NSURL *)assetUrl toPath:(NSString *)path withEnded:(void (^) (NSString *fullPathToPhoto) )block
{
    if (block) {
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary assetForURL:assetUrl resultBlock: ^(ALAsset *asset) {
            
            if (asset) {
                
                @autoreleasepool {
                    ALAssetRepresentation *representation = [asset defaultRepresentation];
                    
                    /*CGFloat scale = [[Config sharedInstance] getScaleFromImageMetadata:representation.metadata
                                                                               maxSize:PHOTO_MAX_SIZE];*/
                    
                    /*UIImage *img = [UIImage imageWithCGImage:representation.fullResolutionImage
                                                       scale:scale
                                                 orientation:representation.orientation];*/
                    UIImage *img = [UIImage imageWithCGImage:representation.fullResolutionImage
                                                       scale:representation.scale
                                                 orientation:representation.orientation];
                    
                    //NSLog(@"img size AFTER= %@", NSStringFromCGSize(img.size));
                    UIImage *croppedImg = [[Config sharedInstance] imageWithMaxSize:img maxSize:PHOTO_MAX_SIZE];
                    img = nil;
                    // DEBUG
                    //NSLog(@"croppedImg size= %@", NSStringFromCGSize(croppedImg.size));
                    
                    NSData *photoData = UIImageJPEGRepresentation(croppedImg, 0.8);
                    croppedImg = nil;
                    // DEBUG
                    //NSLog(@"Taille: %f Mo",(CGFloat)photoData.length/1000000);
                    //NSLog(@"progression: %i%%", (int)roundf(progression*100.0));
                    
                    NSString *imageName = [NSString stringWithFormat:@"Photo_%f.png",[[NSDate date] timeIntervalSince1970]];
                    
                    NSString *fullPathToPhoto = [path stringByAppendingPathComponent:imageName];
                    //NSLog(@"Library | fullPathToFile = %@",fullPathToPhoto);
                    
                    [photoData writeToFile:fullPathToPhoto atomically:NO];
                    photoData = nil;
                    
                    if (![self.photosInCahe containsObject:fullPathToPhoto]) {
                        [self.photosInCahe addObject:fullPathToPhoto];
                    }
                    
                    
                    block(fullPathToPhoto);
                }
            }
            
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@", error.localizedDescription);
            
            block(nil);
        }];
    }
}

- (void)stackImages:(NSArray *)photos
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_PhotosPreparing", nil);
    
    dismissUploadPreparingHUD = NO;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *photosPath = [documentsDirectory stringByAppendingPathComponent:@"PhotosRevivreCache"];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:photosPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:photosPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder

    
    [photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            Photo *photoToDeal = (Photo *)obj;
            
            //NSLog(@"attributes = %@", attributes);
            
            NSString *momentPath = [photosPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i",photoToDeal.momentId.intValue]];
            
            NSError *error = nil;
            if (![[NSFileManager defaultManager] fileExistsAtPath:momentPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:momentPath withIntermediateDirectories:NO attributes:nil error:&error];
            
            /*dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                
            });*/
            
            [self getUIImageFromAssetURL:photoToDeal.assetUrl
                                  toPath:momentPath
                               withEnded:^(NSString *fullPathToPhoto) {
                
                if (fullPathToPhoto) {
                    
                    if (self.photosInCahe.count == self.photos.count) {
                        
                        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            // Add code here to do background processing
                            //
                            //NSLog(@"images count first = %i",images.count);
                            
                            [self prepareForSendingToServer:self.photosInCahe];
                            
                            self.photosInCahe = nil;
                        });
                    }
                }
            }];
        }
        
    }];
}

- (void)prepareForSendingToServer:(NSMutableArray *)images
{
    
    // ----- Envoi au Server -----
    
    // Disable the idle timer
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //int totalImages = images.count;
    // DEBUG
    //NSLog(@"totalImages = %i",totalImages);
    
    NSMutableArray *uniqueMoments = [NSMutableArray array];
    NSMutableArray *allData = [NSMutableArray array];
    
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *pathUrl = (NSURL *)[NSURL URLWithString:obj];
        
        if (pathUrl && pathUrl.absoluteString.length > 0) {
            
            //NSLog(@"pathUrl.pathComponents = %@", pathUrl.pathComponents);
            NSString *idString = pathUrl.pathComponents[pathUrl.pathComponents.count-2];
            
            if ([[Config sharedInstance] isNumeric:idString]) {
                NSNumber *momentId = [NSNumber numberWithInteger:[idString integerValue]];
                
                if (![uniqueMoments containsObject:momentId]) {
                    //NSLog(@"momentId = %@", momentId);
                    [uniqueMoments addObject:momentId];
                    
                    NSMutableArray *momentArray = [NSMutableArray array];
                    [momentArray addObject:momentId];
                    
                    [allData addObject:momentArray];
                    momentArray = nil;
                }
            }
        }
    }];
    
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSURL *pathUrl = (NSURL *)[NSURL URLWithString:obj];
        
        if (pathUrl && pathUrl.absoluteString.length > 0) {
            NSString *idString = pathUrl.pathComponents[pathUrl.pathComponents.count-2];
            
            if ([[Config sharedInstance] isNumeric:idString]) {
                NSNumber *momentId = [NSNumber numberWithInteger:[idString integerValue]];
                
                [self addPhotoPath:pathUrl.absoluteString inMomentArrayWithMomentId:momentId withAllMomentsArray:allData];
            }
        }
    }];
    
    
    // Découplage des tableaux pour les envoyer
    [allData enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
        NSMutableArray *momentArray = (NSMutableArray *)obj1;
        NSNumber *firstLine = (NSNumber *)momentArray[0];
        
        [[MomentCoreData getMoments] enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
            MomentClass *moment = (MomentClass *)obj2;
            
            if ([moment.momentId isEqualToNumber:firstLine]) {
                
                NSMutableSet *set = [NSMutableSet setWithArray:momentArray];
                if ([set containsObject:firstLine]) {
                    [set removeObject:firstLine];
                } else {
                    NSLog(@"NSMutableSet ne contient pas %@ ! WTF putain ?!?!",firstLine);
                }
                
                NSArray *allPhotos = set.allObjects;
                
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self sendArrayOfPhotos:allPhotos withMoment:moment];
                });
            }
        }];
    }];
}

- (void)addPhotoPath:(NSString *)path inMomentArrayWithMomentId:(NSNumber *)momentId withAllMomentsArray:(NSMutableArray *)momentsArray
{
    //NSLog(@"momentsArray = %@",momentsArray);
    
    [momentsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *momentArray = (NSMutableArray *)obj;
        
        //NSLog(@"momentArray = %@",momentArray);
        
        NSNumber *firstLine = (NSNumber *)momentArray[0];
        //NSLog(@"firstLine = %@",firstLine);
        
        if ([firstLine isEqualToNumber:momentId]) {
            
            if (![momentArray containsObject:path]) {
                [momentArray addObject:path];
                //NSLog(@"path: %@ | moment %@", path, momentId);
            }
        }
        
        /*if (stop) {
            NSLog(@"momentsArray = %@",momentsArray);
        }*/
    }];
}

- (void)sendArrayOfPhotos:(NSArray *)images withMoment:(MomentClass *)moment
{
    __block NSInteger actualIndex = 0;
    __block int totalImages = images.count;    
    
    overlayStatusBar.progress = 0;
    dismissUploadPreparingHUD = YES;
    
    // DEBUG
    //NSLog(@"momentId = %@ | images = %@",moment.momentId, images);
    
    runOnMainQueueWithoutDeadlockingRevivre(^{
        if (dismissUploadPreparingHUD) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    });
    
    
    [moment sendArrayOfPhotos:images withStart:^(NSString *photoPath) {
        
        // Message d'upload d'une unique photo
        if(totalImages == 1) {
            //NSLog(@"Message d'upload d'une unique photo");
            
            [overlayStatusBar postMessage:NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil)];
            
        }
        // Premier Status d'un envoi multiple
        else if([images indexOfObject:photoPath] == 0) {
            //NSLog(@"Premier Status d'un envoi multiple");
            
            [overlayStatusBar postMessage:[NSString stringWithFormat:@"%@ 1/%d", NSLocalizedString(@"StatusBarOverlay_Photo_Uploading", nil),totalImages]
             ];
        }
        
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
        }
        
    } withEnded:^ {
        // Status Bar Finished
        [overlayStatusBar postFinishMessage:NSLocalizedString(@"StatusBarOverlay_Photo_UploadEnded", nil) duration:2];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        
        // Activate the idle timer
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }];
}

#pragma Dispatch methods

void runOnMainQueueWithoutDeadlockingRevivre(void (^block)(void))
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
