//
//  PhotoCollectionCell.h
//  LazyTableImages
//
//  Created by SkeletonGamer on 18/09/13.
//
//

#import <UIKit/UIKit.h>
#import "Photos.h"

@interface PhotoCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (nonatomic, strong) Photos *photo;

//-(void)updateCell;

@end
