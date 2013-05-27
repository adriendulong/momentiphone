//
//  EventMissingViewController.m
//  Moment
//
//  Created by SkeletonGamer on 27/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "EventMissingViewController.h"

@interface EventMissingViewController ()

@end

@implementation EventMissingViewController

@synthesize delegate = _delegate;

#pragma mark - Init

- (id)initWithDDMenuDelegate:(DDMenuController *)delegate
{
    self = [super initWithNibName:@"EventMissingViewController" bundle:nil];
    if(self) {
        self.delegate = delegate;
        
        [CustomNavigationController setBackButtonWithViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
