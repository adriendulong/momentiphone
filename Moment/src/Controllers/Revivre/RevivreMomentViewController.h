//
//  RevivreMomentViewController.h
//  Moment
//
//  Created by SkeletonGamer on 02/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface RevivreMomentViewController : GAITrackedViewController

// --- Properties ---

@property (nonatomic, weak) UIViewController <TimeLineDelegate> *timeLineViewContoller;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) DDMenuController *delegate;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *creaImageView;
@property (weak, nonatomic) IBOutlet UIButton *recupererEventsButton;

// --- Methodes ---

- (id)initWithDDMenuDelegate:(DDMenuController*)delegate withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine;

// --- Actions ---

- (IBAction)clicRecupererEvents:(id)sender;

@end
