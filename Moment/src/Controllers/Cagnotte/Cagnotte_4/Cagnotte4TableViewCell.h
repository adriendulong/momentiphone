//
//  Cagnotte4TableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 16/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cagnotte4ViewController.h"

@interface Cagnotte4TableViewCell : UITableViewCell

@property (nonatomic, strong) UserClass *user;
@property (nonatomic, weak) Cagnotte4ViewController *delegate;

@property (nonatomic, weak) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet UILabel *nomLabel;
@property (nonatomic, weak) IBOutlet UILabel *montantLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

- (id)initWithUser:(UserClass*)user
          delegate:(Cagnotte4ViewController*)delegate
             index:(NSInteger)index
   reuseIdentifier:(NSString *)reuseIdentifier;

@end
