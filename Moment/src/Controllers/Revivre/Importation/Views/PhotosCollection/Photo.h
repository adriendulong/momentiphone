//
//  Photo.h
//  REPhotoCollectionControllerExample
//
//  Created by Roman Efimov on 7/27/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REPhotoObjectProtocol.h"

@interface Photo : NSObject <NSMutableCopying, REPhotoObjectProtocol>

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *photoCachePath;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *momentId;

@property (nonatomic, strong) NSURL *assetUrl;
@property (nonatomic) BOOL isSelected;

- (NSString *)description;
- (id)mutableCopyWithZone:(NSZone *)zone;

@end
