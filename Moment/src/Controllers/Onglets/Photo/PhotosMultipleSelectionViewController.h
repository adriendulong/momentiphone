//
//  PhotosMultipleSelectionViewController.h
//  Moment
//
//  Created by SkeletonGamer on 27/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CustomToolbar.h"
#import "Photo.h"

@class PhotosMultipleSelectionViewController;

@protocol PhotosMultipleSelectionViewControllerDelegate <NSObject>
- (void)didDismissAlbumViewController;
- (void)addPhotoToUpload:(Photo *)photo;
- (void)removePhotoToUpload:(Photo *)photo;
- (void)stackImages;
@end

@interface PhotosMultipleSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet CustomToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, strong) NSMutableArray *datasourceAutomatic;
@property (nonatomic, strong) NSMutableArray *datasourceComplete;
@property (nonatomic, strong) NSMutableArray *photosToUpload;

@property (nonatomic, weak) id<PhotosMultipleSelectionViewControllerDelegate> delegate;

- (id)initWithMoment:(MomentClass *)moment;

@end
