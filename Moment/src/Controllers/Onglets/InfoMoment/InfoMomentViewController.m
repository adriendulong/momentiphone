//
//  InfoMomentViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "InfoMomentViewController.h"
#import "Config.h"
#import "NSMutableAttributedString+FontAndTextColor.h"
#import "VersionControl.h"
#import "InvitePresentsViewController.h"
#import "InviteAddViewController.h"

#import "UserCoreData+Model.h"
#import "MomentClass+Server.h"
#import "CalendarManager.h"
#import "Photos.h"
#import "ProfilViewController.h"
#import "AFNetworking.h"
#import "AFMomentAPIClient.h"
#import "CropImageUtility.h"

#import "Cagnotte1ViewController.h"

#import "DEFacebookComposeViewController.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "FacebookManager.h"
#import "MomentClass+Server.h"

// Font Sizes
enum InfoMomentFontSize {
    InfoMomentFontSizeBig = 18,
    InfoMomentFontSizeMedium = 14,
    InfoMomentFontSizeLittle = 12
    };

@implementation InfoMomentViewController {
    @private
    BOOL firstLoad;
    UIButton *seeMoreButton;
}

static CGFloat DescriptionBoxHeightMax = 100;

@synthesize moment = _moment, user = _user;

@synthesize rootViewController = _rootViewController, foregroundView = _foregroundView, parallaxView = _parallaxView;

@synthesize topImageView = _topImageView, ownerDescripionView = _ownerNameView;
@synthesize ownerNameLabel = _ownerNameLabel, hashtagLabel = _hashtagLabel, momentImageView = _momentImageView;
@synthesize expandButton = _expandButton, expandingButtonBackgroundMaskImage = _expandingButtonBackgroundMaskImage;

@synthesize titreView = _titreView, titreLabel = _titreLabel, ttTitreLabel = _ttTitreLabel;

@synthesize descriptionView = _descriptionView;
@synthesize descriptionLabel = _descriptionLabel, backgroundDescripionView = _backgroundDescripionView;
@synthesize descriptionBoxReelHeight = _descriptionBoxReelHeight;

@synthesize coordonateMap = _coordonateMap, generalMapView = _generalMapView, mapView = _mapView;
@synthesize ttAdresseLabel = _ttAdresseLabel, adresseLabel = _adresseLabel, nomLieuView = _nomLieuView;
@synthesize nomLieuLabel = _nomLieuLabel;

@synthesize invitesView = _invitesView, ttNbInvitesLabel = _ttNbInvitesLabel, nbInvitesLabel = _nbInvitesLabel;
@synthesize nbInvitesRefusesLabel = _nbInvitesRefusesLabel, nbInvitesValidesLabel = _nbInvitesValidesLabel;
@synthesize inviteButton = _inviteButton, invitesBackgroundView = _invitesBackgroundView;
@synthesize valideImageView = _valideImageView, refusedImageView = _refusedImageView;

@synthesize dateView = _dateView, ttDateDebutLabel = _ttDateDebutLabel, ttDateFinLabel = _ttDateFinLabel;
@synthesize ttHeureDebutLabel = _ttHeureDebutLabel,  ttHeureFinLabel = _ttHeureFinLabel;
@synthesize dateDebutLabel = _dateDebutLabel, heureDebutLabel = _heureDebutLabel;
@synthesize dateFinLabel = _dateFinLabel, heureFinLabel = _heureFinLabel;

@synthesize photosView = _photosView, nbPhotosLabel = _nbPhotosLabel, photosImageView = _photosImageView;

@synthesize badgesView = _badgesView, nbBadgesLabel = _nbBadgesLabel;

@synthesize metroView = _metroView, ttMetroLabel = _ttMetroLabel, metroLabel = _metroLabel;

@synthesize infoLieuView = _infoLieuView, ttInfoLieuLabel = _ttInfoLieuLabel, infoLieuLabel = _infoLieuLabel;

@synthesize cagnotteView = _cagnotteView;


#pragma mark - Init

- (id)initWithMoment:(MomentClass*)moment withRootViewController:(RootOngletsViewController*)rootViewController {
    
    self = [super initWithNibName:@"InfoMomentViewController" bundle:nil];
    if(self) {
        
        self.moment = moment;
        self.user = [UserCoreData getCurrentUser];
        self.rootViewController = rootViewController;
        
        expandingBarNeedUpdate = NO;
        expandingBarState = moment.state.intValue;
        
        // First Load constance
        firstLoad = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Util

- (void)addSubviewAtAutomaticPosition:(UIView*)view 
{
    CGRect frame = view.frame;
    frame.origin.x = 0;
    frame.origin.y = hauteur;
    view.frame = frame;
    
    hauteur += frame.size.height + 5;
    frame = self.foregroundView.frame;
    frame.size.height = hauteur;
    self.foregroundView.frame = frame;
    
    [self.foregroundView addSubview:view];
}

- (NSDictionary*)formatedStringFromDate:(NSDate*)date
{
    if(date)
    {
        // Formateur
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        
        // Jour
        [formater setDateFormat:@"EEEE"];
        NSString *jour = [[formater stringFromDate:date] capitalizedString];
        
        // Numéro
        [formater setDateFormat:@"dd"];
        int val = [[formater stringFromDate:date] intValue];
        NSString *numero = [NSString stringWithFormat:@"%d", val];
        
        // Mois
        [formater setDateFormat:@"MMMM"];
        NSString *mois = [[formater stringFromDate:date] capitalizedString];
        
        return @{
                 @"jour" : jour,
                 @"numero" : numero,
                 @"mois" : mois
                 };
    }
    return nil;
}

- (NSAttributedString*)createClassicAttributedStringForDate:(NSDate*)date
{
    if(date)
    {
        // Ressources
        UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:12];
        UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:10];
        
        NSDictionary *formats = [self formatedStringFromDate:date];
        
        NSString *jour = formats[@"jour"];
        NSString *numero = formats[@"numero"];
        NSString *mois = formats[@"mois"];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ %@ %@", jour, numero, mois] ];
        
        int taille = 0;
        // 1er lettre jour
        [attributedString setFont:bigFont range:NSMakeRange(0, 1)];
        // Reste Jour
        taille = [jour length]-1;
        [attributedString setFont:smallFont range:NSMakeRange(1, taille)];
        
        // Numéro + 1er lettre mois
        [attributedString setFont:bigFont range:NSMakeRange(taille+1, [numero length] + 3 )];
        
        // Reste Mois
        taille = taille + 1 + [numero length] + 3;
        [attributedString setFont:smallFont range:NSMakeRange(taille, [mois length]-1)];
        
        [attributedString setTextColor:[[Config sharedInstance] textColor] ];
        
        return attributedString;
    }
    return [[NSAttributedString alloc] initWithString:@""];
}

