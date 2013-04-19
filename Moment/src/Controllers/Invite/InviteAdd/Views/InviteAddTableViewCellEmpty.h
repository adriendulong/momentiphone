//
//  InviteAddTableViewCellEmpty.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteAddTableViewCellEmpty : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *noResultsLabel;

- (id)initWithSize:(CGFloat)height reuseIdentifier:(NSString*)reuseIdentifier;

@end
