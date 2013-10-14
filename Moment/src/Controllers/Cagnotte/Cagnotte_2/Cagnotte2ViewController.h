//
//  Cagnotte2ViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchTextField.h"

@interface Cagnotte2ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *parametres;
@property (nonatomic, strong) NSMutableArray *products;

@property (weak, nonatomic) IBOutlet UILabel *bandeauLabel;
@property (nonatomic, weak) IBOutlet UIView *bandeauView;;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet CustomSearchTextField *searchTextField;

- (id)initWitParametres:(NSMutableDictionary *)parametres;

@end