- (void)setTTTAttributedStringForDate:(NSDate*)date forLabel:(UILabel*)origin withTTLabel:(TTTAttributedLabel*)tttLabel withTextAlignment:(NSTextAlignment)alignment
{
    NSInteger bigSize = 12, smallSize = 10;
    
    NSDictionary *formats = [self formatedStringFromDate:date];
    
    NSString *jour = formats[@"jour"];
    NSString *numero = formats[@"numero"];
    NSString *mois = formats[@"mois"];
    
    NSString *total = [NSString stringWithFormat:@"%@ %@ %@", jour, numero, mois];
    
    tttLabel.textAlignment = alignment;
    tttLabel.backgroundColor = [UIColor clearColor];
    [tttLabel setText:total afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        int taille = 0;
        Config *cf = [Config sharedInstance];
        
        // 1er Lettre jour
        [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(0, 1)];
        
        // Reste Jour
        taille = [jour length]-1;
        [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange(1, taille )];
        
        // Numéro + 1er lettre mois
        [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(taille+1, [numero length] + 3 )];
        
        // Reste Mois
        taille = taille + 1 + [numero length] + 3;
        [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange(taille, [mois length]-1)];
        
        // Couleur
        [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(0, [total length])];
        
        
        return mutableAttributedString;
    }];
    
    [tttLabel removeFromSuperview];
    [origin.superview addSubview: tttLabel];
    origin.hidden = YES;
    
}

- (NSDictionary*)formatedStringFromHour:(NSDate*)hour
{
    // Formateur
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
    
    // Heures
    [formater setDateFormat:@"HH"];
    int val = [[formater stringFromDate:hour] intValue];
    NSString *heure = [NSString stringWithFormat:@"%d", val];
    
    // Minutes
    [formater setDateFormat:@"mm"];
    NSString *minutes = [formater stringFromDate:hour];
    
    // Format final
    NSString *final = [NSString stringWithFormat:@"%@h%@", heure, minutes];
    
    return @{
    @"heure" : heure,
    @"minutes" : minutes,
    @"final" : final
    };
}

- (NSAttributedString*)createClassicAttributedStringForHour:(NSDate*)hour
{
    // Ressources
    UIFont *bigFont = [[Config sharedInstance] defaultFontWithSize:12];
    UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:10];
    
    NSDictionary *formats = [self formatedStringFromHour:hour];
    
    NSString *heure = formats[@"heure"];
    NSString *minutes = formats[@"minutes"];
    NSString *final = formats[@"final"];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:final ];
    
    // Fonts
    [attributedString setFont:bigFont range:NSMakeRange(0, [heure length])];
    [attributedString setFont:smallFont range:NSMakeRange([heure length], 1)];
    [attributedString setFont:bigFont range:NSMakeRange([heure length]+1, [minutes length] )];
    
        
    [attributedString setTextColor:[[Config sharedInstance] textColor] ];

    
    return attributedString;
}

- (void)setTTTAttributedStringForHour:(NSDate*)hour forLabel:(UILabel*)origin withTTLabel:(TTTAttributedLabel*)tttLabel withTextAlignment:(NSTextAlignment)alignment
{
    NSInteger bigSize = 12, smallSize = 10;
    
    NSDictionary *formats = [self formatedStringFromHour:hour];
    
    NSString *heure = formats[@"heure"];
    NSString *minutes = formats[@"minutes"];
    NSString *final = formats[@"final"];
        
    tttLabel.textAlignment = alignment;
    tttLabel.backgroundColor = [UIColor clearColor];
    [tttLabel setText:final afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        Config *cf = [Config sharedInstance];
        
        // Heures
        [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(0, [heure length] )];
        
        // 'h'
        [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange( [heure length], 1 )];
        
        // Minutes
        [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange( [heure length]+1 , [minutes length] )];
        
        // Couleur
        [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(0, [final length] )];
        
        
        return mutableAttributedString;
    }];
    
    [tttLabel removeFromSuperview];
    [origin.superview addSubview: tttLabel];
    origin.hidden = YES;
}

/*
#pragma mark - Parallax effect

- (void)updateOffsets {
    CGFloat yOffset   = self.scrollView.contentOffset.y;
    CGFloat threshold = ImageHeight - WindowHeight;
    
    if (yOffset > -threshold && yOffset < 0) {
        self.imageScroller.contentOffset = CGPointMake(0.0, floorf(yOffset / 2.0));
    } else if (yOffset < 0) {
        self.imageScroller.contentOffset = CGPointMake(0.0, yOffset + floorf(threshold / 2.0));
    } else {
        self.imageScroller.contentOffset = CGPointMake(0.0, yOffset);
    }
}

#pragma mark - View Layout
- (void)layoutImage {
    CGFloat imageWidth   = self.imageScroller.frame.size.width;
    CGFloat imageYOffset = floorf((WindowHeight  - ImageHeight) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    self.momentImageView.frame       = CGRectMake(imageXOffset, imageYOffset, imageWidth, ImageHeight);
    self.imageScroller.contentSize   = CGSizeMake(imageWidth, self.view.bounds.size.height);
    self.imageScroller.contentOffset = CGPointMake(0.0, 0.0);
}
 */

#pragma mark - Subviews init

- (void) initTopImageView
{
    // Background image
    [self.momentImageView setImage:self.moment.uimage imageString:self.moment.imageString placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:^(UIImage *image) {
        [self.moment setUimage:image];
    }];
    
    // Medallion
    /*self.ownerAvatarView.borderWidth = 2.0;
    self.ownerAvatarView.defaultStyle = MedallionStyleProfile;
    [self.ownerAvatarView setImage:self.moment.owner.uimage imageString:self.moment.owner.imageString withSaveBlock:^(UIImage *image) {
        [self.moment.owner setUimage:image];
    }];
    [self.ownerAvatarView addTarget:self action:@selector(clicProfile) forControlEvents:UIControlEventTouchUpInside];
     */
    
    CGRect frame = self.ownerDescripionView.frame;
    frame.origin.y = 71;
    self.ownerDescripionView.frame = frame;
    
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:10];
    self.hashtagLabel.font = font;
    self.ownerNameLabel.font = font;
    
    // Photo
    UIImage *picture = self.moment.owner.uimage?self.moment.owner.uimage : [UIImage imageNamed:@"profil_defaut"];
    UIImage *cropped = [CropImageUtility cropImage:picture intoCircle:CircleSizeProfil];
    if(!self.user.uimage) {
        [self.avatarImage setImage:nil imageString:self.moment.owner.imageString placeHolder:cropped withSaveBlock:^(UIImage *image) {
            
            //self.user.uimage = image;
            UIImage *cropped = [CropImageUtility cropImage:image intoCircle:CircleSizeProfil];
            self.avatarImage.image = cropped;
            
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
        self.avatarImage.image = cropped;
    [self.avatarImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicProfile)]];
    
    // Owner Description
    self.ownerNameLabel.text =  [NSString stringWithFormat:@"par %@ %@", self.moment.owner.prenom?:@"", self.moment.owner.nom?:@""];
    
#ifdef HASHTAG_ENABLE
    if(self.moment.hashtag)
        self.hashtagLabel.text = [NSString stringWithFormat:@"#%@", self.moment.hashtag ];
    else {
        self.hashtagLabel.hidden = YES;
        // Déplacer titre
    }
#else
    self.hashtagLabel.hidden = YES;
#endif
    
}

