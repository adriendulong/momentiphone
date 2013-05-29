//
//  EventMissingViewController.h
//  Moment
//
//  Created by SkeletonGamer on 27/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface EventMissingViewController : UIViewController <MFMailComposeViewControllerDelegate>

// --- Properties ---

@property (weak, nonatomic) DDMenuController *delegate;

// --- Methodes ---

- (id)initWithDDMenuDelegate:(DDMenuController*)delegate;

@end
