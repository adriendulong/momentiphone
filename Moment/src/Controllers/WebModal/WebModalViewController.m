//
//  WebModalViewController.m
//  Moment
//
//  Created by SkeletonGamer on 08/07/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "WebModalViewController.h"
#import "CustomToolbar.h"
#import "Config.h"

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
    UIImage *buttonTitle = [[Config sharedInstance] imageFromText:@"Fermer" withColor:[Config sharedInstance].orangeColor andFont:[[Config sharedInstance] defaultFontWithSize:20]];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonTitle.size.width, buttonTitle.size.height)];
    [button setImage:buttonTitle forState:UIControlStateNormal];
    [button setImage:buttonTitle forState:UIControlStateSelected];
    [button addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    CustomToolbar *toolbar = [[CustomToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:closeButton];
    [toolbar setItems:items animated:NO];
    [self.view addSubview:toolbar];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
