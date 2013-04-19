//
//  ChatTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "Config.h"
#import "UserCoreData.h"

@implementation ChatTableViewCell

- (id)initWithChatMessage:(ChatMessageCoreData*)message withDateFormatter:(NSDateFormatter*)dateFormatter
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChatTableViewCell"];
    if(self) {
        
        // Data
        self.message = message;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"ChatTableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Config
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:12];
        
        // TexteMessage
        self.texteMessageLabel.text = message.message;
        self.texteMessageLabel.font = font;
        
        // Date
        dateFormatter.dateFormat = @"HH:mm";
        self.heureLabel.text = [dateFormatter stringFromDate:message.date];
        self.heureLabel.font = font;
        
        self.nomJourLabel.text = [NSString stringWithFormat:@"%@ %@.", message.user.prenom, [message.user.nom substringToIndex:1] ];
        self.nomJourLabel.font = font;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
