//
//  Cagnotte3ViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cagnotte3ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *parametres;
@property (nonatomic, strong) NSMutableArray *invites;
@property (nonatomic, strong) NSArray *users;

@property (nonatomic, weak) IBOutlet UIView *bandeauView;
@property (nonatomic, weak) IBOutlet UILabel *bandeauLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *inviteAllButton;

- (id)initParametres:(NSMutableDictionary *)parametres;

- (void)clicProfile:(UserClass*)user;
- (void)toggleSwitch:(BOOL)on user:(UserClass*)user;

@end
