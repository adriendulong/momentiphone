//
//  FullScreenPhotoViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FullScreenPhotoViewController.h"
#import "Photos.h"
#import "GAI.h"

@interface FullScreenPhotoViewController ()

@end

@implementation FullScreenPhotoViewController

- (id)initWithTitle:(NSString*)title withPhotos:(NSArray*)photos delegate:(BigPhotoViewController*)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        self.photoSource = [[PhotoSet alloc] initWithTitle:title withPhotos:photos];
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self showPhotoAtIndex:self.delegate.selectedIndex];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Photo FullScreen"];
}

/*
- (void)viewDidAppear:(BOOL)animated
{
    static BOOL isRotating = NO;
    
    [super viewDidAppear:animated];
    
    NSLog(@"View Did Appear");
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if( !isRotating && (orientation != UIDeviceOrientationPortrait) && ([self shouldAutorotateToInterfaceOrientation:orientation]) ) {
        isRotating = YES;
        NSLog(@"Change orientation");
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
        //present/dismiss viewcontroller in order to activate rotating.
        UIViewController *mVC = [[UIViewController alloc] init];
        [self presentViewController:mVC animated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else if(isRotating) {
        NSLog(@"Already rotated");
        isRotating = NO;
    }
    else {
        NSLog(@"Don't change orientation");
    }
}
 */

- (void)showPhoto:(id<TTPhoto>)photo
{
    self.centerPhoto = photo;
}

#pragma mark - TTPhotoViewController

-(void)didLoadModel:(BOOL)firstTime
{
    [super didLoadModel:firstTime];
    // Remove "See all" button
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didMoveToPhoto:(Photos<TTPhoto>*)photo fromPhoto:(Photos<TTPhoto>*)fromPhoto {
    [super didMoveToPhoto:photo fromPhoto:fromPhoto];

    if(fromPhoto.index < photo.index) {
        [self.delegate clicPrevious];
    }
    else {
        [self.delegate clicNext];
    }
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //NSLog(@"ViewController Will Rotate to Interface Orientation : %d", toInterfaceOrientation);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //TFLog((@"%s [Line %d] Should Autorotate to interface %d" ), __PRETTY_FUNCTION__, __LINE__, interfaceOrientation);
    if (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) {
        //NSLog(@"Rotation to orientation %d", interfaceOrientation);
        return YES;
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
    TFLog((@"%s [Line %d] supported interface orientation" ), __PRETTY_FUNCTION__, __LINE__);
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
