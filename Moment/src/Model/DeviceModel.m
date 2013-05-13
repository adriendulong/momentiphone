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
#import "AFMomentAPIClient.h"

// Clé NSUserDefaults
// -> Envoyer requete de logout si elle a échoué
#define kDeviceShouldLogout @"DeviceShouldLogout"

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

#pragma mark - Device Should Logout

+ (BOOL)deviceShouldLogout {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDeviceShouldLogout];
}

+ (void)setDeviceShouldLogout:(BOOL)logout {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(logout) {
        [userDefaults setBool:YES forKey:kDeviceShouldLogout];
    } else {
        [userDefaults removeObjectForKey:kDeviceShouldLogout];
    }
    
    [userDefaults synchronize];
}

#pragma mark - Server

+ (void)logout
{
    NSString *path = [NSString stringWithFormat:@"logout/%@", [self openUDID]];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        // Logout success
        [self setDeviceShouldLogout:NO];
        
        NSLog(@"STOP Push Notification Success");
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"STOP Push Notifications Fail");
        HTTP_ERROR(operation, error);
        
        // Logout Fail -> Force Logout when it's possible
        [self setDeviceShouldLogout:YES];
    }];
}

@end
