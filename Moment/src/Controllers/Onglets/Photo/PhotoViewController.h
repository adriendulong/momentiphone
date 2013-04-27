//
//  PhotoViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

enum PhotoViewControllerStyle {
    PhotoViewControllerStyleComplete = 0,
    PhotoViewControllerStyleProfil = 1
    };

// Si la constante ACTIVE_PRINT_MODE est défini, le mode print est activé
//#define ACTIVE_PRINT_MODE
#define PHOTOVIEW_PRINT_BUTTON_INDEX 5

#import "NLImageShowCase.h"
#import "NLImageViewDataSource.h"
#import "MomentCoreData+Model.h"
#import "RootOngletsViewController.h"
#import "QBImagePickerController.h"

#import "MTStatusBarOverlay.h"
#import "BigPhotoViewController.h"



@interface PhotoViewController : UIViewController <NLImageViewDataSource, OngletViewController, QBImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MTStatusBarOverlayDelegate>


@property (nonatomic, strong) UserClass *user;
@property (nonatomic, strong) MomentClass *moment;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, weak) RootOngletsViewController *rootViewController;
@property (nonatomic) enum PhotoViewControllerStyle style;

// ImageShowCase
@property (nonatomic, strong) BigPhotoViewController *bigPhotoViewController;
@property (nonatomic, strong) NLImageShowCase *imageShowCase;

// Print Mode
#ifdef ACTIVE_PRINT_MODE
@property (nonatomic, strong) NSMutableArray *printSelectedCells;
#endif

// Bandeau
@property (strong, nonatomic) IBOutlet UIView *bandeauView;
@property (weak, nonatomic) IBOutlet UIImageView *panierImgeView;
@property (weak, nonatomic) IBOutlet UILabel *nbPhotosToPrintLabel;
@property (weak, nonatomic) IBOutlet UILabel *photosSelectionnesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowWhiteView;


// Init From Onglet
- (id)initWithMoment:(MomentClass *)moment
withRootViewController:(UIViewController *)rootViewController
            withSize:(CGSize)size;

// Init From Profil
- (id)initWithUser:(UserClass *)user
withRootViewController:(UIViewController *)rootViewController
            withSize:(CGSize)size;

#ifdef ACTIVE_PRINT_MODE
- (void)desactiverPrintMode;
#endif

@end
