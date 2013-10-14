//
//  SMSComposeViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 17/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "SMSComposeViewController.h"

@interface SMSComposeViewController ()

@end

@implementation SMSComposeViewController

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
