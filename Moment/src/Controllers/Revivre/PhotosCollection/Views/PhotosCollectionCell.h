//
//  PhotosCollectionCell.h
//  Moment
//
//  Created by SkeletonGamer on 25/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REPhotoObjectProtocol.h"
#import "Photo.h"

@interface PhotosCollectionCell : UICollectionViewCell {
    NSMutableArray *_photos;
}

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *circleCheck;

@property (nonatomic, strong) Photo *photo;

//- (void)addPhoto:(NSObject <REPhotoObjectProtocol> *)photo;
//- (void)refresh;

@end
