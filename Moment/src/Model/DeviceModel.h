//
//  DeviceModel.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject

+ (void)setDeviceToken:(NSString*)token;
+ (NSDictionary*)data;

@end
