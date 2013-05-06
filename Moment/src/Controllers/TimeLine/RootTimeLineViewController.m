//
//  RootTimeLineViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RootTimeLineViewController.h"
#import "MomentClass+Server.h"
#import "VoletViewController.h"

@interface RootTimeLineViewController () {
    @private
    UIButton *plusButton;
}

@end

@implementation RootTimeLineViewController

@synthesize navController = _navController;
@synthesize ddMenuViewController = _ddMenuViewController;;
@synthesize size = _size;
@synthesize timeLineStyle = _timeLineStyle;

@synthesize user = _user;
@synthesize publicFeedList = _publicFeedList, privateTimeLine = _privateTimeLine;
@synthesize isShowingPrivateTimeLine = _isShowingPrivateTimeLine;

@synthesize changeTimeLineButton = _changeTimeLineButton;

- (id)initWithUser:(UserClass*)user
          withSize:(CGSize)size withStyle:(enum TimeLineStyle)style
withNavigationController:(UINavigationController*)navController
{
    self = [super initWithNibName:@"RootTimeLineViewController" bundle:nil];
    if(self) {
        self.user = user;
        self.navController = navController;
        self.size = size;
        self.isShowingPrivateTimeLine = YES;
        
        // Navigation Bar
        [CustomNavigationController customNavBarWithLogo:[UIImage imageNamed:@"logo.png"] withViewController:self];
        
        // Plus Button
        UIImage *image = [UIImage imageNamed:@"topbar_add.png"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [button setImage:image forState:UIControlStateNormal];
        //[button setImage:image forState:UIControlStateHighlighted];
        [button setImage:image forState:UIControlStateSelected];
        [button addTarget:self action:@selector(showAddEvent) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        self.navigationItem.rightBarButtonItem = buttonItem;
        plusButton = button;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation Controller
    if(!self.navController)
        self.navController = self.navigationController;
    
    // iPhone 5
    self.view.frame = CGRectMake(0,0, self.size.width, self.size.height);
    CGRect frame = self.changeTimeLineButton.frame;
    frame.origin.y = self.size.height - frame.size.height - 10;
    self.changeTimeLineButton.frame = frame;
    
    // Init
    [self showContentViewController:self.privateTimeLine];
    // Préload public timeLine
    [self.publicFeedList.view setNeedsDisplay];
    self.publicFeedList.view.alpha = 0;
    
    // Préload Volet
    [[VoletViewController volet] loadNotifications];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChangeTimeLineButton:nil];
    [super viewDidUnload];
}

#pragma mark - Animation

- (void)showContentViewController:(UIViewController*)viewController
{
    // Add new TimeLine
    viewController.view.alpha = 0;
    [self.view addSubview:viewController.view];
    [self.view bringSubviewToFront:self.changeTimeLineButton];

    // Page Curl Animation
    [UIView beginAnimations:@"TimeLineToggle" context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if(self.isShowingPrivateTimeLine)
        [UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    else
        [UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(clearView)]; // Remove Previews TimeLine

    viewController.view.alpha = 1;
    
    // On change le bouton
    UIImage *image = self.isShowingPrivateTimeLine ?
    [UIImage imageNamed:@"timeLine_bouton_public"] : [UIImage imageNamed:@"timeLine_bouton_private"];
    [self.changeTimeLineButton setImage:image forState:UIControlStateNormal];

    [UIView commitAnimations];
}

- (void)clearView {
    if(self.isShowingPrivateTimeLine)
        [self.publicFeedList.view removeFromSuperview];
    else
        [self.privateTimeLine.view removeFromSuperview];
}

#pragma mark - Actions

- (IBAction)clicChangeTimeLine {    
    
    if(self.isShowingPrivateTimeLine) {
        
        // Hide Plus Button
        [UIView animateWithDuration:0.3 animations:^{
            plusButton.alpha = 0;
        } completion:^(BOOL finished) {
            
            plusButton.hidden = YES;
        }];
        
        // Update Volet
        [[VoletViewController volet] selectActualitesButton];
        
        // Update View
        self.isShowingPrivateTimeLine = NO;
        [self showContentViewController:self.publicFeedList];
        
    }
    else {
        
        // Show Plus Button
        [UIView animateWithDuration:0.3 animations:^{
            plusButton.alpha = 1;
        } completion:^(BOOL finished) {
            plusButton.hidden = NO;
        }];
        
        // Update Volet
        [[VoletViewController volet] selectMesMomentsButton];
        
        // Update View
        self.isShowingPrivateTimeLine = YES;
        [self showContentViewController:self.privateTimeLine];
    }
}

- (void)showAddEvent
{
    CreationHomeViewController *creationViewController = [[CreationHomeViewController alloc] initWithUser:self.user withTimeLine:self.privateTimeLine];
    [self.navController pushViewController:creationViewController animated:YES];
}

#pragma mark - Getters and Setters

- (FeedViewController*)publicFeedList {
    
    if(!_publicFeedList) {
        _publicFeedList = [[FeedViewController alloc] initWithRootViewController:self];
    }
    
    return _publicFeedList;
}

- (TimeLineViewController*)privateTimeLine {
    if(!_privateTimeLine) {
        
        NSArray *moments = [MomentCoreData getMoments];
        
        _privateTimeLine = [[TimeLineViewController alloc] initWithMoments:moments withStyle:self.timeLineStyle withSize:self.size withRootViewController:self];
        
    }
    return _privateTimeLine;
}

- (TimeLineViewController*)timeLineForMoment:(MomentClass*)moment
{
    if([self.privateTimeLine hasMoment:moment])
        return self.privateTimeLine;
    
    // Défaut ajout sur la privé
    NSMutableArray *array = self.privateTimeLine.moments.mutableCopy;
    [array removeLastObject];
    [array removeObjectAtIndex:0];
    
    [array addObject:moment];
    [array sortUsingComparator:^NSComparisonResult(MomentClass * obj1, MomentClass * obj2) {
        return [obj1.dateDebut compare:obj2.dateDebut];
    }];
    
    [self.privateTimeLine reloadDataWithMoments:array];
    
    return self.privateTimeLine;
}

@end
