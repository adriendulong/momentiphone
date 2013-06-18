//
//  RotationNavigationControllerViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RotationNavigationControllerViewController.h"

@interface RotationNavigationControllerViewController ()

@end

@implementation RotationNavigationControllerViewController

@synthesize activeRotation = _activeRotation;

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if(self) {
        self.activeRotation = NO;
    }
    return self;
}

#pragma mark - Transitions

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.view.layer addAnimation:transition forKey:@"RotationNavigationControllerPop"];
    
    self.activeRotation = NO;
    self.navigationBar.hidden = YES;
    return [super popViewControllerAnimated:NO];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.view.layer addAnimation:transition forKey:@"RotationNavigationControllerPush"];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(  (orientation != UIDeviceOrientationPortrait) && ([viewController shouldAutorotateToInterfaceOrientation:orientation]) ) {
        //NSLog(@"Change orientation");
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
        
        // Correctly autoOrient the given view controller
        [[VersionControl sharedInstance] presentModalViewController:viewController fromRoot:self animated:NO];
        [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self animated:NO];
    }
    
    [super pushViewController:viewController animated:NO];
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //NSLog(@"NavigationController Will Rotate to Interface Orientation : %d", toInterfaceOrientation);
    [self.visibleViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //TFLog((@"%s [Line %d] Should Autorotate to interface %d" ), __PRETTY_FUNCTION__, __LINE__, interfaceOrientation);
    if(self.activeRotation && 0)
    {
        //NSLog(@"Rotation ON - 2");
        if (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) {
            //NSLog(@"Rotation to orientation %d", interfaceOrientation);
            return YES;
        }
    }
    else {
        //NSLog(@"Rotation OFF - 2");
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //NSLog(@"Rotation to orientation %d", interfaceOrientation);
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldAutorotate
{
    //TFLog((@"%s [Line %d] Should Autorotate" ), __PRETTY_FUNCTION__, __LINE__);
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //TFLog((@"%s [Line %d] supported interface orientation" ), __PRETTY_FUNCTION__, __LINE__);
    if(self.activeRotation && 0) {
        //NSLog(@"Rotation ON - 1");
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    //NSLog(@"Rotation OFF - 1");
    return UIInterfaceOrientationMaskPortrait;
}

/*
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return YES;
}
*/

@end
