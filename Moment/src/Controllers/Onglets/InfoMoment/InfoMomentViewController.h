//
//  InfoMomentViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MKMapView+ZoomLevel.h"

#import "MomentCoreData+Model.h"
#import "MomentClass.h"
#import "UserCoreData+Model.h"

#import "TTTAttributedLabel.h"
#import "CustomLabel.h"
#import "CustomUIImageView.h"
#import "InfoMomentSeparateurView.h"
#import "CustomUIImageView.h"
#import "CustomExpandingButton.h"
#import "RootOngletsViewController.h"
#import "MDCParallaxView.h"
#import "IgnoreTouchView.h"
#import <MessageUI/MessageUI.h>
#import "GAI.h"

@interface InfoMomentViewController : UIViewController <UIAlertViewDelegate, RNExpandingButtonBarDelegate, UIScrollViewDelegate, OngletViewController, MFMailComposeViewControllerDelegate> {
    
    @private
    NSInteger hauteur;
    
    BOOL expandingBarNeedUpdate;
    enum UserState expandingBarState;
}

@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, strong) UserClass *user;

@property (nonatomic, weak) RootOngletsViewController *rootViewController;
@property (nonatomic, strong) IgnoreTouchView *foregroundView;
@property (nonatomic, strong) MDCParallaxView *parallaxView;

/* ----- Top Image View ----- */
@property (nonatomic, strong) IBOutlet UIView *topImageView;
@property (nonatomic, weak) IBOutlet CustomUIImageView *avatarImage;
@property (nonatomic, weak) IBOutlet UIView *ownerDescripionView;
@property (nonatomic, weak) IBOutlet UILabel *ownerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *hashtagLabel;
@property (nonatomic, weak) IBOutlet CustomUIImageView *momentImageView;
@property (nonatomic, strong) CustomExpandingButton *expandButton;
@property (nonatomic, strong) UIImage *expandingButtonBackgroundMaskImage;

/* ----- Titre View ----- */
@property (nonatomic, strong) IBOutlet UIView *titreView;
@property (nonatomic, strong) TTTAttributedLabel* ttTitreLabel;
@property (nonatomic, weak) IBOutlet CustomLabel* titreLabel;

/* ----- RSVP View ----- */
@property (strong, nonatomic) IBOutlet UIView *rsvpView;
@property (weak, nonatomic) IBOutlet UILabel *rsvpLabel;
@property (weak, nonatomic) IBOutlet UIButton *rsvpMaybeButton;
@property (weak, nonatomic) IBOutlet UIButton *rsvpYesButton;
@property (weak, nonatomic) IBOutlet UIButton *rsvpNoButton;

/* ----- Description View ----- */
@property (nonatomic, strong) IBOutlet UIView *descriptionView;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundDescripionView;
@property (nonatomic) CGFloat descriptionBoxReelHeight;

/* ----- Map View ----- */
@property (nonatomic) CLLocationCoordinate2D coordonateMap;
@property (nonatomic, strong) IBOutlet UIView *generalMapView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) TTTAttributedLabel* ttAdresseLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *adresseLabel;
@property (nonatomic, weak) IBOutlet UIView *nomLieuView;
@property (nonatomic, weak) IBOutlet UILabel *nomLieuLabel;

/* ----- Invités View ----- */
@property (nonatomic, strong) IBOutlet UIView *invitesView;
@property (nonatomic, strong) TTTAttributedLabel* ttNbInvitesLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *nbInvitesLabel;
@property (nonatomic, weak) IBOutlet UILabel *nbInvitesValidesLabel;
@property (nonatomic, weak) IBOutlet UILabel *nbInvitesRefusesLabel;
@property (nonatomic, weak) IBOutlet UIButton *inviteButton;
@property (nonatomic, weak) IBOutlet UIView *invitesBackgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *valideImageView, *refusedImageView;
@property (weak, nonatomic) IBOutlet UIButton *seeInviteButton;

/* ----- Date View ----- */
@property (nonatomic, strong) IBOutlet UIView *dateView;
@property (nonatomic, strong) TTTAttributedLabel *ttDateDebutLabel, *ttHeureDebutLabel;
@property (nonatomic, strong) TTTAttributedLabel *ttDateFinLabel, *ttHeureFinLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *dateDebutLabel, *heureDebutLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *dateFinLabel, *heureFinLabel;

/* ----- Photos View ----- */
@property (nonatomic, strong) IBOutlet UIView *photosView;
@property (nonatomic, weak) IBOutlet UILabel *nbPhotosLabel;
@property (strong, nonatomic) IBOutlet UIView *addPhotosView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotosButton;

/* ----- Badges View ----- */
@property (nonatomic, strong) IBOutlet UIView *badgesView;
@property (nonatomic, weak) IBOutlet UILabel *nbBadgesLabel;
@property (strong, nonatomic) IBOutletCollection(CustomUIImageView) NSArray *photosImageView;

/* ----- Metro View ----- */
@property (nonatomic, strong) IBOutlet UIView *metroView;
@property (nonatomic, strong) TTTAttributedLabel *ttMetroLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *metroLabel;

/* ----- InfoLieu View ----- */
@property (nonatomic, strong) IBOutlet UIView *infoLieuView;
@property (nonatomic, strong) TTTAttributedLabel *ttInfoLieuLabel;
@property (nonatomic, weak) IBOutlet CustomLabel *infoLieuLabel;

/* ----- Cagnotte View ----- */
@property (nonatomic, strong) IBOutlet UIView *cagnotteView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *comingSoonCagnotteLabels;
@property (weak, nonatomic) IBOutlet UILabel *cagnotteCourseLabel;
@property (weak, nonatomic) IBOutlet UILabel *cagnotteCagnotteLabel;
@property (weak, nonatomic) IBOutlet UILabel *cagnotteCompteLabel;

/* ------ Partage View ----- */
@property (nonatomic, strong) IBOutlet UIView *partageView;

/* ------ Suppression View ----- */
@property (strong, nonatomic) IBOutlet UIView *managementView;
@property (weak, nonatomic) IBOutlet UIButton *manageMomentButton;
@property (strong, nonatomic) UIAlertView *deleteMoment;
@property (strong, nonatomic) UIAlertView *removeGuest;

@property (strong, nonatomic) NSNumber *nb_photos_in_moment;


// ------------------- METHODES ------------------------ //
- (id)initWithMoment:(MomentClass*)moment withRootViewController:(RootOngletsViewController*)rootViewController;

- (IBAction)clicInviteButton;
- (IBAction)clicSeeInviteButton;
- (void)reloadData;
- (IBAction)clicRSVPButton:(UIButton*)sender;

- (IBAction)clicShareMail;
- (IBAction)clicShareLink;
- (IBAction)clicShareFacebook;
- (IBAction)clicShareTwitter;
//- (IBAction)clicShareInstagram;

- (IBAction)clicCagnotteButton;
//- (IBAction)clicCoursesButton;
- (IBAction)clicComptesButton;
- (IBAction)clicFeedBackButton;

// Google Analytics
- (void)sendGoogleAnalyticsView;

@end
