//
//  DeviceModel.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "DeviceModel.h"
#import "OpenUDID.h"
#import "UIDevice-Hardware.h"

@implementation DeviceModel

static NSString * deviceTokenKey = @"DeviceTokenKey";

+ (NSString*)openUDID {
    return [OpenUDID value];
}

+ (NSString*)osVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString*)model {
    return [UIDevice currentDevice].platformString;
}

+ (void)setDeviceToken:(NSString*)token {
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:deviceTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)deviceToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:deviceTokenKey];
}

+ (NSString*)language {
    NSArray *array = [NSLocale preferredLanguages];
    if([array count] > 0)
        return array[0];
    return nil;
}

+ (NSDictionary*)data {
    
    NSString *token = [self deviceToken];
    NSString *lang = [self language];
    if(token && lang) {
        NSDictionary *val = @{
                             @"os":@(0),
                             @"os_version":[self osVersion],
                             @"model":[self model],
                             @"device_id":[self openUDID],
                             @"notif_id":token,
                             @"lang":lang
                             };
        
        //NSLog(@"model data = %@", val);
        return val;
    }
    else {
        
        NSString *stringError = [NSString stringWithFormat:@"Error with data model : %@\n notif_id = %@\n lang = %@", @{
                                 @"os":@(0),
                                 @"os_version":[self osVersion],
                                 @"model":[self model],
                                 @"device_id":[self openUDID],
                                 }, token, lang];
        
        NSLog(@"%@", stringError);
        
        [[[UIAlertView alloc] initWithTitle:@"Data Model Error" message:stringError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    return nil;
}

@end
