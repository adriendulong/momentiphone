//
//  BigPhotoViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MomentCoreData+Model.h"
#import "CustomUIImageView.h"
#import "UserClass.h"
#import "GAITrackedViewController.h"
#import <MessageUI/MessageUI.h>
#import "AGPhotoBrowserView.h"

@interface BigPhotoViewController : GAITrackedViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, AGPhotoBrowserDelegate, AGPhotoBrowserDataSource>

@property (nonatomic, strong) UserClass *currentUser; // [UserCoreData getCurrentUser]
@property (nonatomic, strong) UserClass *user; // User owner de toutes les photos (util si on est dans le profil)
@property (nonatomic, strong) MomentClass *moment; // Moment qui a toutes les photos (util son on est dans les onglets)
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, weak) PhotoCollectionViewController *delegate;
@property (nonatomic, strong) AGPhotoBrowserView *browserView;

@property (weak, nonatomic) IBOutlet UIView *generalPopupView;
@property (weak, nonatomic) IBOutlet UIView *blackFilterView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImage *backgroundImage;

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic) NSInteger selectedIndex;

@property (weak, nonatomic) IBOutlet UILabel *auteurLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *topPhotoView;
@property (weak, nonatomic) IBOutlet UIView *bottomPhotoView;
@property (weak, nonatomic) IBOutlet UIView *centerPhotoView;

@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *likeNumberLabel;

@property(nonatomic, strong) UIView *whiteBackgroundStatusBar;

// Init from onglet
- (id)initWithMoment:(MomentClass*)moment
          withPhotos:(NSMutableArray*)photos
withRootViewController:(UIViewController *)rootViewController
        withDelegate:(PhotoCollectionViewController*)photoViewController;

// Init From Profil
- (id)initWithUser:(UserClass*)user
        withPhotos:(NSMutableArray*)photos
withRootViewController:(UIViewController*)rootViewController
      withDelegate:(PhotoCollectionViewController*)photoViewController;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated scroll:(BOOL)scroll;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)showViewAtIndex:(NSInteger)index fromParent:(BOOL)fromParent;
- (void)updateBackground;

- (IBAction)clicClose;
- (IBAction)clicNext;
- (IBAction)clicPrevious;

- (IBAction)clicTrash;
- (IBAction)clicLike;
- (IBAction)clicFacebook;
- (IBAction)clicTwitter;
- (IBAction)clicDownload;

@end
