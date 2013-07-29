//
//  Cagnotte3TableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSwitch.h"
#import "CustomAGMedallionView.h"
#import "Cagnotte3ViewController.h"

@interface Cagnotte3TableViewCell : UITableViewCell

@property (nonatomic, strong) UserClass *user;
@property (nonatomic, weak) Cagnotte3ViewController *delegate;

@property (nonatomic, weak) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet CustomSwitch *switchButton;
@property (nonatomic, weak) IBOutlet UILabel *nomLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

- (id)initWithUser:(NSMutableDictionary*)user
          delegate:(Cagnotte3ViewController*)delegate
             index:(NSInteger)index
   reuseIdentifier:(NSString *)reuseIdentifier;

@end
