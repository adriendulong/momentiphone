//
//  ProfilViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 04/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLineViewController.h"
#import "PhotoViewController.h"
#import "FollowTableViewController.h"
#import "CustomUIImageView.h"

enum FollowButtonState {
    FollowButtonStateNotFollowed = 0,
    FollowButtonStateFollowed = 1,
    FollowButtonStateWaiting = 2
};

@interface ProfilViewController : UIViewController

@property (strong, nonatomic) UserClass *user;

@property (strong, nonatomic) TimeLineViewController *timeLineViewController;
@property (strong, nonatomic) PhotoViewController *photoViewController;
@property (strong, nonatomic) FollowTableViewController *followTableViewController;
@property (strong, nonatomic) FollowTableViewController *followerTableViewController;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *leftBarView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *backgroundContentView;

@property (weak, nonatomic) IBOutlet UIButton *momentButton;
@property (weak, nonatomic) IBOutlet UILabel *momentLabel;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UIButton *followerButton;
@property (weak, nonatomic) IBOutlet UILabel *followerLabel;

@property (weak, nonatomic) IBOutlet UILabel *titreLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *headFollowButton;
@property (weak, nonatomic) IBOutlet UILabel *headFollowLabel;
@property (weak, nonatomic) IBOutlet CustomUIImageView *pictureView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *acceptFollowBarView;
@property (weak, nonatomic) IBOutlet UILabel *acceptFollowBarNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *acceptFollowBarInfoLabel;

// Init
- (id)initWithUser:(UserClass*)user;

- (void)updateNbPhotos:(NSInteger)nbPhotos;

// Actions
- (IBAction)clicMoment;
- (IBAction)clicPhotos;
- (IBAction)clicFollow;
- (IBAction)clicFollowers;
- (IBAction)clicHeadFollow;
- (IBAction)clicAcceptFollow;
- (IBAction)clicRefuseFollow;

@end
