//
//  VoletSearchViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchVolletTextField.h"
#import "VoletViewController.h"

@interface VoletSearchViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) VoletViewController *delegate;
@property (nonatomic, strong) NSArray *moments, *utilisateurs;
@property (nonatomic) NSInteger nbPrivateMoments;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Search
@property (weak, nonatomic) IBOutlet UIButton *annulerButton;
@property (weak, nonatomic) IBOutlet CustomSearchVolletTextField *searchBarTextField;

// Segment
@property (nonatomic) BOOL isShowingMoments;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *momentsButton;
@property (weak, nonatomic) IBOutlet UIButton *utilisateursButton;
@property (weak, nonatomic) IBOutlet UIImageView *segementShadow;

// Nb Moments
@property (strong, nonatomic) IBOutlet UIView *nbMomentsView;
@property (weak, nonatomic) IBOutlet UILabel *nbMomentsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nbMomentsBackground;

// Nb Utilisateurs
@property (strong, nonatomic) IBOutlet UIView *nbUtilisateursView;
@property (weak, nonatomic) IBOutlet UILabel *nbUtilisateursLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nbUtilisateursBackground;

// Init
- (id)initWithDelegate:(VoletViewController*)delegate;

// VoletSearchViewController Delegate
- (IBAction)clicAnnuler;

@end
