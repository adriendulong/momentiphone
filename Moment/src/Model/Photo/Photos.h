//
//  Photos.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCoreData.h"
#import "Three20/Three20.h"

#define PHOTO_MAX_SIZE 900.0f

// Le protocol TTPhoto est défini dans la librairie Three20
// --> Il est utilisé par TTPhotoViewController
@interface Photos : NSObject <TTPhoto>

@property (nonatomic, strong) UserClass* owner;
@property (nonatomic, strong) NSString *urlThumbnail;
@property (nonatomic, strong) NSString *urlOriginal;
@property (nonatomic, strong) NSString *uniqueURL;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIImage *imageThumbnail;
@property (nonatomic, strong) UIImage *imageOriginal;
@property (nonatomic) NSInteger photoId;
@property (nonatomic) NSInteger nbLike;

// TTPhoto Protocol
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, assign) id <TTPhotoSource> photoSource;
@property (nonatomic) CGSize size;
@property (nonatomic) NSInteger index;

// Init
- (id)initWithId:(NSInteger)photoId
           owner:(UserClass*)owner
    urlThumbnail:(NSString*)urlThumbnail
     urlOriginal:(NSString*)urlOriginal
       uniqueURL:(NSString*)uniqueURL
          nbLike:(NSInteger)nbLike
            date:(NSDate*)date
            size:(CGSize)size;

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes;
+ (NSArray*)arrayWithArrayFromWeb:(NSArray*)arrayFromWeb;

// Server
- (void)likeRequestWithEnded:(void (^) (NSInteger nbLikes) )block;
- (void)deletePhotoWithEnded:(void (^) (BOOL success) )block;

@end
