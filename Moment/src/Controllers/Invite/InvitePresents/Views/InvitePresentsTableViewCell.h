//
//  InvitePresentsTableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserClass.h"
#import "CustomAGMedallionView.h"
#import "TTTAttributedLabel.h"
#import "InvitePresentsTableViewController.h"

@interface InvitePresentsTableViewCell : UITableViewCell

@property (nonatomic, weak) UserClass *user;
@property (nonatomic) NSInteger index;
@property (nonatomic, weak) InvitePresentsTableViewController *delegate;

@property (nonatomic, weak) IBOutlet CustomAGMedallionView *medaillon;
@property (nonatomic, weak) IBOutlet UILabel *nomLabel;
@property (nonatomic, weak) IBOutlet UILabel *adresseLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttNomLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttAdresseLabel;
@property (nonatomic, weak) IBOutlet UIButton *adminButton;
@property (nonatomic, weak) IBOutlet UILabel *adminLabel;
@property (nonatomic) BOOL adminSelected;

@property (nonatomic, strong) NSString *nomText;
@property (nonatomic, strong) NSString *prenomText;
@property (nonatomic, strong) NSString *phoneText;
@property (nonatomic, strong) NSString *emailText;
@property (nonatomic, strong) NSString *adresseText;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIColor *backgroundDefaultColor;
@property (nonatomic) BOOL isGoldProfile;

- (id)initWithAttributes:(NSMutableDictionary*)attributes
               withIndex:(NSInteger)index
               withAdmin:(BOOL)adminAccess
            withDelegate:(InvitePresentsTableViewController*)delegate
         reuseIdentifier:(NSString*)reuseIdentifier;

- (IBAction)clicAdmin;

@end
