//
//  RevivreImportFBViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UserCoreData+Model.h"
#import "FacebookEvent.h"

@interface RevivreImportFBViewController : UITableViewController

@property (nonatomic, strong) NSArray *eventsValid;
@property (nonatomic, strong) NSArray *eventsMaybe;
//@property (nonatomic, strong) NSArray *moments;
@property (nonatomic, strong) NSMutableArray *selectedRowsValid;
@property (nonatomic, strong) NSMutableArray *selectedRowsMaybe;

@property (nonatomic, weak) UIViewController <TimeLineDelegate> *timeLine;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (id)initWithTimeLine:(UIViewController <TimeLineDelegate> *)timeLine;

@end
