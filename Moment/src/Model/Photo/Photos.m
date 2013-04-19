//
//  Photos.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Photos.h"
#import "UserCoreData+Model.h"
#import "UserClass+Mapping.h"
#import "AFMomentAPIClient.h"

@implementation Photos

static NSDateFormatter *dateFormatter;

@synthesize owner = _owner;
@synthesize urlOriginal = _urlOriginal;
@synthesize urlThumbnail = _urlThumbnail;
@synthesize date = _date;
@synthesize nbLike = _nbLike;
@synthesize photoId = _photoId;
@synthesize imageOriginal = _imageOriginal;
@synthesize imageThumbnail = _imageThumbnail;

@synthesize photoSource = _photoSource;
@synthesize size = _size;
@synthesize index = _index;

#pragma mark - Init

- (id)initWithId:(NSInteger)photoId
           owner:(UserClass*)owner
    urlThumbnail:(NSString*)urlThumbnail
     urlOriginal:(NSString*)urlOriginal
          nbLike:(NSInteger)nbLike
            date:(NSDate*)date
            size:(CGSize)size
{
    self = [super init];
    if(self) {
        self.photoId = photoId;
        self.owner = owner;
        self.urlThumbnail = urlThumbnail;
        self.urlOriginal = urlOriginal;
        self.nbLike = nbLike;
        self.date = date;
        self.photoSource = nil;
        self.size = size;
        
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale currentLocale];
            dateFormatter.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.calendar = [NSCalendar currentCalendar];
        }
    
        if([NSDate timeIntervalSinceReferenceDate] - [date timeIntervalSinceReferenceDate] > 60*60*24) {
            dateFormatter.dateFormat = @"dd/MM/yyyy";
        }
        else {
            dateFormatter.dateFormat = @"HH:mm";
        }
    
        self.caption = (nbLike > 0) ? [NSString stringWithFormat:@"%@ - %d likes", [dateFormatter stringFromDate:date], nbLike] : [dateFormatter stringFromDate:date];
    
    }
    return self;
}

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes
{
    CGSize size;
    NSNumber *numberWidth = attributes[@"original_width"];
    NSNumber *numberHeight = attributes[@"original_height"];
    size.width = (numberWidth && ![numberWidth isKindOfClass:[NSNull class]]) ? numberWidth.floatValue : PHOTO_MAX_SIZE;
    size.height = (numberHeight && ![numberHeight isKindOfClass:[NSNull class]]) ? numberHeight.floatValue : PHOTO_MAX_SIZE;
    
    return [self initWithId:[attributes[@"id"] intValue]
                      owner:[[UserClass alloc]  initWithAttributesFromWeb:attributes[@"taken_by"]]
               urlThumbnail:attributes[@"url_thumbnail"]
                urlOriginal:attributes[@"url_original"]
                     nbLike:[attributes[@"nb_like"]intValue]
                    date:[NSDate dateWithTimeIntervalSince1970:[attributes[@"time"] doubleValue]]
                       size:size
            ];
}

+ (NSArray*)arrayWithArrayFromWeb:(NSArray*)arrayFromWeb
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[arrayFromWeb count]];
    for(NSDictionary* attributes in arrayFromWeb) {
        [array addObject:[[Photos alloc] initWithAttributesFromWeb:attributes]];
    }
    return array;
}

#pragma mark - Server

- (void)likeRequestWithEnded:(void (^) (NSInteger nbLikes) )block
{
    NSString *path = [NSString stringWithFormat:@"like/%d", self.photoId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
                
        self.nbLike = [JSON[@"nb_likes"] intValue];
        
        if(block) {
            block(self.nbLike);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(self.nbLike);
        
    }];
}

- (void)deletePhotoWithEnded:(void (^) (BOOL success) )block
{
    NSString *path = [NSString stringWithFormat:@"delphoto/%d", self.photoId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
                
        if(block) {
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
        
    }];
    
}


#pragma mark - TTPhoto

- (NSString*)URLForVersion:(TTPhotoVersion)version {
    
    switch (version) {
        case TTPhotoVersionLarge:
            return self.urlOriginal;
        case TTPhotoVersionMedium:
            return self.urlOriginal;
        case TTPhotoVersionSmall:
            return self.urlThumbnail;
        case TTPhotoVersionThumbnail:
            return self.urlThumbnail;
        default:
            return nil;
    }
}

@end
