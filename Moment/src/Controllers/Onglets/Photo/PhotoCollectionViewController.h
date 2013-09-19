//
//  PhotoCollectionViewController.h
//  PhotoCollection
//
//  Created by SkeletonGamer on 18/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MomentCoreData+Model.h"
#import "RootOngletsViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"

#import "MTStatusBarOverlay.h"
#import "BigPhotoViewController.h"

enum PhotoViewControllerStyle {
    PhotoViewControllerStyleComplete = 0,
    PhotoViewControllerStyleProfil = 1
};

@interface PhotoCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, OngletViewController, ELCImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MTStatusBarOverlayDelegate>


@property (nonatomic, strong) UserClass *user;
@property (nonatomic, strong) MomentClass *moment;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, weak) RootOngletsViewController *rootViewController;
@property (nonatomic) enum PhotoViewControllerStyle style;

@property (weak, nonatomic) UIImagePickerController *picker;
@property (weak, nonatomic) ELCImagePickerController *imagePicker;

@property (nonatomic, strong) BigPhotoViewController *bigPhotoViewController;

@property (strong, nonatomic) id mediaInfo;
@property (nonatomic) int pageNumber;


- (id)initWithRootViewController:(UIViewController*)rootViewController withSize:(CGSize)size;
- (id)initWithMoment:(MomentClass *)moment
withRootViewController:(UIViewController *)rootViewController
            withSize:(CGSize)size;
- (id)initWithUser:(UserClass *)user
withRootViewController:(UIViewController *)rootViewController
          withSize:(CGSize)size;

- (void)sendGoogleAnalyticsView;
- (void)showPhotoActionSheet;
- (void)loadPhotosFromPage:(int)pageNumber;

@end