- (void)clicProfile {
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:self.user];
    [self.rootViewController.navigationController pushViewController:profil animated:YES];
}

- (void)initTitreView
{
    // Titre
    if(self.moment.titre)
    {
        NSString *texteLabel = [self.moment.titre uppercaseString];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
        
#pragma CustomLabel
        if( [[VersionControl sharedInstance] supportIOS6] )
        {
            // Attributs du label
            NSRange range = NSMakeRange(0, 1);
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeBig] range:range];
            [attributedString setTextColor:[[Config sharedInstance] orangeColor] range:range];
            range = NSMakeRange(1, [attributedString length]-1);
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium] range:range];
            [attributedString setTextColor:[[Config sharedInstance] textColor] range:range];
            
            [self.titreLabel setAttributedText:attributedString];
            self.titreLabel.textAlignment = kCTLeftTextAlignment;
        }
        else
        {
            if(!self.ttTitreLabel)
                self.ttTitreLabel = [[TTTAttributedLabel alloc] initWithFrame:self.titreLabel.frame];
            self.ttTitreLabel.backgroundColor = [UIColor clearColor];
            [self.ttTitreLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                NSInteger taille = [texteLabel length];
                Config *cf = [Config sharedInstance];
                
                // 1er Lettre Font
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:InfoMomentFontSizeBig onRange:NSMakeRange(0, 1)];
                
                // Autres Lettres Font
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:InfoMomentFontSizeMedium onRange:NSMakeRange(1, taille-1 )];
                
                // 1er Lettre Couleur
                [cf updateTTTAttributedString:mutableAttributedString withColor:cf.orangeColor onRange:NSMakeRange(0, 1)];
                
                // Autres lettres couleurs
                [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(1, taille-1)];
                
                return mutableAttributedString;
            }];
            
            [self.ttTitreLabel removeFromSuperview];
            [self.titreLabel.superview addSubview:self.ttTitreLabel];
            self.titreLabel.hidden = YES;
            
            //[self.titreLabel setAttributedTextFromString:texteLabel withFontSize:InfoMomentFontSizeMedium];
            //self.titreLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        if(firstLoad) {            
            
            [self addSubviewAtAutomaticPosition:self.titreView];
        }

    }
}

- (void)initRsvpView
{
    // Police
    self.rsvpLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
    
    // Wordings
    enum UserState state = self.moment.state.intValue;
    NSString *message = nil;
    
    switch (state) {
            
        case UserStateAdmin:
        case UserStateOwner:
        case UserStateValid:
            message = @"Je serais présent au moment ...";
            self.rsvpYesButton.selected = YES;
            self.rsvpNoButton.selected = NO;
            self.rsvpMaybeButton.selected = NO;
            break;
            
        case UserStateRefused:
            message = @"Je ne serais pas présent au moment ...";
            self.rsvpNoButton.selected = YES;
            self.rsvpMaybeButton.selected = NO;
            self.rsvpYesButton.selected = NO;
            break;
            
        case UserStateWaiting:
            message = @"Je sais pas si je serais présent au moment ...";
            self.rsvpMaybeButton.selected = YES;
            self.rsvpYesButton.selected = NO;
            self.rsvpNoButton.selected = NO;
            break;
            
        // Unknown
        default:
            message = @"Serez-vous présent au moment ?";
            break;
    }
    
    // Text
    self.rsvpLabel.text = message;
    
    // Sparateur
    InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(70 + 5)];
    [self.rsvpView addSubview:separator];
    
    CGRect frame = self.rsvpView.frame;
    frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
    self.rsvpView.frame = frame;
    
    if(firstLoad)
        [self addSubviewAtAutomaticPosition:self.rsvpView];
    
    
}

- (void) initDescriptionView
{
    // Description
    if(self.moment.descriptionString)
    {
        self.descriptionLabel.text = self.moment.descriptionString;
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeLittle];
        self.descriptionLabel.font = font;
        self.descriptionLabel.textColor = [[Config sharedInstance] textColor];
        CGSize maxSize = CGSizeMake(self.descriptionLabel.frame.size.width, 9999);
        CGSize expectedSize = [self.moment.descriptionString sizeWithFont:font constrainedToSize:maxSize lineBreakMode:self.descriptionLabel.lineBreakMode];
        CGRect frame = self.descriptionLabel.frame;
        //frame.origin.y = separator.frame.origin.y + separator.frame.size.height + 15;
        
#warning Description incomplete
        // Limitation de la taille
        if( expectedSize.height > DescriptionBoxHeightMax )
        {
            self.descriptionBoxReelHeight = expectedSize.height;
            frame.size.height = DescriptionBoxHeightMax + 30;
            self.descriptionLabel.frame = CGRectMake(frame.origin.x, frame.origin.y - 10, frame.size.width, frame.size.height);
            
            // Background TextField
            frame = self.backgroundDescripionView.frame;
            frame.origin.y = self.descriptionLabel.frame.origin.y - 10;
            frame.size.height = self.descriptionLabel.frame.size.height + 20;
            self.backgroundDescripionView.frame = frame;
            
            // Bouton Voir Plus
            UIButton *more = [[UIButton alloc] init];
            [more setTitle:@"Voir plus" forState:UIControlStateNormal];
            [more setTitleColor:[Config sharedInstance].textColor forState:UIControlStateNormal];
            more.titleLabel.textAlignment = [[VersionControl sharedInstance] alignment:TextAlignmentCenter];
            more.titleLabel.font = [[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium];
            [more addTarget:self action:@selector(clicExpandDescriptionView) forControlEvents:UIControlEventTouchUpInside];
            [more sizeToFit];
            more.backgroundColor = [UIColor redColor];
            
            // Frame
            CGPoint origin = (CGPoint){(320 - more.frame.size.width)/2.0,
                                        self.rsvpView.frame.origin.y + self.rsvpView.frame.size.height + DescriptionBoxHeightMax + 25};
            more.frame = CGRectMake(origin.x, origin.y, more.frame.size.width, more.frame.size.height);
            [self.foregroundView addSubview:more];
            seeMoreButton = more;
        }
        else
        {
            self.descriptionBoxReelHeight = expectedSize.height;
            frame.size.height = expectedSize.height;
            self.descriptionLabel.frame = frame;
            
            // Background TextField
            frame = self.backgroundDescripionView.frame;
            frame.origin.y = self.descriptionLabel.frame.origin.y - 10;
            frame.size.height = self.descriptionLabel.frame.size.height + 20;
            self.backgroundDescripionView.frame = frame;
        }
        
        if(firstLoad) {
            // Separateur
            InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(self.backgroundDescripionView.frame.origin.y + self.backgroundDescripionView.frame.size.height + 5)];
            [self.descriptionView addSubview:separator];
            
            // View
            frame = self.descriptionView.frame;
            frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
            self.descriptionView.frame = frame;
            
            [self addSubviewAtAutomaticPosition:self.descriptionView];
        }

    }
}

