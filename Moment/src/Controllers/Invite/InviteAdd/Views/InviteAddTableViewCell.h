//
//  InviteAddTableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAGMedallionView.h"
#import "InfoMomentSeparateurView.h"
#import "TTTAttributedLabel.h"
#import "CustomLabel.h"

@interface InviteAddTableViewCell : UITableViewCell

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) UserClass *user;

@property (nonatomic, weak) IBOutlet CustomAGMedallionView *medallion;

@property (nonatomic, weak) IBOutlet CustomLabel *nomLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttNomLabel;
@property (nonatomic, strong) NSString *nomText;
@property (nonatomic, strong) NSString *prenomText;
@property (nonatomic, strong) NSString *phoneText;
@property (nonatomic, strong) NSString *emailText;

@property (nonatomic, weak) IBOutlet CustomLabel *adresseLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttAdresseLabel;
@property (nonatomic, strong) NSString *adresseText;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIColor *backgroundDefaultColor;
@property (nonatomic) BOOL isGoldProfile;

- (id)initWithUser:(UserClass*)user
         withStyle:(NSInteger)style
withNavigationController:(UINavigationController*)navigationController
   reuseIdentifier:(NSString*)reuseIdentifier;

@end
