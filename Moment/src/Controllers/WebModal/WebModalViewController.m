//
//  WebModalViewController.m
//  Moment
//
//  Created by SkeletonGamer on 08/07/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "WebModalViewController.h"

@interface WebModalViewController ()

@end

@implementation WebModalViewController

@synthesize url =_url;

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {        
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadUIWebView];
    [self loadUIToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AppDelegate updateActualViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUIWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    [webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self.view addSubview:webView];
}

- (void)loadUIToolBar
{
    UIBarButtonItem *closeView = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"WebModalViewController_Toolbar_CloseButton", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(closeView)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:closeView];
    [toolbar setItems:items animated:NO];
    [self.view addSubview:toolbar];
}

- (void)closeView
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