- (void) initMapView
{
    if(self.moment.adresse)
    {
        // Indicateur de chargement
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        
        // On centre l'indicateur
        CGRect frame = activityIndicator.frame;
        frame.origin.x = (self.mapView.frame.size.width - frame.size.width)/2.0;
        frame.origin.y = (self.mapView.frame.size.height - frame.size.height)/2.0;
        activityIndicator.frame = frame;
        
        [self.mapView addSubview:activityIndicator];
        
        // ---- Chargement de la vue map ----
        dispatch_queue_t geocoderQueue = dispatch_queue_create("GeocoderQueue", NULL);
        dispatch_async(geocoderQueue, ^{
            
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:self.moment.adresse completionHandler:^(NSArray *placemarks, NSError *error) {
                
                // Si l'adresse a été trouvée
                if ([placemarks count] > 0) {
                    
                    CLPlacemark *placemark = placemarks[0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.coordonateMap = placemark.location.coordinate;
                        [self.mapView setCenterCoordinate:self.coordonateMap zoomLevel:12 animated:YES];
                        [activityIndicator stopAnimating];
                    });
                    
                }
                else
                {
#warning afficher ui indiquant que la localisation a échoué
                    //NSLog(@"InfoMoment MapView Geocoder fail");
                    
                    
                    // Try Google API
                    [self geolocalisationFromGoogleMaps:self.moment.adresse withEnded:^(BOOL success, double lat, double lng) {
                        
                        if(success) {
                            
                            //NSLog(@"Google Map Success");
                            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.coordonateMap = coord;
                                [self.mapView setCenterCoordinate:self.coordonateMap zoomLevel:12 animated:YES];
                                [activityIndicator stopAnimating];
                            });
                            
                        }
                        else  {
                                                        
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [activityIndicator stopAnimating];
                            });
                            
                        }
                        
                    }];
                    
                }
                
            }];
            
        });
        dispatch_release(geocoderQueue);
        
                
#pragma CustomLabel
        // ---- Attributed string for CustomLabel ----
        int taille = [self.moment.adresse length];
        if( [[VersionControl sharedInstance] supportIOS6] )
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.moment.adresse];
            
            // Couleur
            [attributedString setTextColor:[[Config sharedInstance] textColor]];
            
            // 1er Lettre
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium] range:NSMakeRange(0, 1)];
            
            // Autres lettres
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeLittle] range:NSMakeRange(1, taille-1) ];
            
            [self.adresseLabel setAttributedText:attributedString];
        }
        else
        {
            if(!self.ttAdresseLabel)
                self.ttAdresseLabel = [[TTTAttributedLabel alloc] initWithFrame:self.adresseLabel.frame];
            self.ttAdresseLabel.backgroundColor = [UIColor clearColor];
            [self.ttAdresseLabel setText:self.moment.adresse afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                Config *cf = [Config sharedInstance];
                
                // Couleur
                [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(0, taille)];
                
                // 1er Lettre
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:InfoMomentFontSizeMedium onRange:NSMakeRange(0, 1) ];
                
                // Autres lettres
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:InfoMomentFontSizeLittle onRange:NSMakeRange(1, taille-1) ];
                
                return mutableAttributedString;
            }];
            
            [self.ttAdresseLabel removeFromSuperview];
            [self.adresseLabel.superview addSubview:self.ttAdresseLabel];
            self.adresseLabel.hidden = YES;
            
            /*
             self.adresseLabel.text = adresse;
             self.adresseLabel.textAlignment = NSTextAlignmentCenter;
             self.adresseLabel.textColor = [[Config sharedInstance] textColor];
             self.adresseLabel.font = [[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium];
             */
        }
        
        
        // ---- Nom Lieu ----
        if([self.moment.nomLieu length] > 0)
        {
            self.nomLieuLabel.textColor = [[Config sharedInstance] textColor];
            self.nomLieuLabel.text = [self.moment.nomLieu uppercaseString];
            self.nomLieuLabel.font = [[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium];
            self.nomLieuLabel.alpha = 0.7;
            self.nomLieuView.alpha = 0.4;
        }
        else {
            self.nomLieuView.alpha = 0;
            self.nomLieuLabel.alpha = 0;
        }
        
        if(firstLoad) {
            // ---- Sparateur ----
            InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(99 + 5)];
            [self.generalMapView addSubview:separator];
            
            
            // Frame
            frame = self.generalMapView.frame;
            frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
            self.generalMapView.frame = frame;
            
            // Tap Gesture
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicMapView)];
            [self.mapView addGestureRecognizer:tap];
            
            [self addSubviewAtAutomaticPosition:self.generalMapView];
        }
        
    }
    
}

