//
//  RowIndexInVolet.h
//  Moment
//
//  Created by SkeletonGamer on 24/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RowIndexInVolet : NSObject

@property (nonatomic, strong) NSMutableArray *indexNotifications;
//@property (nonatomic, strong) NSMutableDictionary *indexNotifications;

+ (id)sharedManager;

@end