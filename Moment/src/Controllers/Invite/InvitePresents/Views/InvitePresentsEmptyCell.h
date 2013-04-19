//
//  InvitePresentsEmptyCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitePresentsEmptyCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *emptyLabel;

- (id)initWithSize:(CGFloat)height reuseIdentifier:(NSString*)reuseIdentifier;

@end