- (void) initInvitesView
{
    // Attributed string
    
    int nb = self.moment.guests_number.intValue;
    
    UIColor *color = [[Config sharedInstance] textColor];
    UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeLittle];
    
    NSMutableString *texte = [NSMutableString stringWithFormat:@"%d", nb];
    int taille = [texte length];
    if(nb > 1)
        [texte appendString:@" invités"];
    else
        [texte appendString:@" invité"];
    
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texte];
        [attributedString setTextColor:color];
        
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium] range:NSMakeRange(0, taille)];
        [attributedString setFont:smallFont range:NSMakeRange(taille, [texte length] - taille)];
        
        // Invités labels
        self.nbInvitesLabel.attributedText = attributedString;
    }
    else
    {
        if(!self.ttNbInvitesLabel)
            self.ttNbInvitesLabel = [[TTTAttributedLabel alloc] initWithFrame:self.nbInvitesLabel.frame];
        self.ttNbInvitesLabel.backgroundColor = [UIColor clearColor];
        [self.ttNbInvitesLabel setText:texte afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // Couleur
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(0, [texte length])];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InfoMomentFontSizeMedium onRange:NSMakeRange(0, taille)];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InfoMomentFontSizeLittle onRange:NSMakeRange(taille, [texte length] - taille )];
            
            return mutableAttributedString;
        }];
        
        [self.ttNbInvitesLabel removeFromSuperview];
        [self.nbInvitesLabel.superview addSubview:self.ttNbInvitesLabel];
        self.nbInvitesLabel.hidden = YES;
        
        /*
        self.nbInvitesLabel.text = texte;
        self.nbInvitesLabel.textColor = color;
        self.nbInvitesLabel.font = smallFont;
         */
    }
    
    self.nbInvitesRefusesLabel.text = [NSString stringWithFormat:@"%d", self.moment.guests_not_coming.intValue];
    //self.nbInvitesValidesLabel.text = [NSString stringWithFormat:@"%d", nb - taille - [self.moment.usersWaiting count]];
    self.nbInvitesValidesLabel.text = [NSString stringWithFormat:@"%d", self.moment.guests_coming.intValue];
    self.nbInvitesRefusesLabel.font = smallFont;
    self.nbInvitesValidesLabel.font = smallFont;
    self.nbInvitesRefusesLabel.textColor = color;
    self.nbInvitesValidesLabel.textColor = color;
    
    // Non Admin
    if( (!self.moment.isOpen) && (self.moment.state.intValue != UserStateAdmin) && (self.moment.state.intValue != UserStateOwner) )
    {
        self.inviteButton.hidden = YES;
        
        // Background frame
        CGRect frame = self.invitesBackgroundView.frame;
        int difference = 300 - frame.size.width;
        frame.size.width = 300;
        frame.size.height += 20;
        frame.origin.y -= 10;
        self.invitesBackgroundView.frame = frame;
        
        // Valide frame
        frame = self.valideImageView.frame;
        frame.origin.x = self.invitesBackgroundView.frame.size.width - frame.size.width - 9;
        self.valideImageView.frame = frame;
        
        // Label valide frame
        frame = self.nbInvitesValidesLabel.frame;
        frame.origin.x += difference/2.0;
        frame.size.width = self.valideImageView.frame.origin.x - frame.origin.x - 1;
        self.nbInvitesValidesLabel.frame = frame;
        
        // Refused frame
        frame = self.refusedImageView.frame;
        frame.origin.x += difference/2.0;
        self.refusedImageView.frame = frame;
        
        // Label refused frame
        frame = self.nbInvitesRefusesLabel.frame;
        frame.size.width = self.refusedImageView.frame.origin.x - frame.origin.x - 1;
        self.nbInvitesRefusesLabel.frame = frame;
        
    }
    
    if(firstLoad) {
        // Sparateur
        InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(50 + 5)];
        [self.invitesView addSubview:separator];
        
        // Frame
        CGRect frame = self.invitesView.frame;
        frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
        self.invitesView.frame = frame;
        
        // Tap Gesture Recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicInviteView)];
        [self.invitesBackgroundView addGestureRecognizer:tap];
        
        [self addSubviewAtAutomaticPosition:self.invitesView];
    }
    
}

- (void) initDateView
{    
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Création des textes
        if(self.moment.dateDebut) {
            self.dateDebutLabel.attributedText = [self createClassicAttributedStringForDate:self.moment.dateDebut];
            self.heureDebutLabel.attributedText = [self createClassicAttributedStringForHour:self.moment.dateDebut];
        }
        if(self.moment.dateFin) {
            self.dateFinLabel.attributedText = [self createClassicAttributedStringForDate:self.moment.dateFin];
            self.heureFinLabel.attributedText = [self createClassicAttributedStringForHour:self.moment.dateFin];
        }
            
        // Alignement
        [self.dateDebutLabel setTextAlignment:kCTTextAlignmentLeft];
        [self.dateFinLabel setTextAlignment:NSTextAlignmentRight];
        [self.heureDebutLabel setTextAlignment:kCTTextAlignmentLeft];
        [self.heureFinLabel setTextAlignment:NSTextAlignmentRight];
    }
    else
    {
        if(self.moment.dateDebut)
        {
            if(!self.ttDateDebutLabel)
                self.ttDateDebutLabel = [[TTTAttributedLabel alloc] initWithFrame:self.dateDebutLabel.frame];
            [self setTTTAttributedStringForDate:self.moment.dateDebut forLabel:self.dateDebutLabel withTTLabel:self.ttDateDebutLabel withTextAlignment:NSTextAlignmentLeft];
            
            if(!self.ttHeureDebutLabel)
                self.ttHeureDebutLabel = [[TTTAttributedLabel alloc] initWithFrame:self.heureDebutLabel.frame];
            [self setTTTAttributedStringForHour:self.moment.dateDebut forLabel:self.heureDebutLabel withTTLabel:self.ttHeureDebutLabel withTextAlignment:NSTextAlignmentLeft];
        }
        
        if(self.moment.dateFin)
        {
            if(!self.ttDateFinLabel)
                self.ttDateFinLabel = [[TTTAttributedLabel alloc] initWithFrame:self.dateFinLabel.frame];
            [self setTTTAttributedStringForDate:self.moment.dateFin forLabel:self.dateFinLabel withTTLabel:self.ttDateFinLabel withTextAlignment:NSTextAlignmentRight];
            
            if(!self.ttHeureFinLabel)
                self.ttHeureFinLabel = [[TTTAttributedLabel alloc] initWithFrame:self.heureFinLabel.frame];
            [self setTTTAttributedStringForHour:self.moment.dateFin forLabel:self.heureFinLabel withTTLabel:self.ttHeureFinLabel withTextAlignment:NSTextAlignmentRight];
        }
        
    }
    
    if(firstLoad) {
        
        // Sparateur
        InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(76 + 5)];
        [self.dateView addSubview:separator];
        
        CGRect frame = self.dateView.frame;
        frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
        self.dateView.frame = frame;
        
        // Tap Gesture Recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicDateView)];
        [self.dateView addGestureRecognizer:tap];
        
        [self addSubviewAtAutomaticPosition:self.dateView];
    }
    
}

- (void) initPhotosView
{
    // Sparateur
    InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(78 + 5)];
    [self.photosView addSubview:separator];
    
    CGRect frame = self.photosView.frame;
    frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
    self.photosView.frame = frame;
    
    //rotate label in 45 degrees
    self.nbPhotosLabel.transform = CGAffineTransformMakeRotation( (-1)*M_PI/4 );
    
    // Load Photos
    [self.moment getPhotosWithEnded:^(NSArray *photos) {
        
        int taille = [photos count];
        self.nbPhotosLabel.text = [NSString stringWithFormat:@"%d", taille];
        for(int i=0; i<taille && i<5; i++) {
            Photos *p = photos[taille - 1 - i];
            [self.photosImageView[i] setImage:p.imageThumbnail imageString:p.urlThumbnail withSaveBlock:^(UIImage *image) {
                p.imageThumbnail = image;
            }];
        }
    }];
    
    if(firstLoad) {
        
        // Tap Gesture recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicPhotoView)];
        [self.photosView addGestureRecognizer:tap];
        
        [self addSubviewAtAutomaticPosition:self.photosView];
    }
        
}

- (void) initBadgesView
{
    // Sparateur
    InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(78 + 5)];
    [self.badgesView addSubview:separator];
    
    CGRect frame = self.photosView.frame;
    frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
    self.badgesView.frame = frame;
    
    //rotate label 45 degrees
    self.nbBadgesLabel.transform = CGAffineTransformMakeRotation( (-1)*M_PI/4 );
    self.nbBadgesLabel.text = [NSString stringWithFormat:@"%d", 7];
    
    if(firstLoad)
        [self addSubviewAtAutomaticPosition:self.badgesView];
}

