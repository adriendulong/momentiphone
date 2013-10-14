//
//  ImporterFBViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCoreData+Model.h"
#import "FacebookEvent.h"

@interface ImporterFBViewController : UITableViewController

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *moments;

@property (nonatomic, weak) UIViewController <TimeLineDelegate> *timeLine;

- (id)initWithTimeLine:(UIViewController <TimeLineDelegate> *)timeLine;

@end
