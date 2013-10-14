//
//  RowIndexInVolet.m
//  Moment
//
//  Created by SkeletonGamer on 24/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RowIndexInVolet.h"

@implementation RowIndexInVolet

@synthesize indexNotifications;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static RowIndexInVolet *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        indexNotifications = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end