//
//  PhotoSet.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PhotoSet.h"
#import "Photos.h"

@implementation PhotoSet

@synthesize title = _title;
@synthesize photos = _photos;

- (id)initWithTitle:(NSString *)title withPhotos:(NSArray*)photos
{
    self = [super init];
    if(self) {
        self.title = title;
        self.photos = photos;
        
        int i = 0;
        for(Photos *p in self.photos) {
            p.photoSource = self;
            p.index = i;
            i++;
        }
    }
    return self;
}

#pragma mark - TTModel

- (BOOL)isLoading {
    return NO;
}

- (BOOL)isLoaded {
    return YES;
}

- (BOOL)isOutdated {
    return NO;
}

#pragma mark - TTPhotoSource

- (NSInteger)numberOfPhotos {
    return _photos.count;
}

- (NSInteger)maxPhotoIndex {
    return _photos.count-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < _photos.count) {
        return [_photos objectAtIndex:photoIndex];
    } else {
        return nil;
    }
}

@end
