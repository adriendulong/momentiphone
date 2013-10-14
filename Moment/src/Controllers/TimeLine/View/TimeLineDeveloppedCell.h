//
//  TimeLineDeveloppedCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TimeLineViewController.h"
#import "MomentCoreData+Model.h"

#import "CustomAGMedallionView.h"

@interface TimeLineDeveloppedCell : UITableViewCell

@property (nonatomic, weak) id <TimeLineDelegate> timeLineDelegate;
@property (nonatomic, strong) MomentClass *moment;

@property (nonatomic, weak) IBOutlet UIView *centerView;
@property (nonatomic, strong) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet UILabel *titreMoment;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (nonatomic, weak) IBOutlet UIButton *buttonPhoto;
@property (nonatomic, weak) IBOutlet UIButton *buttonInfo;
@property (nonatomic, weak) IBOutlet UIButton *buttonMessage;
@property (nonatomic, weak) IBOutlet UIButton *buttonDelete;

- (id)initWithMoment:(MomentClass*)param
        withDelegate:(id <TimeLineDelegate>)delegate
     reuseIdentifier:(NSString*)reuseIdentifier;

- (IBAction)buttonPhotoClic;
- (IBAction)buttonInfoClic;
- (IBAction)buttonMessageClic;

- (void)didAppear;
- (void)willDisappear;

@end
