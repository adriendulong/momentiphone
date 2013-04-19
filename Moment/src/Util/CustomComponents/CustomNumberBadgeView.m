//
//  CustomNumberBadgeView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 11/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomNumberBadgeView.h"
#import "PushNotificationManager.h"
#import "Config.h"

@implementation CustomNumberBadgeView

@synthesize delegate = _delegate;

- (id)initWithDDMenuDelegate:(DDMenuController*)delegate
{
    self = [super init];
    if(self) {
        
        // Listen to notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifChangeNumber:)
                                                     name:kNotificationChangeBadgeNumber
                                                   object:nil];
        
        // Init
        self.hideWhenZero = YES;
        self.clipsToBounds = NO;
        self.font = [UIFont boldSystemFontOfSize:10];
        self.strokeWidth = 1.2;
        self.delegate = delegate;
        
        // Tap
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicSuperViewButton)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)notifChangeNumber:(NSNotification*)notification {
    self.value = [notification.object intValue];
    self.frame = CGRectMake(self.superview.frame.size.width - self.badgeSize.width, 0, self.badgeSize.width + 7, self.badgeSize.height + 7);
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationChangeBadgeNumber object:nil];
}

- (void)clicSuperViewButton {
    [self.delegate showLeftController:YES];
}

@end
