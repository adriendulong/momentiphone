//
//  RedirectionManager.h
//  Moment
//
//  Created by SkeletonGamer on 06/08/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalNotification.h"
#import "MomentClass.h"

@interface RedirectionManager : NSObject

enum SchemeType {
    SchemeTypeChat = 10,
    SchemeTypeInfo = 20,
    SchemeTypePhoto = 30
};

@property (nonatomic) enum SchemeType type;

// Singleton
+ (RedirectionManager *)sharedInstance;

- (void)sendRedirectionToMomentWithId:(NSNumber *)momentId withType:(int)type andWithApplicationState:(UIApplicationState)state;
- (void)pushToCorrectControllerFrom:(UIViewController *)actualView withType:(int)type andMoment:(MomentClass *)moment;

@end
