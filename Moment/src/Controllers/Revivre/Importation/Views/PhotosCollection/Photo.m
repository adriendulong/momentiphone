//
//  Photo.m
//  REPhotoCollectionControllerExample
//
//  Created by Roman Efimov on 7/27/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize /*thumbnailURL = _thumbnailURL,*/ date = _date,
            thumbnail = _thumbnail,
            photoCachePath = _photoCachePath,
            assetUrl = _assetUrl,
            isSelected = _isSelected,
            momentId = _momentId;

- (NSString *)description {
    return [NSString stringWithFormat:@"PHOTO :\n{\nMOMENT : %@\nDATE : %@\nASSETURL : %@\n}\n-----------\n", self.momentId, self.date, self.assetUrl.absoluteString];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Photo *photoCopy = [[Photo allocWithZone:zone] init];
    
    [photoCopy setDate:self.date];
    [photoCopy setThumbnail:self.thumbnail];
    [photoCopy setPhotoCachePath:self.photoCachePath];
    [photoCopy setAssetUrl:self.assetUrl];
    [photoCopy setIsSelected:self.isSelected];
    [photoCopy setMomentId:self.momentId];
    
    return photoCopy;
}

@end
