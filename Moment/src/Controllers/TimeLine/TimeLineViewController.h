//
//  TimeLineViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MomentClass.h"
#import "UserCoreData.h"

// Protocol
@class RootOngletsViewController;
@protocol TimeLineDelegate <NSObject>

@property NSInteger selectedIndex;
@property CGSize size;
@property (nonatomic, weak) UINavigationController *navController;
@property (nonatomic, strong) RootOngletsViewController *rootOngletsViewController;

// Update TimeLine
- (void)updateSelectedMoment:(MomentClass*)moment atRow:(NSInteger)row;
- (void)reloadDataWithWaitUntilFinished:(BOOL)waitUntilFinished withEnded:(void (^) (BOOL success))block;
- (void)reloadData;
- (void)reloadMomentPicture:(MomentClass*)momentParam;

// Redirection Onglets
- (void)showInfoMomentView:(MomentClass*)moment;
- (void)showPhotoView:(MomentClass*)moment;
- (void)showTchatView:(MomentClass*)moment;

// Modification Model
- (void)deleteMoment:(MomentClass*)moment;

// Redirection Profonde
- (void)showInviteViewControllerWithMoment:(MomentClass*)moment;
- (BOOL)hasMoment:(MomentClass*)moment;

@end


//#import "TimeScroller.h"
#import "CustomTimeScroller.h"
#import "TimeLineCell.h"
#import "TimeLineDeveloppedCell.h"

#import "CreationHomeViewController.h"
#import "RootOngletsViewController.h"
#import "TTTAttributedLabel.h"
#import "GAI.h"

enum TimeLineStyle {
    TimeLineStyleComplete = 0,
    TimeLineStyleProfil = 1
};

@class RootTimeLineViewController;

// Classe
@interface TimeLineViewController : UIViewController <TimeLineDelegate, CustomTimeScrollerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) RootOngletsViewController *rootOngletsViewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) enum TimeLineStyle timeLineStyle;
@property (nonatomic, strong) RootTimeLineViewController *rootViewController;
@property (nonatomic, weak) UINavigationController *navController;

// Model
@property (nonatomic, strong) NSArray *moments;
@property (nonatomic, strong) UserClass *user;
@property NSInteger selectedIndex;
@property CGSize size;
@property (nonatomic, strong) MomentClass *selectedMoment;
@property (nonatomic) BOOL shoulShowInviteView;

// Overlay views
@property (nonatomic, weak) IBOutlet UIView *bandeauTitre;
@property (nonatomic) NSInteger bandeauIndex;
@property (nonatomic, weak) IBOutlet CustomLabel *nomMomentLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *nomOwnerLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *fullDateLabel;
@property (nonatomic, strong) TTTAttributedLabel *nomMomentTTLabel;
/*
@property (nonatomic, strong) TTTAttributedLabel *nomOwnerTTLabel;
@property (nonatomic, strong) TTTAttributedLabel *fullDateTTLabel;
 */
@property (nonatomic, strong) UILabel *nomOwnerTTLabel;
@property (nonatomic, strong) UILabel *fullDateTTLabel;
//
@property (nonatomic, strong) CustomTimeScroller *timeScroller;
@property (nonatomic, weak) IBOutlet UIButton *B2PButton;

@property (weak, nonatomic) IBOutlet UILabel *echelleFuturLabel;
@property (weak, nonatomic) IBOutlet UILabel *echelleTodayLabel;
@property (weak, nonatomic) IBOutlet UILabel *echellePasseLabel;

@property (strong, nonatomic) UIImageView *overlay;
@property (strong, nonatomic) UIButton *overlay_button;


// Methodes

- (id)initWithMoments:(NSArray*)momentsParam
            withStyle:(enum TimeLineStyle)style
             withUser:(UserClass*)user
             withSize:(CGSize)size
withRootViewController:(RootTimeLineViewController*)rootViewController
  shouldReloadMoments:(BOOL)reloadMoments
shouldLoadEventsFromFacebook:(BOOL)loadEvents;

- (void)updateSelectedMoment:(MomentClass*)moment atRow:(NSInteger)row;
- (void)reloadData;
- (void)reloadDataWithMoments:(NSArray*)moments;
- (void)reloadMomentPicture:(MomentClass*)momentParam;

- (void)showInfoMomentView:(MomentClass*)moment;
- (void)showPhotoView:(MomentClass*)moment;
- (void)showTchatView:(MomentClass*)moment;
- (void)deleteMoment:(MomentClass*)moment;

- (IBAction)clicButtonClock;

// Google Analytics
+ (void)sendGoogleAnalyticsView ;

@end

#import "RootTimeLineViewController.h"
