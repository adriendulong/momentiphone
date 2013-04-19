//
//  ChatTableViewRightCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "CustomAGMedallionView.h"
#import "ChatMessageCoreData+Model.h"

@interface ChatTableViewRightCell : UITableViewCell

@property (nonatomic, strong) ChatMessageCoreData *message;

@property (nonatomic, weak) IBOutlet CustomAGMedallionView *medallion;
@property (nonatomic, weak) IBOutlet UIImageView *messageBackgroudView;
@property (nonatomic, weak) IBOutlet UILabel *texteMessageLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttTexteMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *nomJourLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttNomJourLabel;
@property (nonatomic, weak) IBOutlet UILabel *heureLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttHeureLabel;

- (id)initWithChatMessage:(ChatMessageCoreData*)message withDateFormatter:(NSDateFormatter*)dateFormatter;

@end
