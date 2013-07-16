//
//  TimeLineCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLineViewController.h"
#import "MomentCoreData+Model.h"

#import "CustomAGMedallionView.h"

@interface TimeLineCell : UITableViewCell

@property (nonatomic, weak) id <TimeLineDelegate> timeLineDelegate;
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic) NSInteger row;

@property (nonatomic, strong) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet UILabel *titre;
@property (nonatomic, weak) IBOutlet UIView *centerView;

- (id)initWithMoment:(MomentClass*)param
        withDelegate:(id <TimeLineDelegate>)delegate
             withRow:(NSInteger)row
     reuseIdentifier:(NSString*)reuseIdentifier;

- (void)willDisappear;

- (void)decallerRow:(NSInteger)decallage;

@end
