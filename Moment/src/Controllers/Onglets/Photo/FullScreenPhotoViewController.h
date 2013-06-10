//
//  FullScreenPhotoViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Three20/Three20.h"
#import "PhotoSet.h"

@class BigPhotoViewController;

@interface FullScreenPhotoViewController : TTPhotoViewController

@property (nonatomic, weak) BigPhotoViewController *delegate;

- (id)initWithTitle:(NSString*)title withPhotos:(NSArray*)photos delegate:(BigPhotoViewController*)delegate;
- (void)showPhoto:(id<TTPhoto>)photo;

@end

#import "BigPhotoViewController.h"
