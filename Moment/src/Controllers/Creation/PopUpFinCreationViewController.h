//
//  PopUpFinCreationViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopUpFinCreationViewController : UIViewController

@property (strong, nonatomic) MomentClass *moment;
@property (weak, nonatomic) UIViewController <TimeLineDelegate> *timeLine;
@property (weak, nonatomic) UIViewController *rootViewController;

@property (weak, nonatomic) IBOutlet UIView *backgroundFilterView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (strong, nonatomic) UIImage *backgroundImage;

@property (weak, nonatomic) IBOutlet UILabel *bigLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallLabel1;
@property (weak, nonatomic) IBOutlet UILabel *smallLabel2;

@property (nonatomic, weak) IBOutlet UIButton *switchButton;
@property (nonatomic) BOOL switchControlState;

@property (weak, nonatomic) IBOutlet UIButton *publicButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *privateButton;

@property (weak, nonatomic) IBOutlet UILabel *privacyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyDetailsLabel;


- (id)initWithRootViewController:(UIViewController*)rootViewController
                      withMoment:(MomentClass*)moment
                    withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
                  withBackground:(UIImage*)background;

- (IBAction)clicInviter;
- (IBAction)clicSwitchButton;

@end
