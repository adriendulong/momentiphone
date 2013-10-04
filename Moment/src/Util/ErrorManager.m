//
//  ErrorManager.m
//  Moment
//
//  Created by SkeletonGamer on 27/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ErrorManager.h"


#import "AppDelegate.h"

#import "UserClass+Server.h"
#import "RedirectionManager.h"
#import "HomeViewController.h"

@implementation ErrorManager

#pragma mark - Singleton

static ErrorManager *sharedInstance = nil;

+ (ErrorManager *)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

+ (void)performActionForThisError:(NSInteger)error
{
    NSLog(@"performActionForThisError = %i", error);
    
    switch (error) {
        case 0: {
            [UserClass logoutCurrentUserWithRequestToServer:NO withEnded:^ {
                // Show Home
                UIViewController *actualViewController = [AppDelegate actualViewController];
                [actualViewController.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
