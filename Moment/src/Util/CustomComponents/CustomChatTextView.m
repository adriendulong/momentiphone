//
//  CustomChatTextView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomChatTextView.h"
#import "Config.h"

@implementation CustomChatTextView

- (void)setup {
    [self setPlaceholder:NSLocalizedString(@"ChatViewController_SendBoxView_placeHolder", nil)];
    [self setPlaceholderColor:[Config sharedInstance].orangeColor];
    [self setBackgroundImage:[UIImage imageNamed:@"chat_textfield_bg"]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

@end