- (void) initMetroView
{
    if(self.moment.infoMetro)
    {
        [self.metroLabel setFont:[[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium] ];
        [self.metroLabel setTextColor:[[Config sharedInstance] textColor] ];
        //[self.metroLabel setFontSize:InfoMomentFontSizeMedium];
        self.metroLabel.text = self.moment.infoMetro;
        
        // Sparateur
        InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(59 + 5)];
        [self.metroView addSubview:separator];
        
        CGRect frame = self.metroView.frame;
        frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
        self.metroView.frame = frame;
        
        if(firstLoad)
            [self addSubviewAtAutomaticPosition:self.metroView];
    }
}

- (void) initInfoLieuView
{
    if(self.moment.infoLieu)
    {
        [self.infoLieuLabel setFont:[[Config sharedInstance] defaultFontWithSize:InfoMomentFontSizeMedium] ];
        [self.infoLieuLabel setTextColor:[[Config sharedInstance] textColor] ];
        //[self.infoLieuLabel setFontSize:InfoMomentFontSizeMedium];
        self.infoLieuLabel.text = self.moment.infoLieu;
        
        // Sparateur
        InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(63)];
        [self.infoLieuView addSubview:separator];
        
        CGRect frame = self.infoLieuView.frame;
        frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
        self.infoLieuView.frame = frame;
        
        if(firstLoad)
            [self addSubviewAtAutomaticPosition:self.infoLieuView];
    }
}

- (void) initCagnotteView
{
     // Sparateur
     InfoMomentSeparateurView *separator = [[InfoMomentSeparateurView alloc] initAtPosition:(121)];
     [self.cagnotteView addSubview:separator];
     
     CGRect frame = self.cagnotteView.frame;
     frame.size.height = separator.frame.origin.y + separator.frame.size.height + 5;
     self.cagnotteView.frame = frame;
    
    if(firstLoad) {
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:10];
        for( UILabel *label in self.comingSoonCagnotteLabels) {
            label.font = font;
        }
        
        font = [[Config sharedInstance] defaultFontWithSize:11];
        self.cagnotteCourseLabel.font = font;
        self.cagnotteCagnotteLabel.font = font;
        self.cagnotteCompteLabel.font = font;
        
        [self addSubviewAtAutomaticPosition:self.cagnotteView];
    }
}

