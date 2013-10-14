//
//  ChatTableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "CustomAGMedallionView.h"
#import "ChatMessageCoreData+Model.h"

@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) ChatMessage *message;

@property (nonatomic, retain) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet UIImageView *messageBackgroudView;
@property (nonatomic, weak) IBOutlet UILabel *texteMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *nomLabel;
@property (nonatomic, weak) IBOutlet UILabel *jourLabel;
@property (nonatomic, weak) IBOutlet UILabel *heureLabel;

- (id)initWithChatMessage:(ChatMessage*)message
        withDateFormatter:(NSDateFormatter*)dateFormatter
               withHeight:(CGFloat)height
          reuseIdentifier:(NSString*)reuseIdentifier
     navigationController:(UINavigationController*)navController;

@end
