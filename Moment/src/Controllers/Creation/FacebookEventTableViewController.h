//
//  FacebookEventTableViewController.h
//  Moment
//
//  Created by Charlie FANCELLI on 26/09/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookEventTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *facebookEvents;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFacebookEvents:(NSArray *)facebookEvents;

@end
