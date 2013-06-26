//
//  ProfilViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 04/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ProfilViewController.h"
#import "Config.h"
#import "CropImageUtility.h"
#import "UserClass+Server.h"
#import "MomentClass+Server.h"
#import "ModifierUserViewController.h"

enum ProfilOnglet {
    ProfilOngletMoments = 0,
    ProfilOngletPhotos = 1,
    ProfilOngletFollow = 2,
    ProfilOngletFollower = 3
    };

@interface ProfilViewController () {
    @private
    enum ProfilOnglet selectedOnglet;
    CGRect insertionFrame;
    enum FollowButtonState headFollowButtonState;
}

@end

@implementation ProfilViewController

@synthesize user = _user;
@synthesize timeLineViewController = _timeLineViewController, photoViewController = _photoViewController;
@synthesize followTableViewController = _followTableViewController, followerTableViewController = _followerTableViewController;

@synthesize contentView = _contentView, leftBarView = _leftBarView, buttonsView = _buttonsView;
@synthesize backgroundContentView = _backgroundContentView;
@synthesize momentButton = _momentButton, momentLabel = _momentLabel;
@synthesize photoButton = _photoButton, photoLabel = _photoLabel;
@synthesize followButton = _followButton, followLabel = _followLabel;
@synthesize followerButton = _followerButton, followerLabel = _followerLabel;
@synthesize titreLabel = _titreLabel, descriptionLabel = _descriptionLabel;
@synthesize headFollowButton = _headFollowButton, headFollowLabel = _headFollowLabel, pictureView = _pictureView;
@synthesize acceptFollowBarView = _acceptFollowBarView, acceptFollowBarNameLabel = _acceptFollowBarNameLabel, acceptFollowBarInfoLabel = _acceptFollowBarInfoLabel;

#pragma mark - Init

- (id)initWithUser:(UserClass *)user
{
    self = [super initWithNibName:@"ProfilViewController" bundle:nil];
    if(self) {
        
        self.user = user;
        
        // Si les informations du user sont incompletes (ou potentiellement incompletes) --> Reload
        if(!(user && user.userId && (user.nom || user.prenom) && user.description && (user.is_followed != nil)))
        {
            if(user.userId) {
                [UserClass getUserFromServerWithId:user.userId.intValue withEnded:^(UserClass *user) {
                    self.user = user;
                    [self reloadData];
                }];
            }
        }
        
        [CustomNavigationController setBackButtonWithViewController:self];
        
        // Observe les modifications de la cover
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifChangeCover:)
                                                     name:kNotificationChangeCover
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifCurrentUserNeedsUpdate:)
                                                     name:kNotificationCurrentUserNeedsUpdate
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifCurrentUserDidUpdate:)
                                                     name:kNotificationCurrentUserDidUpdate
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Profil";
    
    // Navigation bar
    [CustomNavigationController setBackButtonWithViewController:self];
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    frame = self.contentView.frame;
    frame.size.height = self.view.frame.size.height - 100;
    self.contentView.frame = frame;
    frame = self.leftBarView.frame;
    frame.size.height = self.view.frame.size.height - 100;
    self.leftBarView.frame = frame;
    
    // Save
    insertionFrame = CGRectMake(0,0,self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    // Left Bar
    frame = self.leftBarView.frame;
    frame.size.height = self.view.frame.size.height;
    self.leftBarView.frame = frame;
    self.leftBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_bar"]];
    self.leftBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Buttons View
    frame = self.buttonsView.frame;
    frame.origin.x = 0;
    frame.origin.y = 100 + (self.leftBarView.frame.size.height - 100 - frame.size.height)/2.0;
    self.buttonsView.frame = frame;
    [self.leftBarView addSubview:self.buttonsView];
    
    // Boutons
    // Réduire la taille de la police si nécessaire
    // --> Ne semble pas marcher
    /*
    self.momentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.followButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.followerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.photoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    CGFloat minimumFontSize = 9.0f;
    CGFloat defaultFontSize = 13.0f;
    if([[VersionControl sharedInstance] supportIOS6]) {
        self.momentButton.titleLabel.minimumScaleFactor = minimumFontSize/defaultFontSize;
        self.photoButton.titleLabel.minimumScaleFactor = minimumFontSize/defaultFontSize;
        self.followerButton.titleLabel.minimumScaleFactor = minimumFontSize/defaultFontSize;
        self.followButton.titleLabel.minimumScaleFactor = minimumFontSize/defaultFontSize;
    }
    else {
        self.momentButton.titleLabel.minimumFontSize = minimumFontSize;
        self.photoButton.titleLabel.minimumFontSize = minimumFontSize;
        self.followerButton.titleLabel.minimumFontSize = minimumFontSize;
        self.followButton.titleLabel.minimumFontSize = minimumFontSize;
    }
     */
    
    // Follow Bar
    frame = self.acceptFollowBarView.frame;
    frame.origin.y = self.headerView.frame.size.height;
    self.acceptFollowBarView.frame = frame;
    self.acceptFollowBarView.hidden = YES;
    self.acceptFollowBarView.alpha = 0;
    [self.view insertSubview:self.acceptFollowBarView belowSubview:self.headerView];
    self.acceptFollowBarNameLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
    self.acceptFollowBarInfoLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
    self.acceptFollowBarNameLabel.text = self.user.formatedUsername;
    self.acceptFollowBarInfoLabel.text = NSLocalizedString(@"ProfilViewController_AcceptFollowBar_InfoLabel", nil);
    self.acceptFollowBarInfoLabel.adjustsFontSizeToFitWidth = YES;
    
    [self reloadData];
    
    // Default -> Time Line
    selectedOnglet = -1;
    [self clicMoment];
    [self.contentView addSubview:self.timeLineViewController.view];
    
    UserClass *current = [UserCoreData getCurrentUser];
    if( (self.user.state.intValue == UserStateCurrent) || (current && current.userId && ([self.user.userId isEqualToNumber:current.userId])) )
    {
        // Add customView
        UIImage *editImage = [UIImage imageNamed:@"picto_stylo_respond"];
        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,editImage.size.width,editImage.size.height)];
        [editButton setImage:editImage forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(clicEdit) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        
        // Set Nav bar buttons
        self.navigationItem.rightBarButtonItem = barButton;
        
        // Hide Follow Button
        [self showHeadFollowButton:NO];
        self.user.state = @(UserStateCurrent);
    }
    
    //NSLog(@"User = %@", self.user);

}

