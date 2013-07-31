//
//  RootOngletsViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimeLineViewController.h"
#import "MomentClass.h"
#import "CMPopTipView.h"

enum OngletRank {
    OngletPhoto = 0,
    OngletInfoMoment = 1,
    OngletChat = 2
};

@class InfoMomentViewController, PhotoViewController, ChatViewController;

@interface RootOngletsViewController : UIViewController <UIScrollViewDelegate, CMPopTipViewDelegate> {
    @private
    NSInteger viewHeight;
}

@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, weak) UserClass *user;
@property (nonatomic) enum OngletRank selectedOnglet;

@property (nonatomic, weak) IBOutlet UIView *navBarRigthButtonsView;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, weak) IBOutlet UIButton *chatButton;
@property (nonatomic, weak) IBOutlet UIButton *photoButton;

@property (nonatomic, strong) UIViewController <TimeLineDelegate> *timeLine;
@property (nonatomic, strong) InfoMomentViewController *infoMomentViewController;
@property (nonatomic, strong) PhotoViewController *photoViewController;
@property (nonatomic, strong) ChatViewController *chatViewController;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL shouldShowInviteViewController;

@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) CMPopTipView *roundRectButtonPopTipView;

@property (nonatomic) BOOL poptipPhotos, poptipChat;

- (id)initWithMoment:(MomentClass*)moment
          withOnglet:(enum OngletRank)onglet
        withTimeLine:(UIViewController <TimeLineDelegate>*)timeLine;

- (void)addAndScrollToOnglet:(enum OngletRank)onglet;

@end

@protocol OngletViewController <NSObject>
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, weak) RootOngletsViewController *rootViewController;
@end

#import "InfoMomentViewController.h"
#import "PhotoViewController.h"
#import "ChatViewController.h"
