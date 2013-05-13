//
//  PopUpFinCreationViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PopUpFinCreationViewController.h"
#import "MomentClass+Server.h"
#import "Config.h"

@interface PopUpFinCreationViewController ()

@end

@implementation PopUpFinCreationViewController

@synthesize moment = _moment, timeLine = _timeLine, rootViewController = _rootViewController;
@synthesize backgroundFilterView = _backgroundFilterView, backgroundImageView = _backgroundImageView;
@synthesize generalView = _generalView, backgroundImage = _backgroundImage;
@synthesize bigLabel = _bigLabel, smallLabel1 = _smallLabel1, smallLabel2 = _smallLabel2;
@synthesize switchControlState = _switchControlState, switchButton = _switchButton;

- (id)initWithRootViewController:(UIViewController*)rootViewController
                      withMoment:(MomentClass*)moment
                    withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
                  withBackground:(UIImage*)background
{    
    self = [super initWithNibName:@"PopUpFinCreationViewController" bundle:nil];
    if(self) {
        self.moment = moment;
        self.timeLine = timeLine;
        self.switchControlState = NO;
        self.backgroundImage = background;
        
        // Default Privacy = Public
        self.moment.privacy = @(MomentPrivacyPublic);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    self.backgroundImageView.image = self.backgroundImage;
    
    // iPhone 5 support
    CGRect frame = self.view.frame;
    CGFloat screenHeight = [VersionControl sharedInstance].screenHeight - STATUS_BAR_HEIGHT;
    frame.size.height = screenHeight;
    self.view.frame = frame;
    self.backgroundFilterView.frame = frame;
    self.backgroundImageView.frame = frame;
    frame = self.generalView.frame;
    frame.origin.y = (screenHeight - frame.size.height)/2.0;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
    self.generalView.frame = frame;
    [self.view addSubview:self.generalView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
        
    // Black Filter
    self.backgroundFilterView.alpha = 0;
    self.generalView.alpha = 0;
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundFilterView.alpha = 0.5;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.generalView.alpha = 1;
        }];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBigLabel:nil];
    [self setSmallLabel1:nil];
    [self setSmallLabel2:nil];
    [self setBackgroundFilterView:nil];
    [self setGeneralView:nil];
    [self setSwitchButton:nil];
    [self setMoment:nil];
    [self setTimeLine:nil];
    [self setRootViewController:nil];
    [self setBackgroundImageView:nil];
    [self setPublicButton:nil];
    [self setFriendsButton:nil];
    [self setPrivateButton:nil];
    [super viewDidUnload];
}

- (IBAction)clicInviter {
    
    // Update Privacy and isOpenInvit
    self.moment.isOpen = @(self.switchControlState);
    [self.moment updateMomentFromLocalToServerWithEnded:^(BOOL success) {
        
        // Success
        if(success) {
            // Animation
            [UIView animateWithDuration:0.3 animations:^{
                self.generalView.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.backgroundFilterView.alpha = 0;
                } completion:^(BOOL finished) {
                    
                    // Show Navigation Bar
                    self.navigationController.navigationBar.hidden = NO;
                    
                    // Update Timeline
                    [self.timeLine updateSelectedMoment:self.moment atRow:-1];
                    [self.timeLine showInviteViewControllerWithMoment:self.moment];
                    
                }];
            }];
        }
        // Erreur
        else {
            [[MTStatusBarOverlay sharedInstance]
             postImmediateErrorMessage:NSLocalizedString(@"Error_Classic", nil)
             duration:1
             animated:YES];
        }
        
        
    }];
    
}

- (IBAction)clicSwitchButton {
    self.switchControlState = !self.switchControlState;
    NSInteger position = self.switchControlState? 247:214;
    
    CGRect frame = self.switchButton.frame;
    frame.origin.x = position;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.switchButton.frame = frame;
    }];
}

- (IBAction)changePrivacy:(UIButton*)sender
{
    if(!sender.isSelected)
    {
        // Privacy Ouvert
        if(sender == self.publicButton)
        {
            self.moment.privacy = @(MomentPrivacyOpen);
            self.publicButton.selected = YES;
            self.friendsButton.selected = self.privateButton.selected = NO;
        }
        // Privacy Public
        else if(sender == self.friendsButton)
        {
            self.moment.privacy = @(MomentPrivacyPublic);
            self.friendsButton.selected = YES;
            self.publicButton.selected = self.privateButton.selected = NO;
        }
        // Privacy Private
        else
        {
            self.moment.privacy = @(MomentPrivacyPrivate);
            self.privateButton.selected = YES;
            self.publicButton.selected = self.friendsButton.selected = NO;
        }
    }
}

@end
