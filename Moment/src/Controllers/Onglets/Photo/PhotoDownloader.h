//
//  PhotoDownloader.h
//  Moment
//
//  Created by SkeletonGamer on 18/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photos;

@interface PhotoDownloader : NSObject

@property (nonatomic, strong) Photos *photo;
@property (nonatomic, copy) void (^completionHandler)(void);

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end
