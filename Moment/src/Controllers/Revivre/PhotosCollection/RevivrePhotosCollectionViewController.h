//
//  RevivrePhotosCollectionViewController.h
//  Moment
//
//  Created by SkeletonGamer on 25/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REPhotoObjectProtocol.h"
#import "REPhotoGroup.h"

@interface RevivrePhotosCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate> {
    
    NSMutableArray *_ds;
}

@property (nonatomic, strong, setter = setDatasource:) NSMutableArray *datasource;
@property (nonatomic, strong) NSArray *moments;
@property (nonatomic, strong) NSMutableArray *photosToUpload;

@property (nonatomic, weak) UIViewController <TimeLineDelegate> *timeLine;

- (id)initWithDatasource:(NSArray *)datasource moments:(NSArray *)moments timeLine:(UIViewController <TimeLineDelegate> *)timeLine;
- (void)reloadData;

@end
