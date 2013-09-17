//
//  CustomNavigationController.m
//  Moment
//
//  Created by Charlie FANCELLI on 28/06/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "CustomNavigationController.h"
#import "Config.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (id) initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if( self ) {
        
        //[self setValue:[[PrettyNavigationBar alloc] init] forKeyPath:@"navigationBar"];
        
        //PrettyNavigationBar *navBar = (PrettyNavigationBar *)self.navigationBar;
        
        //navBar.roundedCornerRadius = 5.0;
        //navBar.roundedCornerColor = [UIColor blackColor];
        
        /*
        navBar.topLineColor = [UIColor colorWithHex:0xffffff];
        navBar.gradientStartColor = [UIColor colorWithHex:0xeef0f4];
        navBar.gradientEndColor = [UIColor colorWithHex:0xffffff];
        navBar.bottomLineColor = [UIColor colorWithHex:0xeef0f4];
        navBar.tintColor = [UIColor colorWithHex:0xfdfdfd];
         */
        
        rootViewController.navigationItem.hidesBackButton = YES;
        rootViewController.navigationItem.backBarButtonItem = nil;
        
        if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
            UIImage *image = [UIImage imageNamed:@"topbar-bg.png"];
            [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        }
        
        self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

#pragma mark - Customisations

+ (void)setTitle:(NSString *)title withColor:(UIColor *)color withViewController:(UIViewController *) viewController
{
    UILabel *titleView = (UILabel *)viewController.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,1,1)];
        titleView.backgroundColor = [UIColor clearColor];
        
        if(title.length > 20)
            titleView.font = [UIFont systemFontOfSize:17];
            //titleView.font = [[Config sharedInstance] defaultFontWithSize:13];
        else
            titleView.font = [UIFont systemFontOfSize:17];
            //titleView.font = [[Config sharedInstance] defaultFontWithSize:18];
        
        //titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.shadowColor = nil;
        
        titleView.textColor = color; //UIColorFromRGB(0x0057af)
        
        viewController.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

+ (void)setLogo:(UIImage*)logo withViewController:(UIViewController*)viewController
{
    UIImageView *titleView = (UIImageView*)viewController.navigationItem.titleView;
    if(!titleView)
    {
        titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,1,1) ];
        titleView.backgroundColor = [UIColor clearColor];
        
        viewController.navigationItem.titleView = titleView;
    }
    [titleView setImage:logo];
    [titleView sizeToFit];
}

+ (void)setBackButtonWithViewController:(UIViewController *) viewController
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"btn-back.png"];
    
    button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateSelected];
    
    [button addTarget:viewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    viewController.navigationItem.hidesBackButton = YES;
    viewController.navigationItem.backBarButtonItem = nil;
    viewController.navigationItem.leftBarButtonItem = barBackItem;
}

+ (void)setBackButtonChevronWithViewController:(UIViewController *)viewController
{
    [self setBackButtonChevronWithViewController:viewController withNewBackSelector:nil];
}

+ (void)setBackButtonChevronWithViewController:(UIViewController *)viewController withNewBackSelector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"chevron-left-orange.png"];
    
    button.frame = CGRectMake(0, 0, 44, 44);
    
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateSelected];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    
    if (!selector) {
        [button addTarget:viewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [button addTarget:viewController action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    viewController.navigationItem.hidesBackButton = YES;
    viewController.navigationItem.backBarButtonItem = nil;
    viewController.navigationItem.leftBarButtonItem = barBackItem;
}

+ (void)setBackButtonWithImage:(UIImage *)img withViewController:(UIViewController *)viewController withSelector:(SEL)selector andWithTarget:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(0, 0, 80, 44);
    //button.backgroundColor = [UIColor orangeColor];
    
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateSelected];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 45)];
    
    //[button addTarget:viewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    if (target) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    } else {
        [button addTarget:viewController.navigationController action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    viewController.navigationItem.hidesBackButton = YES;
    viewController.navigationItem.backBarButtonItem = nil;
    viewController.navigationItem.leftBarButtonItem = barBackItem;
}

+ (void)setBackButtonWithTitle:(NSString *)title andColor:(UIColor *)color andFont:(UIFont *)font withViewController:(UIViewController *)viewController withSelector:(SEL)selector andWithTarget:(id)target
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIImage *img = [UIImage imageNamed:@"btn-back-trans.png"];
    UIImage *img = [[Config sharedInstance] imageFromText:title withColor:color andFont:font];
    
    button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateSelected];
    
    //[button addTarget:viewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    if (target) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    } else {
        [button addTarget:viewController.navigationController action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [barBackItem setTitle:title];
    
    viewController.navigationItem.hidesBackButton = YES;
    viewController.navigationItem.backBarButtonItem = nil;
    viewController.navigationItem.leftBarButtonItem = barBackItem;
}


+ (void)customNavBarWithTitle:(NSString *)title withColor:(UIColor *)color withViewController:(UIViewController *) viewController {
    
    [CustomNavigationController setTitle:title withColor:color withViewController:viewController];
    [CustomNavigationController setBackButtonWithViewController:viewController];
}

+ (void)customNavBarWithLogo:(UIImage*)logo withViewController:(UIViewController *) viewController {
    
    [CustomNavigationController setLogo:logo withViewController:viewController];
    [CustomNavigationController setBackButtonWithViewController:viewController];
}

+ (void)customToolBarWithLogo:(UIImage*)logo withViewController:(UIViewController *) viewController {
    
    [CustomNavigationController setLogo:logo withViewController:viewController];
    viewController.navigationItem.hidesBackButton = YES;
    viewController.navigationItem.backBarButtonItem = nil;
}

+ (void) setRightBarButtonWithImage:(UIImage*)image withTarget:(id)target withAction:(SEL)action withViewController:(UIViewController*)viewController
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    //[button setImage:image forState:UIControlStateHighlighted];
    [button setImage:image forState:UIControlStateSelected];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    viewController.navigationItem.rightBarButtonItem = buttonItem;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end