- (void)clearContentView
{
    NSArray *subviews = self.contentView.subviews;
    for( UIView *v in subviews ) {
        [v removeFromSuperview];
    }
    
    self.backgroundContentView.backgroundColor = [UIColor clearColor];
}

- (void)drawBackground:(UIImage*)background
{
    // Background
    CGRect frame = self.backgroundContentView.frame;
    frame.origin.x = 0; frame.origin.y = 0;
    
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    background = [[Config sharedInstance] scaleAndCropImage:background forSize:frame.size];
    [background drawInRect:frame];
    
    // Ligne Blanche
    CGContextSetStrokeColorWithColor(context, [[[UIColor whiteColor] colorWithAlphaComponent:0.4] CGColor] );
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, (frame.size.width-1)/2.0, 0);
    CGContextAddLineToPoint(context, (frame.size.width-1)/2.0, frame.size.height);
    CGContextSetLineWidth(context, 2);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.backgroundContentView.backgroundColor = [UIColor colorWithPatternImage:image];
}


- (void)showHeadFollowButton:(BOOL)show {
    self.headFollowButton.hidden = !show;
    self.headFollowLabel.hidden = !show;
}

- (void)reloadData
{
    // Update data view core data
    //self.user = [[UserCoreData requestUserAsCoreDataWithUser:self.user] localCopy];
    
    [UserClass getUserFromServerWithId:self.user.userId.intValue withEnded:^(UserClass *user) {
        
        // Update User
        if(user)
            self.user = user;
        
        // Load TimeLine
        [MomentClass getMomentsForUser:self.user withEnded:^(NSArray *moments) {
            if(moments) {
                [self.timeLineViewController reloadDataWithMoments:moments];
            }
        }];
        
        // Titre
        self.titreLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.prenom?[self.user.prenom capitalizedString]:@"", self.user.nom?[self.user.nom capitalizedString]:@""];
        self.titreLabel.font = [[Config sharedInstance] defaultFontWithSize:14];
        
        // Description
        self.descriptionLabel.text = self.user.descriptionString ?: @"";
        
        // Photo
        UIImage *picture = self.user.uimage?self.user.uimage : [UIImage imageNamed:@"profil_defaut"];
        UIImage *cropped = [CropImageUtility cropImage:picture intoCircle:CircleSizeProfil];
        if(!self.user.uimage) {
            [self.pictureView setImage:nil imageString:self.user.imageString placeHolder:cropped withSaveBlock:^(UIImage *image) {
                
                //self.user.uimage = image;
                UIImage *cropped = [CropImageUtility cropImage:image intoCircle:CircleSizeProfil];
                self.pictureView.image = cropped;
                
                /*
                 UserCoreData *coredata = [UserCoreData requestUserAsCoreDataWithUser:self.user];
                 if(coredata)
                 {
                 [coredata setDataImageWithUIImage:image];
                 [[Config sharedInstance] saveContext];
                 }
                 */
                
            }];
        }
        else
            self.pictureView.image = cropped;
        
        // Nb Followers
        NSString *texte = NSLocalizedString(@"ProfilViewController_FollowersLabel", nil);
        self.followerLabel.text = (self.user.nb_followers.intValue > 0)? [NSString stringWithFormat:@"%@\n%@", self.user.nb_followers, texte] : texte;
        
        // Nb Follows
        texte = NSLocalizedString(@"ProfilViewController_FollowLabel", nil);
        self.followLabel.text = (self.user.nb_follows.intValue > 0)? [NSString stringWithFormat:@"%@\n%@", self.user.nb_follows, texte] : texte;
        
        // Nb Moments
        texte = NSLocalizedString(@"ProfilViewController_MomentsLabel", nil);
        self.momentLabel.text = (self.user.nb_moments.intValue > 0)? [NSString stringWithFormat:@"%@\n%@", self.user.nb_moments, texte] : texte;
        
        // Nb Photos
        texte = NSLocalizedString(@"ProfilViewController_PhotosLabel", nil);
        self.photoLabel.text = (self.user.nb_photos.intValue > 0)? [NSString stringWithFormat:@"%@\n%@", self.user.nb_photos, texte] : texte;
        
        // -------- Activer les boutons par défaut --------
        self.momentButton.enabled = YES;
        self.photoButton.enabled = YES;
        self.followButton.enabled = YES;
        self.followerButton.enabled = YES;
        
        // --------- Profil du user connecté ----------
        // -> On ne peut pas se follow soi-même
        if( (self.user.state.intValue == UserStateCurrent) || ([self.user.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]) )
        {
            // Hide Follow Button
            [self showHeadFollowButton:NO];
        }
        else
        {
            //--------------- Cacher Informations ----------------
            BOOL hideInformations = NO;
            
            // -> Blindage
            if( (self.user.privacy == nil) || ![self.user.privacy isKindOfClass:[NSNumber class]]) {
                hideInformations = YES;
            }
            // -> On ne peut pas voir les infos d'un profil qu'on ne follow pas
            // -> On peut voir les infos d'un profil public
            else if(  (self.user.privacy.intValue != UserPrivacyOpen) && !self.user.is_followed.boolValue ) {
                hideInformations = YES;
                
                // -> On ne peut pas follow un profil privé
                if(self.user.privacy.intValue == UserPrivacyClosed)
                {
                    // Hide Follow Button
                    [self showHeadFollowButton:NO];
                }
                
            }
            
            // Cacher infos
            if(hideInformations) {
                [self clearContentView];
                self.momentButton.enabled = NO;
                self.photoButton.enabled = NO;
                self.followButton.enabled = NO;
                self.followerButton.enabled = NO;
            }
        }
        
        //----------- Bouton Head Follow ------------
        enum FollowButtonState state;
        // Waiting for follow request
        if(self.user.request_follower.boolValue) {
            state = FollowButtonStateWaiting;
        }
        else {
            state = (self.user.is_followed.boolValue) ? FollowButtonStateFollowed : FollowButtonStateNotFollowed;
        }
        [self setHeadFollowButtonState:state];

        //----------- Barre de réponse à une demande de Follow ------------
        // -> Si une requete de follow est en attente
        if(self.user.request_follow_me.boolValue)
            [self showAcceptFollowBar:YES];
        else
            [self hideAcceptFollowBar:YES];
        
    }];
    
}

