//
//  PhotoCollectionViewController.h
//  PhotoCollection
//
//  Created by SkeletonGamer on 18/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosMultipleSelectionViewController.h"
#import "MomentCoreData+Model.h"
#import "RootOngletsViewController.h"

#import "MTStatusBarOverlay.h"
#import "BigPhotoViewController.h"

enum PhotoViewControllerStyle {
    PhotoViewControllerStyleComplete = 0,
    PhotoViewControllerStyleProfil = 1
};

@interface PhotoCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, OngletViewController, UIActionSheetDelegate, UINavigationControllerDelegate, PhotosMultipleSelectionViewControllerDelegate, UIImagePickerControllerDelegate, MTStatusBarOverlayDelegate>


@property (nonatomic, strong) UserClass *user;
@property (nonatomic, strong) MomentClass *moment;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *photosInCache;
@property (nonatomic, strong) NSMutableArray *photosToUpload;
@property (nonatomic, weak) RootOngletsViewController *rootViewController;
@property (nonatomic) enum PhotoViewControllerStyle style;

@property (weak, nonatomic) UIImagePickerController *picker;
//@property (weak, nonatomic) ELCImagePickerController *imagePicker;

@property (nonatomic, strong) BigPhotoViewController *bigPhotoViewController;

@property (nonatomic, strong) NSMutableArray *mediaInfo;
@property (nonatomic, strong) NSArray *mediaInfoCache;
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

- (void)stackImages;

@end
