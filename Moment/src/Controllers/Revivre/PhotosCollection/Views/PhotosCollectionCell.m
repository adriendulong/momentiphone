//
//  PhotosCollectionCell.m
//  Moment
//
//  Created by SkeletonGamer on 25/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PhotosCollectionCell.h"

@implementation PhotosCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"PhotosCollectionCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}

/*-(void)updateCell {
 
 NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photo.urlOriginal]];
 UIImage *image = [[UIImage alloc] initWithData:data];
 
 [self.photoView setImage:image];
 [self.photoView setContentMode:UIViewContentModeScaleAspectFill];
 [self.photoView setClipsToBounds:YES];
 
}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIImage imageNamed:@"bords_photo_small.png"] drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}*/

- (void)removeAllPhotos
{
    [_photos removeAllObjects];
}

- (void)addPhoto:(NSObject<REPhotoObjectProtocol> *)photo
{
    [_photos addObject:photo];
}

@end