- (void) initPartageView
{    
    if(firstLoad)
        [self addSubviewAtAutomaticPosition:self.partageView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // View
    CGRect frame = self.view.frame;
    frame.size.height = [[VersionControl sharedInstance] screenHeight] - TOPBAR_HEIGHT;
    self.view.frame = frame;
        
    // Initialisation
    hauteur = 0;
    self.foregroundView = [[IgnoreTouchView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    self.foregroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.foregroundView.autoresizesSubviews = NO;
    
    /***********************************************
     *                   Views                     *
     ***********************************************/
    [self initTitreView];
    [self initRsvpView];
    [self initDescriptionView];
    [self initMapView];
    [self initInvitesView];
    [self initDateView];
    [self initPhotosView];
    //[self initBadgesView];
    [self initMetroView];
    [self initInfoLieuView];
    [self initTopImageView];
    [self initCagnotteView];
    [self initPartageView];

    /***********************************************
     *              Parallax View                  *
     ***********************************************/
    self.parallaxView = [[MDCParallaxView alloc] initWithBackgroundView:self.topImageView foregroundView:self.foregroundView];
    self.parallaxView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.parallaxView sizeToFit];
    self.parallaxView.backgroundHeight = 150.0f;
    self.parallaxView.scrollViewDelegate = self;
    self.parallaxView.scrollView.scrollsToTop = YES;
    [self.view addSubview:self.parallaxView];
    
    /***********************************************
     *              ExpandingButtonBar             *
     ***********************************************/
    self.expandButton = [[CustomExpandingButton alloc] initWithDelegate:self withState:self.moment.state.intValue];
    //[self.ownerDescripionView addSubview:self.expandButton];
    UIView *retain = self.ownerDescripionView;
    [retain removeFromSuperview];
    [self.parallaxView.scrollView addSubview:retain];
    [self.parallaxView.scrollView addSubview:self.expandButton];
    
    // First Load Complete
    firstLoad = NO;
    
    /*
    [self layoutImage];
    [self updateOffsets];
    */
    
    // Load RSVP From Facebook
    [[FacebookManager sharedInstance] getRSVP:self.moment withEnded:^(enum UserState rsvp) {
        if(self.moment.state.intValue != rsvp) {
            
            // Informer User
            [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:@"Status Facebook Importé" duration:1 animated:YES];
            
            // Update View
            UIButton *buttonSimulation = nil;
            switch (rsvp) {
                case UserStateValid:
                    buttonSimulation = self.rsvpYesButton;
                    break;
                    
                case UserStateRefused:
                    buttonSimulation = self.rsvpNoButton;
                    break;
                                        
                default:
                    buttonSimulation = self.rsvpMaybeButton;
                    break;
            }
            
            [self clicRSVPButton:buttonSimulation];
        }
    }];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
    [self sendGoogleAnalyticsView];
}

- (void)viewDidUnload
{
    [self setMoment:nil];
    [self setForegroundView:nil];
    [self setTopImageView:nil];
    [self setOwnerDescripionView:nil];
    [self setOwnerNameLabel:nil];
    [self setHashtagLabel:nil];
    [self setExpandButton:nil];
    [self setMomentImageView:nil];
    [self setDescriptionView:nil];
    [self setTitreLabel:nil];
    [self setDescriptionLabel:nil];
    [self setBackgroundDescripionView:nil];
    [self setGeneralMapView:nil];
    [self setMapView:nil];
    [self setAdresseLabel:nil];
    [self setNomLieuView:nil];
    [self setNomLieuLabel:nil];
    [self setInvitesView:nil];
    [self setNbInvitesLabel:nil];
    [self setNbInvitesValidesLabel:nil];
    [self setNbInvitesRefusesLabel:nil];
    [self setDateView:nil];
    [self setDateDebutLabel:nil];
    [self setHeureDebutLabel:nil];
    [self setDateFinLabel:nil];
    [self setHeureFinLabel:nil];
    [self setPhotosView:nil];
    [self setBadgesView:nil];
    [self setMetroView:nil];
    [self setMetroLabel:nil];
    [self setInfoLieuView:nil];
    [self setInfoLieuLabel:nil];
    [self setTtNbInvitesLabel:nil];
    [self setTtMetroLabel:nil];
    [self setTtHeureFinLabel:nil];
    [self setTtHeureDebutLabel:nil];
    [self setTtTitreLabel:nil];
    [self setTtDateFinLabel:nil];
    [self setTtDateDebutLabel:nil];
    [self setTtAdresseLabel:nil];
    [self setInviteButton:nil];
    [self setInvitesBackgroundView:nil];
    [self setValideImageView:nil];
    [self setRefusedImageView:nil];
    [self setParallaxView:nil];
    [self setPhotosImageView:nil];
    [self setTitreView:nil];
    [self setCagnotteView:nil];
    [self setComingSoonCagnotteLabels:nil];
    [self setCagnotteCourseLabel:nil];
    [self setCagnotteCagnotteLabel:nil];
    [self setCagnotteCompteLabel:nil];
    [self setRsvpView:nil];
    [self setRsvpLabel:nil];
    [self setRsvpMaybeButton:nil];
    [self setRsvpYesButton:nil];
    [self setRsvpNoButton:nil];
    [super viewDidUnload];
}

- (void)reloadData
{
    [self.moment updateMomentFromServerWithEnded:^(BOOL success) {
        if(success)
        {
            // Force Reload Image
            self.moment.uimage = nil;
            self.moment.dataImage = nil;
            self.momentImageView.image = nil;
            self.momentImageView.imageString = nil;
            
            [self initTitreView];
            [self initRsvpView];
            [self initDescriptionView];
            [self initMapView];
            [self initInvitesView];
            [self initDateView];
            [self initPhotosView];
            //[self initBadgesView];
            [self initMetroView];
            [self initInfoLieuView];
            [self initTopImageView];
            [self initCagnotteView];
            [self initPartageView];
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsView {
    //AppDelegate *d = [[UIApplication sharedApplication] delegate];
    //[d.tracker sendView:@"Vue Info"];
    [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Info"];
    
}

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Infos"
     withAction:action
     withLabel:label
     withValue:value];
}

#pragma mark - ExpandingButtonBarDelegate

- (void) expandingBarDidAppear:(RNExpandingButtonBar *)bar
{
    //NSLog(@"did appear");
}

- (void) expandingBarWillAppear:(RNExpandingButtonBar *)bar
{
    //NSLog(@"will appear");
}

- (void) expandingBarDidDisappear:(RNExpandingButtonBar *)bar
{
    //NSLog(@"did disappear");
    
    if(expandingBarNeedUpdate) {
        
        NSArray *images = [self.expandButton orderButtonsWithState:expandingBarState];
        
        if( [images count] > 1 ) {
            [self.expandButton.firstButton setImage:images[1] forState:UIControlStateNormal];
            [self.expandButton.firstButton setImage:images[1] forState:UIControlEventTouchDown];
            
            [self.expandButton.secondButton setImage:images[2] forState:UIControlStateNormal];
            [self.expandButton.secondButton setImage:images[2] forState:UIControlEventTouchDown];
        }
        
        UIImage *newImage = images[0];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            [self.expandButton.button setImage:newImage forState:UIControlStateNormal];
            [self.expandButton.button setImage:newImage forState:UIControlEventTouchDown];
            [self.expandButton.toggledButton setImage:newImage forState:UIControlStateNormal];
            [self.expandButton.toggledButton setImage:newImage forState:UIControlEventTouchDown];
        } completion:nil];
        
        expandingBarNeedUpdate = NO;
    }
    
}

- (void) expandingBarWillDisappear:(RNExpandingButtonBar *)bar
{
    //NSLog(@"will disappear");
}

#pragma mark - Actions

- (void)clicRespond:(UIButton*)sender {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic RSVP" value:nil];
    
    enum UserState state = UserStateWaiting;
    UIImage *image = sender.imageView.image;
    
    // Si on a cliqué sur valider
    if(image == self.expandButton.validImage) {
        state = UserStateValid;
    }
    // Si on a cliquer sur refuser
    else if(image == self.expandButton.refusedImage) {
        state = UserStateRefused;
    }
    
    if(self.moment.state.intValue != state) {
        
        //self.moment.state = @(state);
        // Action
        [self.moment updateCurrentUserState:state withEnded:^(BOOL success) {
            expandingBarState = state;
            expandingBarNeedUpdate = YES;
            [self.expandButton hideButtonsAnimated:YES];
            [self reloadData];
        }];
    }
    else
        [self.expandButton hideButtonsAnimated:YES];
    
}

- (IBAction)clicRSVPButton:(UIButton*)sender {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic RSVP" value:nil];
    
    if(sender.isSelected)
        return;
    
    enum UserState state;
    
    if(sender == self.rsvpMaybeButton) {
        state = UserStateWaiting;
    }else if(sender == self.rsvpNoButton) {
        state = UserStateRefused;
    }else {
        state = UserStateValid;
    }
    
    if(self.moment.state.intValue != state) {
        
        // Action
        [self.moment updateCurrentUserState:state withEnded:^(BOOL success) {
            expandingBarState = state;
            expandingBarNeedUpdate = YES;
            [self.expandButton hideButtonsAnimated:YES];
            [self reloadData];
        }];
    }
    else
        [self.expandButton hideButtonsAnimated:YES];
    
}

- (void)clicEdit {
    CreationFicheViewController *editViewController = [[CreationFicheViewController alloc] initWithUser:self.user withMoment:self.moment withTimeLine:self.rootViewController.timeLine];
    [self.rootViewController.navigationController pushViewController:editViewController animated:YES];
}

- (IBAction)clicInviteButton {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Ajout Invité depuis Info" value:nil];
    
    InviteAddViewController *inviteViewController = [[InviteAddViewController alloc] initWithOwner:self.user withMoment:self.moment];
    [self.rootViewController.navigationController pushViewController:inviteViewController animated:YES];
}

- (void)clicInviteView {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Invités" value:nil];
    
    InvitePresentsViewController *inviteViewController = [[InvitePresentsViewController alloc] initWithOwner:self.user withMoment:self.moment];
    [self.rootViewController.navigationController pushViewController:inviteViewController animated:YES];
}

- (void)clicDateView {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Date" value:nil];
    
    [CalendarManager addNewEventFromMoment:self.moment];
}

- (void)clicMapView {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Map" value:nil];
    
    [self openMapsWithDirectionsTo:self.coordonateMap title:self.moment.titre];
}

- (void)clicPhotoView {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Racourcis Photos" value:nil];
    
    [self.rootViewController addAndScrollToOnglet:OngletPhoto];
}

- (void)clicExpandDescriptionView
{
    NSLog(@"pop");
}

- (IBAction)clicShareMail {
    NSLog(@"Mail");
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Partager Mail" value:nil];
    
    if([MFMailComposeViewController canSendMail])
    {
        
        // Email Subject
        NSString *emailTitle = @"Moment";
        // Email Content
        NSMutableString *messageBody = [NSMutableString stringWithFormat:@"Bon Moment @%@ !", self.moment.titre];
        
#ifdef HASHTAG_ENABLE
        if(self.moment.hashtag)
            [messageBody appendFormat:@" #%@\n", self.moment.hashtag];
        else
            [messageBody appendString:@"\n"];
#else
        [messageBody appendString:@"\n"];
#endif
      
        if(self.moment.uniqueURL)
            [messageBody appendFormat:@"<a href=%@>%@</a>\n", self.moment.uniqueURL, self.moment.uniqueURL];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        
        // Present mail view controller on screen
        [[VersionControl sharedInstance] presentModalViewController:mc fromRoot:self.rootViewController animated:YES];
    }
    else
    {
        NSLog(@"mail composer fail");
        
        [[[UIAlertView alloc] initWithTitle:@"Envoi impossible"
                                    message:@"Votre appareil ne supporte pas l'envoi d'email"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
    
}

- (IBAction)clicShareLink {
    NSLog(@"Link");
    
    // Copy To Clipboard
    if(self.moment.uniqueURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.moment.uniqueURL;
        
        [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:@"URL Copiée" duration:1 animated:YES];
    }
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Partager Copié" value:nil];
    
}

- (IBAction)clicShareFacebook {
    NSLog(@"Facebook");
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Partager Facebook" value:nil];
    
    // Paramètres
    NSString *initialText = [NSString stringWithFormat:@"Bon Moment @%@ !\n", self.moment.titre];
    
    // iOS 6 -> Social Framework
    if ( (NSClassFromString(@"SLComposeViewController") != nil) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController
                                            composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbSheet setInitialText:initialText];
        if(self.moment.uniqueURL)
            [fbSheet addURL:[NSURL URLWithString:self.moment.uniqueURL]];
        
        //[self presentViewController:fbSheet animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:fbSheet fromRoot:self animated:YES];
    }
    // iOS 5
    else
    {
        /*
         DEFacebookComposeViewControllerCompletionHandler completionHandler = ^(DEFacebookComposeViewControllerResult result) {
         switch (result) {
         case DEFacebookComposeViewControllerResultCancelled:
         NSLog(@"Facebook Result: Cancelled - iOS 5");
         break;
         case DEFacebookComposeViewControllerResultDone:
         NSLog(@"Facebook Result: Sent - iOS 5");
         break;
         }
         
         [self dismissModalViewControllerAnimated:YES];
         };
         */
        
        DEFacebookComposeViewController *facebookViewComposer = [[DEFacebookComposeViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [facebookViewComposer setInitialText:initialText];
        if(self.moment.uniqueURL)
            [facebookViewComposer addURL:[NSURL URLWithString:self.moment.uniqueURL]];
        //facebookViewComposer.completionHandler = completionHandler;
        //[self presentViewController:facebookViewComposer animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:facebookViewComposer fromRoot:self animated:YES];
    }
    
}

- (IBAction)clicShareTwitter {
    NSLog(@"Twitter");
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Partager Twitter" value:nil];
    
    // Paramètres
    NSMutableString *initialText = [NSMutableString stringWithFormat:@"Bon Moment @%@ !", self.moment.titre];
#ifdef HASHTAG_ENABLE
    if(self.moment.hashtag)
        [initialText appendFormat:@" #%@\n", self.moment.hashtag];
    else
        [initialText appendString:@"\n"];
#else
    [initialText appendString:@"\n"];
#endif
    
    // iOS 6 -> Social Framework
    if( (NSClassFromString(@"SLComposeViewController") != nil) && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:initialText];
        if(self.moment.uniqueURL)
            [tweetSheet addURL:[NSURL URLWithString:self.moment.uniqueURL]];
        
        //[self presentViewController:tweetSheet animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:tweetSheet fromRoot:self animated:YES];
    }
    // iOS 5 -> Twitter Framework
    else
    {
        TWTweetComposeViewController *twitterViewComposer = [[TWTweetComposeViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [twitterViewComposer setInitialText:initialText];
        if(self.moment.uniqueURL)
            [twitterViewComposer addURL:[NSURL URLWithString:self.moment.uniqueURL]];
        
        //[self presentViewController:twitterViewComposer animated:YES completion:nil];
        [[VersionControl sharedInstance] presentModalViewController:twitterViewComposer fromRoot:self animated:YES];
    }
    
}

/*
- (IBAction)clicShareInstagram {
    NSLog(@"Instagram");
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Partager Instagram" value:nil];
    
}
*/

#pragma mark - UIScrollView Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Si on dépasse la vue du haut et que le bouton est développé, on le rétracte
    if( (scrollView.contentOffset.y > self.topImageView.frame.size.height)
       && self.expandButton.isShowed ) {
        
        [self.expandButton hideButtons];
    }
    
}

#pragma mark - Maps

- (void)openMapsWithDirectionsTo:(CLLocationCoordinate2D)coord title:(NSString*)title {
        
    // iOS 6 and later -> Application Maps
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil]];
        toLocation.name = title;
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{
                                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                         MKLaunchOptionsShowsTrafficKey : @(YES)
          }];
        
    }
    // iOS 5
    else {
        UIApplication *app = [UIApplication sharedApplication];
        NSString *path = [[NSString stringWithFormat:@"?daddr=%1.6f,%1.6f", coord.latitude, coord.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // Safari
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps%@", path]];
        [app openURL:url];
    }
}

- (void)geolocalisationFromGoogleMaps:(NSString*)adresse withEnded:(void (^) (BOOL success, double lat, double lng) )block
{
    if(block)
    {
        // Parameters
        NSDictionary *params = @{@"address" : [[adresse stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 @"sensor" : @"true"
                                 };
        
        // Operation
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://maps.googleapis.com/"]];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:@"Accept" value:@"application/json"];
        [client getPath:@"maps/api/geocode/json" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            //NSLog(@"response = %@", JSON);
            
            // Success
            if([JSON[@"results"] count] > 0)
            {
                NSDictionary *location = JSON[@"results"][0][@"geometry"][@"location"];
                if(location) {
                    double lat = [location[@"lat"] doubleValue];
                    double lng = [location[@"lng"] doubleValue];
                    
                    block(YES, lat, lng);
                }
                
            }
            
            block(NO, 0, 0);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            HTTP_ERROR(operation, error);
            
            block(NO, 0, 0);
            
        }];
    }
}

#pragma mark - Cagnotte

- (IBAction)clicCagnotteButton {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Soon Cagnotte" value:nil];
    
#ifdef CAGNOTTE
    Cagnotte1ViewController *cagnotte = [[Cagnotte1ViewController alloc] initWithMoment:self.moment];
    
    UINavigationController *nav = self.rootViewController.timeLine.navigationController ?: self.rootViewController.navigationController;
    [nav pushViewController:cagnotte animated:YES];
#endif
    
}

/*
- (IBAction)clicCoursesButton {
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Soon Courses" value:nil];
}
*/

- (IBAction)clicFeedBackButton {
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Feedback" value:nil];
    
    // TestFlight SDK
    [TestFlight openFeedbackView];
}

- (IBAction)clicComptesButton {
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Soon Comptes" value:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            
            [[[UIAlertView alloc] initWithTitle:@"Erreur d'envoi"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
            
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:self.rootViewController animated:YES];
}


@end
