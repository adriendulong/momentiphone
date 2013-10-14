//
//  ErrorManager.h
//  Moment
//
//  Created by SkeletonGamer on 27/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorManager : NSObject

+ (ErrorManager *)sharedInstance;
+ (void)performActionForThisError:(NSInteger)error;

@end
