//
//  PlacesViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreationFicheViewController.h"
#import "CustomSearchTextField.h"

@interface PlacesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) id <CreationFicheViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet CustomSearchTextField *searchTextField;

- (id)initWithDelegate:(id <CreationFicheViewControllerDelegate>)delegate;

@end
