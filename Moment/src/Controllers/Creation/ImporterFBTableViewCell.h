//
//  ImporterFBTableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIImageView.h"
#import "FacebookEvent.h"

@interface ImporterFBTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet CustomUIImageView *coverView;
@property (nonatomic, weak) IBOutlet UIImageView *buttonView;
@property (nonatomic, weak) IBOutlet UIView *backgroundColorView;

@property (nonatomic, weak) IBOutlet UILabel *titreLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *creeParLabel;
@property (nonatomic, weak) IBOutlet UILabel *ownerLabel;
@property (nonatomic, weak) IBOutlet UILabel *alreadyOnMomentLabel;

- (id)initWithFacebookEvent:(FacebookEvent*)event withIndex:(NSInteger)index reuseIdentifier:(NSString*)reuseIdentifier;

@end