- (void)showAcceptFollowBar:(BOOL)animated {
    
    if( (self.acceptFollowBarView.hidden == YES) && (self.acceptFollowBarView.alpha == 0) )
    {
        self.acceptFollowBarView.hidden = NO;
        
        if(!animated) {
            self.acceptFollowBarView.alpha = 1;
        }
        else {
            CGRect frame = self.acceptFollowBarView.frame;
            frame.origin.y -= frame.size.height;
            self.acceptFollowBarView.frame = frame;
            frame.origin.y += frame.size.height;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.acceptFollowBarView.frame = frame;
                self.acceptFollowBarView.alpha = 1;
            }];
        }
    }
}

- (void)hideAcceptFollowBar:(BOOL)animated {
    
    if( (self.acceptFollowBarView.hidden == NO) && (self.acceptFollowBarView.alpha == 1) )
    {
        if(!animated) {
            self.acceptFollowBarView.alpha = 0;
            self.acceptFollowBarView.hidden = YES;
        }
        else {
            CGRect frame = self.acceptFollowBarView.frame;
            frame.origin.y -= frame.size.height;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.acceptFollowBarView.frame = frame;
                self.acceptFollowBarView.alpha = 0;
            } completion:^(BOOL finished) {
                self.acceptFollowBarView.hidden = YES;
                CGRect frame = self.acceptFollowBarView.frame;
                frame.origin.y += frame.size.height;
                self.acceptFollowBarView.frame = frame;
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setMomentButton:nil];
    [self setMomentLabel:nil];
    [self setPhotoButton:nil];
    [self setPhotoLabel:nil];
    [self setFollowButton:nil];
    [self setFollowLabel:nil];
    [self setFollowerButton:nil];
    [self setFollowerLabel:nil];
    [self setHeadFollowButton:nil];
    [self setTitreLabel:nil];
    [self setDescriptionLabel:nil];
    [self setLeftBarView:nil];
    [self setTimeLineViewController:nil];
    [self setPhotoViewController:nil];
    [self setFollowTableViewController:nil];
    [self setFollowerTableViewController:nil];
    [self setPictureView:nil];
    [self setButtonsView:nil];
    [self setHeadFollowLabel:nil];
    [self setBackgroundContentView:nil];
    [super viewDidUnload];
}

- (void)updateNbPhotos:(NSInteger)nbPhotos
{
    // Nb Photos
    NSString *texte = NSLocalizedString(@"ProfilViewController_PhotosLabel", nil);
    self.photoLabel.text = (self.user.nb_photos.intValue > 0)? [NSString stringWithFormat:@"%@\n%@", self.user.nb_photos, texte] : texte;
}

#pragma mark - Notification

- (void)notifChangeCover:(NSNotification*)notification
{
    if(selectedOnglet == ProfilOngletMoments)
    {
        [self drawBackground:notification.object];
    }
}

- (void)notifCurrentUserNeedsUpdate:(NSNotification*)notification
{
    //NSLog(@"PROFIL RECEIVED NOTIFICATION UPDATE CURRENT USER");
    [UserCoreData getCurrentUser];
}

- (void)notifCurrentUserDidUpdate:(NSNotification*)notifiation
{
    UserClass *current = [UserCoreData getCurrentUser];
    if( (self.user.userId.intValue == UserStateCurrent) || ([self.user.userId isEqualToNumber:current.userId]) ) {
        self.user = current;
        [self reloadData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationChangeCover object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCurrentUserNeedsUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCurrentUserDidUpdate object:nil];
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Profil"
     withAction:action
     withLabel:label
     withValue:value];
}

#pragma mark - Actions 

- (IBAction)clicMoment {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Moments" value:nil];
    
    if(selectedOnglet != ProfilOngletMoments) {
        selectedOnglet = ProfilOngletMoments;
        [self.momentButton setSelected:YES];
        [self.photoButton setSelected:NO];
        [self.followButton setSelected:NO];
        [self.followerButton setSelected:NO];
        
        [self clearContentView];
        [self.contentView addSubview:self.timeLineViewController.view];
        
        [self drawBackground:[Config sharedInstance].coverImage];
    }
}

- (IBAction)clicPhotos {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Photos" value:nil];
    
    if(selectedOnglet != ProfilOngletPhotos) {
        selectedOnglet = ProfilOngletPhotos;
        [self.momentButton setSelected:NO];
        [self.photoButton setSelected:YES];
        [self.followButton setSelected:NO];
        [self.followerButton setSelected:NO];
        
        [self clearContentView];
        [self.contentView addSubview:self.photoViewController.view];
    }
}

- (IBAction)clicFollow {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Liste des Follow" value:nil];
    
    if(selectedOnglet != ProfilOngletFollow) {
        selectedOnglet = ProfilOngletFollow;
        [self.momentButton setSelected:NO];
        [self.photoButton setSelected:NO];
        [self.followButton setSelected:YES];
        [self.followerButton setSelected:NO];
        
        [self.followTableViewController loadUsersListWithEnded:^{
            
        }];
        
        [self clearContentView];
        [self.contentView addSubview:self.followTableViewController.view];
    }
}

- (IBAction)clicFollowers {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Liste des Followers" value:nil];
    
    if(selectedOnglet != ProfilOngletFollower) {
        selectedOnglet = ProfilOngletFollower;
        [self.momentButton setSelected:NO];
        [self.photoButton setSelected:NO];
        [self.followButton setSelected:NO];
        [self.followerButton setSelected:YES];
        
        [self.followerTableViewController loadUsersListWithEnded:^{
            
        }];
        
        [self clearContentView];
        [self.contentView addSubview:self.followerTableViewController.view];
    }
}

- (void)clicEdit {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Editer Profil" value:nil];
    
    ModifierUserViewController *edit = [[ModifierUserViewController alloc] initWithDefaults];
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)setHeadFollowButtonState:(enum FollowButtonState)newState
{
    BOOL selected = (newState != FollowButtonStateNotFollowed);
    self.headFollowLabel.textColor = selected ? [UIColor colorWithHex:0x50504f] : [[Config sharedInstance] orangeColor];
    [self.headFollowButton setSelected:selected];
    
    switch (newState) {
        case FollowButtonStateWaiting:
            self.headFollowLabel.text = NSLocalizedString(@"ProfilViewController_HeadFollowButtonLabel_Waiting", nil);
            break;
            
        case FollowButtonStateFollowed:
            self.headFollowLabel.text = NSLocalizedString(@"ProfilViewController_HeadFollowButtonLabel_isFollowed", nil);
            break;
            
        case FollowButtonStateNotFollowed:
            self.headFollowLabel.text = NSLocalizedString(@"ProfilViewController_HeadFollowButtonLabel_Follow", nil);
            break;
    }
        
    headFollowButtonState = newState;
}

- (IBAction)clicHeadFollow
{
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Bouton pour Follow" value:nil];
    
    // Requete pas encore envoyée
    if( (headFollowButtonState != FollowButtonStateWaiting) && (!self.user.request_follower.boolValue) )
    {
        
        // Si on veut unfollow -> AlertView pour prévenir
        if(headFollowButtonState == FollowButtonStateFollowed) {
            
            // Si c'est un profil public
            if(self.user.privacy.intValue == UserPrivacyOpen) {
                [[[UIAlertView alloc]
                  initWithTitle:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_Title", nil)
                  message:NSLocalizedString(@"ProfilViewController_Unfollow_Public_AlertView_Message", nil)
                  delegate:self
                  cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                  otherButtonTitles:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_ConfirmButton", nil), nil]
                 show];
            }
            else {
                [[[UIAlertView alloc]
                  initWithTitle:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_Title", nil)
                  message:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_Message", nil)
                  delegate:self
                  cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                  otherButtonTitles:NSLocalizedString(@"ProfilViewController_Unfollow_AlertView_ConfirmButton", nil), nil]
                 show];
            }
        }
        else {
            [self sendToggleFollowRequest];
        }

    }
}

- (void)sendToggleFollowRequest {
    
    enum FollowButtonState previousState = headFollowButtonState;
    
    [self setHeadFollowButtonState:(!self.headFollowButton.selected)? FollowButtonStateFollowed : FollowButtonStateNotFollowed];
    
    // Follow / UnFollow user selectionné
    [self.user toggleFollowWithEnded:^(BOOL success, BOOL waitForResponse) {
        
        // Success
        if(success) {
            
            enum FollowButtonState newState = waitForResponse ? FollowButtonStateWaiting : ((previousState == FollowButtonStateFollowed)? FollowButtonStateNotFollowed : FollowButtonStateFollowed );
            
            [self setHeadFollowButtonState:newState];
            
            // Update Content
            [self.followerTableViewController loadUsersList];
            [self reloadData];
            
        }
        // Si il y a eu un erreur
        else {
            
            // On remet le bouton dans le bonne état
            [self setHeadFollowButtonState:previousState];
            
            // On informe l'utilisateur
            [[MTStatusBarOverlay sharedInstance] postImmediateErrorMessage:NSLocalizedString(@"FollowTableViewController_AddFollow_ErrorMessage", nil)
                                                                  duration:1
                                                                  animated:YES];
            
        }
    }];
}

- (IBAction)clicAcceptFollow {
    
    [UserClass acceptFollowOfUser:self.user withEnded:^(BOOL success) {
        if(success) {
            // Hide Accept Follow Bar
            [self hideAcceptFollowBar:YES];
            
            // Informer User
            [[MTStatusBarOverlay sharedInstance]
             postFinishMessage:NSLocalizedString(@"ProfilViewController_AcceptFollow_Message", nil)
             duration:1];
            
            // Update Content
            [self.followTableViewController loadUsersList];
            [self reloadData];
            
            // Default -> Time Line
            selectedOnglet = -1;
            [self clicMoment];
            [self.contentView addSubview:self.timeLineViewController.view];
        }
        else {
            [[MTStatusBarOverlay sharedInstance]
             postImmediateErrorMessage:NSLocalizedString(@"Error_Classic", nil)
             duration:1 animated:YES];
        }
    }];
}

- (IBAction)clicRefuseFollow {
    
    [UserClass refuseFollowOfUser:self.user withEnded:^(BOOL success) {
        if(success) {
            // Hide Accept Follow Bar
            [self hideAcceptFollowBar:YES];
            
            // Informer User
            [[MTStatusBarOverlay sharedInstance]
             postFinishMessage:NSLocalizedString(@"ProfilViewController_RefuseFollow_Message", nil)
             duration:1];
            
        }
        else {
            [[MTStatusBarOverlay sharedInstance]
             postImmediateErrorMessage:NSLocalizedString(@"Error_Classic", nil)
             duration:1 animated:YES];
        }
    }];
}

#pragma mark - Getters & Setters

- (TimeLineViewController*)timeLineViewController {
    if(!_timeLineViewController) {

        _timeLineViewController = [[TimeLineViewController alloc] initWithMoments:@[]
                                                                        withStyle:TimeLineStyleProfil
                                                                         withUser:self.user
                                                                         withSize:self.contentView.frame.size
                                                           withRootViewController:(RootTimeLineViewController*)self
                                                              shouldReloadMoments:YES];
        
        _timeLineViewController.view.frame = insertionFrame;
    }
    return _timeLineViewController;
}

- (PhotoViewController*)photoViewController {
    if(!_photoViewController) {
        _photoViewController = [[PhotoViewController alloc]
                                initWithUser:self.user
                                withRootViewController:self
                                withSize:self.contentView.frame.size];
        _photoViewController.view.frame = insertionFrame;
        [_photoViewController.view setNeedsDisplay];
    }
    return _photoViewController;
}

- (FollowTableViewController*)followTableViewController {
    if(!_followTableViewController) {
        
        _followTableViewController = [[FollowTableViewController alloc]
                                      initWithOwner:self.user
                                      withFrame:insertionFrame
                                      withStyle:FollowTableViewStyleFollow
                                      navigationController:self.navigationController];
        
    }
    return _followTableViewController;
}

- (FollowTableViewController*)followerTableViewController {
    if(!_followerTableViewController) {
                
        _followerTableViewController = [[FollowTableViewController alloc]
                                        initWithOwner:self.user
                                        withFrame:insertionFrame
                                        withStyle:FollowTableViewStyleFollower
                                        navigationController:self.navigationController];

    }
    return _followerTableViewController;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Confirmation de la demande de unfollow
    if(buttonIndex == 1)
    {
        [self sendToggleFollowRequest];
    }
}

@end
