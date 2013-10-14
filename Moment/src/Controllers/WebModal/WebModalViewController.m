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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUIWebView
{
    int pixelY = NAVIGATION_BAR_HEIGHT;
    
    if ([VersionControl sharedInstance].supportIOS7) {
        pixelY = TOPBAR_HEIGHT;
    }
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, pixelY, self.view.bounds.size.width, self.view.bounds.size.height-pixelY)];
    [webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self.view addSubview:webView];
}

- (void)loadUIToolBar
{
    UIImage *buttonTitle = [[Config sharedInstance] imageFromText:NSLocalizedString(@"WebModalViewController_Toolbar_CloseButton", nil) withColor:[Config sharedInstance].orangeColor andFont:[[Config sharedInstance] defaultFontWithSize:20]];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonTitle.size.width, buttonTitle.size.height)];
    [button setImage:buttonTitle forState:UIControlStateNormal];
    [button setImage:buttonTitle forState:UIControlStateSelected];
    [button addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    int pixelY = 0;
    
    if ([VersionControl sharedInstance].supportIOS7) {
        pixelY = STATUS_BAR_HEIGHT;
    }
    
    CustomToolbar *toolbar = [[CustomToolbar alloc] init];
    toolbar.frame = CGRectMake(0, pixelY, self.view.frame.size.width, NAVIGATION_BAR_HEIGHT);
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    [items addObject:closeButton];
    [toolbar setItems:items animated:NO];
    [self.view addSubview:toolbar];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
