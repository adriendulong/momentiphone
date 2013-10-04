//
//  CustomNavigationController.m
//  Moment
//
//  Created by Charlie FANCELLI on 28/06/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "CustomNavigationController.h"
#import "Config.h"
#import "CustomNavigationBarButton.h"

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
        
        if ([VersionControl sharedInstance].supportIOS7) {
            //self.navigationBar.backgroundColor = [Config sharedInstance].orangeColor;
            //self.navigationBar.barTintColor = [Config sharedInstance].orangeColor;
            //self.navigationBar.barTintColor = [UIColor colorWithRed:255/255 green:169/255 blue:48/255 alpha:1.0];
            //self.navigationBar.barTintColor = [UIColor colorWithHex:0xFFAA00];
            self.navigationBar.backgroundColor = [UIColor colorWithRed:245/155 green:245/155 blue:245/155 alpha:1.0];
            self.navigationBar.translucent = NO;
            //self.navigationBar.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"topbar-bg.png"]];
            
            [self.interactivePopGestureRecognizer setEnabled:NO];
        } else {
            if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
                UIImage *image = [UIImage imageNamed:@"topbar-bg.png"];
                [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
            }
        }
        
        
        //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
        //self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
    /*UIImage *chevron = [UIImage imageNamed:@"UINavigationBarBackIndicatorDefault.png"
                                withColor:[Config sharedInstance].orangeColor];*/
    UIImage *chevron = [UIImage imageNamed:@"UINavigationBarBackIndicatorOrange.png"];
    
    
    UIButton *button = nil;
    CGRect frame = CGRectMake(0, 0, 90, 40);
    if ([VersionControl sharedInstance].supportIOS7) {
        button = [[CustomNavigationBarButton alloc] initWithFrame:frame andIsLeftButton:YES];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
    } else {
        button = [[UIButton alloc] initWithFrame:frame];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    }
    
    //button.backgroundColor = [UIColor greenColor];
    
    [button setImage:chevron forState:UIControlStateNormal];
    [button setImage:chevron forState:UIControlStateSelected];
    
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    //[button.titleLabel setTextAlignment:NSTextAlignmentRight];
    [button setTitle:@"Moments" forState:UIControlStateNormal];
    [button setTitle:@"Moments" forState:UIControlStateSelected];
    [button setTitleColor:[Config sharedInstance].orangeColor forState:UIControlStateNormal];
    [button setTitleColor:[Config sharedInstance].orangeColor forState:UIControlStateSelected];
    //[button.titleLabel setText:@"Moments"];
    
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