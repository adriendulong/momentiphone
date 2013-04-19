//
//  CreationHomeViewController.h
//  Moment
//
//  Created by Charlie FANCELLI on 21/09/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "CreationFicheViewController.h"

#import "UserCoreData.h"
#import "FacebookEvent.h"

@interface CreationHomeViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) UIViewController <TimeLineDelegate> *timeLineViewContoller;
@property (nonatomic, strong) UserClass *user;

@property (nonatomic, weak) IBOutlet TPKeyboardAvoidingScrollView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *nomTextField;

- (id)initWithUser:(UserClass*)user withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine;

@end
