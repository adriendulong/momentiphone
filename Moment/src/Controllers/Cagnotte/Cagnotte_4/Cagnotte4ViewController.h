//
//  Cagnotte4ViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CagnotteProduct.h"

@interface Cagnotte4ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *parametres;
@property (nonatomic, strong) NSArray *participants;
@property (nonatomic, strong) CagnotteProduct *product;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bandeauView;
@property (weak, nonatomic) IBOutlet UILabel *bandeauLabel;
@property (weak, nonatomic) IBOutlet CustomUIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *organisePourLabel;
@property (weak, nonatomic) IBOutlet UILabel *cagnotteLabel;

@property (weak, nonatomic) IBOutlet UIImageView *descriptionBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *argentImage;
@property (weak, nonatomic) IBOutlet UILabel *argentLabel;
@property (weak, nonatomic) IBOutlet UILabel *argentInfoLabel;

@property (weak, nonatomic) IBOutlet UIImageView *participantsImage;
@property (weak, nonatomic) IBOutlet UILabel *participantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *participantsInfoLabel;

@property (weak, nonatomic) IBOutlet UIImageView *tempsImage;
@property (weak, nonatomic) IBOutlet UILabel *tempsLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempsInfoLabel;

@property (weak, nonatomic) IBOutlet UIButton *participeButton;
@property (weak, nonatomic) IBOutlet UIButton *recupereButton;

@property (strong, nonatomic) IBOutlet UIImageView *shadowView;

- (id)initWithParametres:(NSMutableDictionary *)parametres;

- (void)clicProfile:(UserClass*)user;

@end
