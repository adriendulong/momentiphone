//
//  PhotoSet.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Three20/Three20.h"
#import "MomentClass.h"

@interface PhotoSet : TTURLRequest <TTPhotoSource>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSArray *photos;

- (id)initWithTitle:(NSString*)title withPhotos:(NSArray*)photos;

@end
