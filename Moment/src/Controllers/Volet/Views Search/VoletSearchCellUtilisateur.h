//
//  VoletSearchCellUtilisateur.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoletSearchViewController.h"
#import "CustomAGMedallionView.h"

@interface VoletSearchCellUtilisateur : UITableViewCell

@property (nonatomic, weak) UserClass *user;

@property (nonatomic, weak) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet UILabel *nomLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

- (id)initWithUser:(UserClass*)user reuseIdentifier:(NSString*)reuseIdentifier;

@end
