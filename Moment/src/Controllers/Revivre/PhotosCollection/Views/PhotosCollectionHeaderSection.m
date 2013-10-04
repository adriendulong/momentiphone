//
//  PhotosCollectionHeaderSection.m
//  Moment
//
//  Created by SkeletonGamer on 25/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PhotosCollectionHeaderSection.h"

@implementation PhotosCollectionHeaderSection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"PhotosCollectionHeaderSection" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionReusableView class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIImage imageNamed:@"bords_photo_small.png"] drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    //[[UIImage imageNamed:@"bords_photo_small.png"] drawInRect:rect];
    //self.momentTitle.frame = CGRectMake(5, 4, rect.size.width, 23);
}

@end
