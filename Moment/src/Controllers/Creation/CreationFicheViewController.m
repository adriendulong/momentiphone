//
//  CreationFicheViewController.m
//  Moment
//
//  Created by Charlie FANCELLI on 03/10/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "CreationFicheViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Config.h"
#import "NSDate+NSDateAdditions.h"

#import "MomentCoreData+Model.h"
#import "MomentClass+Server.h"

#import "NSMutableAttributedString+FontAndTextColor.h"
#import "TTTAttributedLabel.h"
#import "PopUpFinCreationViewController.h"
#import "PlacesViewController.h"

@interface CreationFicheViewController () {
    @private
    BOOL isEdition;
    BOOL adresseTextFieldShouldClear;
    
    UIImage *modifiedCover;
}

@end

@implementation CreationFicheViewController

@synthesize timeLineViewContoller = _timeLineViewContoller;

@synthesize user = _user;
@synthesize moment = _moment;
@synthesize nomEvent = _nomEvent;
@synthesize coverImage = _coverImage;

@synthesize globalScrollView = _globalScrollView;
@synthesize currentStep = _currentStep;

@synthesize step2ScrollView = _step2ScrollView;
@synthesize quandLabel = _quandLabel;
@synthesize etape1Label = _etape1Label;
@synthesize coverView = _coverView;
@synthesize titreMomentLabel = _titreMomentLabel;
@synthesize changerCoverButton = _changerCoverButton;
@synthesize pickerView = _pickerView;
@synthesize startDateTextField = _startDateTextField;
@synthesize endDateTextField = _endDateTextField;
@synthesize startDateLabel = _startDateLabel;
@synthesize endDateLabel = _endDateLabel;
@synthesize dateFormatter = _dateFormatter;
@synthesize dateDebut = _dateDebut;
@synthesize dateFin = _dateFin;

@synthesize step1ScrollView = _step1ScrollView;
@synthesize ouLabel = _ouLabel;
@synthesize etape2Label = _etape2Label;
@synthesize infoLieuTextField = _infoLieuTextField;
@synthesize hashtagTextField = _hashtagTextField;
@synthesize adresseLabel = _adresseLabel;
@synthesize adresseText = _adresseText;
@synthesize infoLieuLabel = _infoLieuLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize hashtagLabel = _hashtagLabel;
@synthesize infoHashtagLabel = _infoHashtagLabel;
@synthesize switchButton = _switchButton;
@synthesize switchControlState = _switchControlState;
@synthesize backgroundDescriptionView = _backgroundDescriptionView;
@synthesize descriptionTextView = _descriptionTextView;

#pragma mark - Init

- (void)updateNavBarForStep:(NSInteger)step
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    
    if([buttons count] == 2)
    {
        UIImage *normal = nil;//, *selected = nil;
        SEL action = NULL;
        BOOL secondButtonEnable = NO;
        
        // Second Button
        UIButton *button = (UIButton*)[buttons[0] customView];
        
        // Previous Button
        UIButton *previousButton = (UIButton*)[buttons[1] customView];
                
        if(step == 1)
        {
            // Button Next
            normal = [UIImage imageNamed:@"topbar_arrow_down_enable.png"];
            action = @selector(clicNext);
            
            // Button Previous Disabled
            [UIView animateWithDuration:0.3 animations:^{
                previousButton.alpha = 0;
            }];
            [previousButton setEnabled:NO];
            
            // Second Button enable
            if( ((self.startDateTextField.text.length > 0) && (self.endDateTextField.text.length > 0)) ||
               (self.moment.dateDebut && self.moment.dateFin && [self.moment.dateDebut isEarlierThan:self.moment.dateFin]) ) {
                secondButtonEnable = YES;
            }
            
        }
        else
        {
            if(previousButton.hidden)
                previousButton.hidden = NO;
            
            // Button Valider
            normal = [UIImage imageNamed:@"topbar_valider.png"];
            action = @selector(clicCreate);
            
            // Button Previous Enable
            [UIView animateWithDuration:0.3 animations:^{
                previousButton.alpha = 1;
            }];
            [previousButton setEnabled:YES];
            
            // Second Button enable
            if( ((self.adresseLabel.text.length > 0)||(self.adresseText.length > 0)) && (self.descriptionTextView.text.length > 0) ){
                secondButtonEnable = YES;
            }

        }
        
        // Update
        [button setImage:normal forState:UIControlStateNormal];
        [button removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [button setEnabled:secondButtonEnable];
        
    }
    
}

- (void)setNavBarSecondButtonEnable:(BOOL)enable
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    UIButton *button = (UIButton*)[buttons[0] customView];
    
    [button setEnabled:enable];
}

- (id)initWithUser:(UserClass*)user withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    NSString *nibName = ([VersionControl sharedInstance].screenHeight == 480)? @"CreationFicheViewController_3_5" : @"CreationFicheViewController_4";
    
    self = [super initWithNibName:nibName bundle:nil];
    if(self) {
        
        self.user = user;
        self.timeLineViewContoller = timeLine;
        viewHeight = [[VersionControl sharedInstance] screenHeight] - TOPBAR_HEIGHT;
        adresseTextFieldShouldClear = NO;
        
        self.switchControlState = YES;
    }
    return self;
}

- (id)initWithUser:(UserClass*)user withEventName:(NSString*)eventName withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [self initWithUser:user withTimeLine:timeLine];
    if(self) {
        self.nomEvent = eventName;
        isEdition = NO;
    }
    return self;
}

- (id)initWithUser:(UserClass*)user withMoment:(MomentClass*)moment withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [self initWithUser:user withTimeLine:timeLine];
    if(self) {
        self.moment = moment;
        isEdition = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Init

- (void)initNavigationBar
{
    [CustomNavigationController setBackButtonWithViewController:self];
    CGRect frameButton = CGRectMake(0,0,43,43);
    
    // Bouton Previous
    UIButton *buttonPrevious = [[UIButton alloc] initWithFrame:frameButton];
    UIImage *arrow_up_disable = [UIImage imageNamed:@"topbar_arrow_up_disable.png"];
    UIImage *arrow_up_normal = [UIImage imageNamed:@"topbar_arrow_up_enable.png"];
    [buttonPrevious setImage:arrow_up_disable forState:UIControlStateDisabled];
    [buttonPrevious setImage:arrow_up_normal forState:UIControlStateNormal];
    [buttonPrevious addTarget:self action:@selector(clicPrev) forControlEvents:UIControlEventTouchUpInside];
    buttonPrevious.hidden = YES;
    UIBarButtonItem *buttonItemPrevious = [[UIBarButtonItem alloc] initWithCustomView:buttonPrevious];
    
    // 2e bouton
    UIButton *secondButton = [[UIButton alloc] initWithFrame:frameButton];
    UIBarButtonItem *secondBarButton = [[UIBarButtonItem alloc] initWithCustomView:secondButton];
    
    // Set buttons
    self.navigationItem.rightBarButtonItems = @[secondBarButton, buttonItemPrevious];
    
    // Init For Step 1
    [self updateNavBarForStep:1];
}

#pragma mark View Init - Util

- (void)placerView:(UIView*)view atStep:(NSInteger)step
{
    CGRect frame = view.frame;
    frame.origin.y += (step-1)*viewHeight;
    view.frame = frame;
}

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.masksToBounds  = NO;
}

- (UIView*)setLabelText:(CustomLabel*)label text:(NSString*)texteLabel minFontSize:(NSInteger)minSize maxFontSize:(NSInteger)maxSize color:(UIColor*)color
{
    if(texteLabel.length > 0)
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
        
        if( [[VersionControl sharedInstance] supportIOS6] )
        {
            // Attributs du label
            NSRange range = NSMakeRange(0, 1);
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
            range = NSMakeRange(1, [attributedString length]-1);
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
            [attributedString setTextColor:color];
            
            [label setAttributedText:attributedString];
            
            return label;
        }
        else
        {
            TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:label.frame];
            tttLabel.backgroundColor = [UIColor clearColor];
            [tttLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                NSInteger taille = [texteLabel length];
                Config *cf = [Config sharedInstance];
                
                // 1er Lettre Font
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:maxSize onRange:NSMakeRange(0, 1)];
                
                // Autres Lettres Font
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:minSize onRange:NSMakeRange(1, taille-1 )];
                
                // Couleurs
                [cf updateTTTAttributedString:mutableAttributedString withColor:color onRange:NSMakeRange(0, taille)];
                
                return mutableAttributedString;
            }];
            
            [label.superview addSubview:tttLabel];
            label.hidden = YES;
            
            return tttLabel;
        }
    }
    return label;
}

- (void)designTitreLabel:(CustomLabel*)label
{
    NSString *texteLabel = label.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
    NSInteger maxSize = 18, minSize = 14;
    
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
        [attributedString setTextColor:[[Config sharedInstance] orangeColor] range:range];
        range = NSMakeRange(1, taille-2);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
        range = NSMakeRange(1, taille-1);
        [attributedString setTextColor:[[Config sharedInstance] textColor] range:range];
        range = NSMakeRange(taille-2, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
        
        [label setAttributedText:attributedString];
    }
    else
    {
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:label.frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // 1er Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:maxSize onRange:NSMakeRange(0, 1)];
            
            // Autres Lettres Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:minSize onRange:NSMakeRange(1, taille-2)];
            
            // Dernière lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:maxSize onRange:NSMakeRange(taille-2, 1)];
            
            // 1er Lettre Couleur
            [cf updateTTTAttributedString:mutableAttributedString withColor:[[Config sharedInstance] orangeColor] onRange:NSMakeRange(0, 1)];
            
            // Autres Lettes Couleur
            [cf updateTTTAttributedString:mutableAttributedString withColor:[[Config sharedInstance] textColor] onRange:NSMakeRange(1, taille-1)];
            
            return mutableAttributedString;
        }];
        
        [label.superview addSubview:tttLabel];
        label.hidden = YES;
    }

}

#pragma mark View Init - Step 1

- (void) initCover
{
    // -- Shadow
    UIImageView *shadowCover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_cover_moment.png"] ];
    //shadowCover.contentMode = UIViewContentModeScaleToFill;
    CGRect frame = self.coverView.frame;
    frame.size.height += 1;
    shadowCover.frame = frame;
    [self.step1ScrollView insertSubview:shadowCover aboveSubview:self.coverView];
    //[self.step1ScrollView addSubview:shadowCover];
    
    // -- Labels
    // Label titre
    UIView *titre = [self setLabelText:self.titreMomentLabel text:[self.nomEvent uppercaseString] minFontSize:12 maxFontSize:16 color:[UIColor whiteColor]];
    // Label Changer Cover
    
    [self addShadowToView:titre];
    
    [self.step1ScrollView bringSubviewToFront:self.changerCoverButton];
}

- (void)initTitreStep1
{
    // Quand Label
    [self designTitreLabel:self.quandLabel];
    
    // Etape 1 Label
    [self setLabelText:self.etape1Label text:self.etape1Label.text minFontSize:10 maxFontSize:14 color:[Config sharedInstance].textColor];
}

- (void)initStep1Labels
{
    NSInteger maxSize = 15, minSize = 11;
    UIColor *color = [Config sharedInstance].textColor;
    
    [self setLabelText:self.startDateLabel text:self.startDateLabel.text minFontSize:minSize maxFontSize:maxSize color:color];
    [self setLabelText:self.endDateLabel text:self.endDateLabel.text minFontSize:minSize maxFontSize:maxSize color:color];
    
    self.changerCoverButton.titleLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
}

- (void)initDatePicker
{
    self.pickerView = [[CustomDatePicker alloc] init];
    
    [self.pickerView setValiderButtonTarget:self action:@selector(clicValiderPickerView)];
    [self.pickerView setDatePickerTarget:self action:@selector(datePickerChangeValue)];

    // Set InputViews
    self.startDateTextField.inputView = self.pickerView;
    self.endDateTextField.inputView = self.pickerView;
}

#pragma mark View Init - Step 2

- (void)initTitreStep2
{
    // Quand Label
    [self designTitreLabel:self.ouLabel];
    
    // Etape 1 Label
    [self setLabelText:self.etape2Label text:self.etape2Label.text minFontSize:10 maxFontSize:14 color:[Config sharedInstance].textColor];
}

- (void)initStep2Labels
{
    NSInteger maxSize = 15, minSize = 11;
    UIColor *textColor = [Config sharedInstance].textColor;
    
    [self setLabelText:self.adresseLabel text:self.adresseLabel.text minFontSize:minSize maxFontSize:maxSize color:textColor];
    [self setLabelText:self.infoLieuLabel text:self.infoLieuLabel.text minFontSize:minSize maxFontSize:maxSize color:textColor];
    [self setLabelText:self.descriptionLabel text:self.descriptionLabel.text minFontSize:minSize maxFontSize:maxSize color:textColor];
    
    self.adresseButton.titleLabel.font = [[Config sharedInstance] defaultFontWithSize:14];
    
    // HashTag Label
#ifdef HASHTAG_ENABLE
    UIColor *orangeColor = [[Config sharedInstance] orangeColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.hashtagLabel.text];
    NSInteger taille = [self.hashtagLabel.text length];

    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setTextColor:orangeColor range:range];
        range = NSMakeRange(0, 3);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
        range = NSMakeRange(1, taille-1);
        [attributedString setTextColor:textColor range:range];
        range = NSMakeRange(3, taille-3);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
        
        [self.hashtagLabel setAttributedText:attributedString];
    }
    else
    {
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.hashtagLabel.frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:self.hashtagLabel.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // 3 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:maxSize onRange:NSMakeRange(0, 3)];
            
            // Autres Lettres Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:minSize onRange:NSMakeRange(3, taille-3 )];
            
            // 3 first Lettre Couleurs
            [cf updateTTTAttributedString:mutableAttributedString withColor:orangeColor onRange:NSMakeRange(0, 1)];
            
            // Autres Lettres Couleurs
            [cf updateTTTAttributedString:mutableAttributedString withColor:textColor onRange:NSMakeRange(1, taille-1)];
            
            return mutableAttributedString;
        }];
        
        [self.hashtagLabel.superview addSubview:tttLabel];
        self.hashtagLabel.hidden = YES;
        
    }
    
    // Info HashTag Label    
    attributedString = [[NSMutableAttributedString alloc] initWithString:self.infoHashtagLabel.text];
    taille = [self.infoHashtagLabel.text length];
    minSize = 8;
    maxSize = 10;
    
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 52);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
        range = NSMakeRange(52, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
        range = NSMakeRange(53, taille - 53);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
        [attributedString setTextColor:textColor];
        
        [self.infoHashtagLabel setAttributedText:attributedString];
    }
    else
    {
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.infoHashtagLabel.frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        tttLabel.numberOfLines = 9999;
        [tttLabel setText:self.infoHashtagLabel.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:minSize onRange:NSMakeRange(0, 52)];
            
            // #
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:maxSize onRange:NSMakeRange(52, 1 )];
            
            // Autres Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:minSize onRange:NSMakeRange(53, taille-53 )];
            
            // Couleur
            [cf updateTTTAttributedString:mutableAttributedString withColor:textColor onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        [self.infoHashtagLabel.superview addSubview:tttLabel];
        self.infoHashtagLabel.hidden = YES;
        
    }
#else
    self.hashtagLabel.hidden = YES;
    self.hashtagTextField.hidden = YES;
    self.switchButton.hidden = YES;
    self.switchBackground.hidden = YES;
#endif

}

#pragma mark - view Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentStep = 1;
    self.globalScrollView.contentSize = CGSizeMake(320, 2*viewHeight);
    
    // ---- CustomNavigationBar init ----
    [self initNavigationBar];
    
    // ---- Init With Moment ---
    if(self.moment)
    {        
        self.nomEvent = self.moment.titre;
        self.dateDebut = self.moment.dateDebut;
        self.dateFin = self.moment.dateFin;
        self.startDateTextField.text = [self.dateFormatter stringFromDate:self.dateDebut];
        self.endDateTextField.text = [self.dateFormatter stringFromDate:self.dateFin];
        [self setAdresseText:self.moment.adresse];
        self.descriptionTextView.text = self.moment.descriptionString;
        self.coverImage = self.moment.uimage;
        [self.coverView setImage:self.coverImage imageString:self.moment.imageString withSaveBlock:^(UIImage *image) {
            self.coverImage = image;
            self.moment.uimage = image;
        }];
    }
    
    // ---- Step 1 ----
    [self initCover];
    [self initTitreStep1];
    [self initStep1Labels];
    [self initDatePicker];
    [self.globalScrollView addSubview:_step1ScrollView];
    
    // ---- Step 2 ----
    [self placerView:_step2ScrollView atStep:2];
    [self initTitreStep2];
    [self initStep2Labels];
    // Description
    UIImage *image = [[VersionControl sharedInstance] resizableImageFromImage:self.backgroundDescriptionView.image withCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    self.backgroundDescriptionView.image = image;
    self.descriptionTextView.placeholder = @"Description";
    [self.globalScrollView addSubview:_step2ScrollView];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [AppDelegate updateActualViewController:self];
    
    // Cacher clavier
    [self.view endEditing:YES];
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Création Event 1"];
}

#pragma mark - Util

- (BOOL)formIsValid
{
    if( self.dateDebut && self.dateFin &&
        (self.adresseText.length > 0) && (self.descriptionTextView.text.length > 0) )
    {
        return YES;
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Champs invalides"
                                    message:@"Veuillez remplir tous les champs"
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
        
        // Si step 1 pas OK ==> scroll to step 1
        if( !(self.dateDebut && self.dateFin) ) {
            [self clicPrev];
        }
    }
    
    
    return NO;
}

#pragma mark - Actions

- (void)clicNext
{
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Création Event 2"];
    
    // Cacher clavier
    [self.view endEditing:YES];
    
    [self.globalScrollView scrollRectToVisible:CGRectMake(0, _currentStep*viewHeight, 320, viewHeight) animated:YES];
    _currentStep++;
        
    [self updateNavBarForStep:_currentStep];
}

- (void)clicPrev
{
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Création Event 1"];
    
    // Cacher clavier
    [self.view endEditing:YES];
    
    _currentStep--;
    [self updateNavBarForStep:_currentStep];
    [self.globalScrollView scrollRectToVisible:CGRectMake(0, (_currentStep-1)*viewHeight, 320, viewHeight) animated:YES];
}

- (void)datePickerChangeValue
{
    if(self.startDateTextField.isFirstResponder) {
        self.startDateTextField.text = [self.dateFormatter stringFromDate:self.pickerView.datePicker.date];
    }
    else {
        self.endDateTextField.text = [self.dateFormatter stringFromDate:self.pickerView.datePicker.date];
    }
    
    [self updateSecondNavBarEnable];
}

- (void)clicCreate
{
    // Cacher clavier
    [self.view endEditing:YES];
    
    // Update dates
    if ( self.startDateTextField.text.length > 0 )
        self.dateDebut = [self.dateFormatter dateFromString:self.startDateTextField.text];
    if ( self.endDateTextField.text.length > 0 )
        self.dateFin = [self.dateFormatter dateFromString:self.endDateTextField.text];
    
    if([self formIsValid])
    {
        //NSLog(@"Form valide");
        
        //NSLog(@"date envoyée :\ndate début = %@\ndate fin = %@", _dateDebut, _dateFin);
        
        NSMutableDictionary *attributes = @{
        @"adresse":_adresseLabel.text,
        @"titre":_nomEvent,
        @"dateDebut":_dateDebut,
        @"dateFin":_dateFin,
        }.mutableCopy;
        
        if([_infoLieuTextField.text length] > 0)
            attributes[@"infoLieu"] = _infoLieuTextField.text;
        if([_descriptionTextView.text length] > 0)
            attributes[@"descriptionString"] = _descriptionTextView.text;
#ifdef HASHTAG_ENABLE
        if([_hashtagTextField.text length] > 0)
            attributes[@"hashtag"] = _hashtagTextField.text;
#endif
        if(self.moment && self.moment.facebookId)
            attributes[@"facebbokId"] = self.moment.facebookId;
        if(modifiedCover)
            attributes[@"dataImage"] = modifiedCover;
        
        // Mettre à jour Moment Local
        [self.moment setupWithAttributes:attributes];
        // Si nouvelle image, supprimer url pour mettre à jour
        if(modifiedCover) {
            self.moment.imageString = nil;
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
        
        // Edition d'un moment
        if(isEdition)
        {
            [self.moment updateMomentFromLocalToServerWithEnded:^(BOOL success) {
                
                if(success) {
                    
                    [self.timeLineViewContoller.rootOngletsViewController.infoMomentViewController reloadData];
                    [self.timeLineViewContoller reloadData];
                    [self.timeLineViewContoller updateSelectedMoment:self.moment atRow:-1];
                    [self.timeLineViewContoller reloadMomentPicture:self.moment];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:@"Erreur"
                                         message:@"Une erreur est survenue. Veuillez réessayer ultérieurement"
                                        delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil]
                    show];
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }

            }];
        }
        // Création d'un moment
        else
        {
            [MomentClass createMomentWithAttributes:attributes withEnded:^(MomentClass* moment) {
                
                if(moment) {
                    
                    [self.timeLineViewContoller reloadData];
                    
                    // Redimentionner vue
                    [UIApplication sharedApplication].keyWindow.frame=CGRectMake(0, 0, 320, [VersionControl sharedInstance].screenHeight);
                    
                    // ---- Capture d'écran ----
                    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
                    CGRect rect = [keyWindow bounds];
                    
                    UIGraphicsBeginImageContextWithOptions( rect.size ,YES,0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    [keyWindow.layer renderInContext:context];
                    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    CGRect contentRect;
                    if ([[VersionControl sharedInstance] isRetina]) {
                        // Retina
                        contentRect = CGRectMake(0, 2*STATUS_BAR_HEIGHT, 2*rect.size.width, 2*(rect.size.height-STATUS_BAR_HEIGHT));
                    } else {
                        // Not Retina
                        contentRect = CGRectMake(0, STATUS_BAR_HEIGHT, rect.size.width, (rect.size.height-STATUS_BAR_HEIGHT));
                    }
                    CGImageRef imageRef = CGImageCreateWithImageInRect([capturedScreen CGImage], contentRect );
                    
                    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    //  ---- Popup ----
                    PopUpFinCreationViewController *popup = [[PopUpFinCreationViewController alloc]
                                                             initWithRootViewController:self withMoment:moment
                                                             withTimeLine:self.timeLineViewContoller
                                                             withBackground:croppedImage];
                    [self.navigationController pushViewController:popup animated:NO];
                     
                    
                }else{
                    [[[UIAlertView alloc] initWithTitle:@"Erreur"
                                                message:@"Une erreur est survenue. Veuillez réessayer ultérieurement"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil]
                     show];
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            }];
        }
        
    }
    
}

- (IBAction)clicChangeCover
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"ActionSheet_PeekPhoto_Title", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"ActionSheet_PeekPhoto_Button_Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  NSLocalizedString(@"ActionSheet_PeekPhoto_Button_PhotoLibrary", nil),
                                  NSLocalizedString(@"ActionSheet_PeekPhoto_Button_Camera", nil),
                                  nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (IBAction)clicSwitch
{
    self.switchControlState = !self.switchControlState;
    NSInteger position = self.switchControlState? 260 : 227;
    
    CGRect frame = self.switchButton.frame;
    frame.origin.x = position;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.switchButton.frame = frame;
    }];
}

- (void)clicValiderPickerView
{
    if([self.startDateTextField isFirstResponder]) {
        [self.endDateTextField becomeFirstResponder];
    }
    else if([self.endDateTextField isFirstResponder]) {
        [self.endDateTextField resignFirstResponder];
    }
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(_currentStep == 2)
    {
#ifdef HASHTAG_ENABLE
        if(textField == _infoLieuTextField) {
            [_hashtagTextField becomeFirstResponder];
        }
        else {
            [textField resignFirstResponder];
        }
#else
        [textField resignFirstResponder];
#endif
        
        return YES;
    }
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if((_currentStep == 1) && (textField.text.length > 0)) {

        // On stocke la date
        if(textField == self.startDateTextField) {
            self.dateDebut = self.pickerView.datePicker.date;
        }
        else {
            self.dateFin = self.pickerView.datePicker.date;
        }
        
    }
    
    [self updateSecondNavBarEnable];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(_currentStep == 1) {
        
        NSDate *today = [NSDate date];
        
        if( [self.pickerView.datePicker.minimumDate isLaterThan:today] ) {
            self.pickerView.datePicker.date = self.pickerView.datePicker.minimumDate;
        } else {
            self.pickerView.datePicker.date = today;
        }
        
        if(textField == self.startDateTextField)
            self.dateDebut = nil;
        else
            self.dateFin = nil;
        
        [self setNavBarSecondButtonEnable:NO];
        
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( _currentStep == 1 )
    {
        
        BOOL startIsFull = self.startDateTextField.text.length > 0;
        BOOL endIsFull = self.endDateTextField.text.length > 0;
        
        // Si on sélectionne la date de fin et qu'on a fixé une date de début, on fixe une date minimum
        if( textField == self.endDateTextField ) {
            
            [self.pickerView setButtonStyle:CustomDatePickerButtonStyleDone];
            
            if(startIsFull)
                self.pickerView.datePicker.minimumDate = [self.dateDebut dateByAddingTimeInterval:15*60];
        }
        // Si on sélectionne la date de début et qu'on a fixé une date de fin, on fixe une date maximum
        else if( textField == self.startDateTextField ) {
            
            [self.pickerView setButtonStyle:CustomDatePickerButtonStyleNext];
            
            if(endIsFull)
                self.pickerView.datePicker.maximumDate = [self.dateFin dateByAddingTimeInterval:-15*60];;
        }
        
        // Rénitialise date min
        if(!startIsFull)
            self.pickerView.datePicker.minimumDate = nil;
        
        // Réninitialise date max
        if(!endIsFull)
            self.pickerView.datePicker.maximumDate = nil;
        
        // Charge nouvelle date
        if([textField.text length] > 0) {
            
            if(self.startDateTextField == textField) {
                self.pickerView.datePicker.date = self.dateDebut;
                self.pickerView.datePicker.minimumDate = nil;
            }
            else {
                self.pickerView.datePicker.date = self.dateFin;
                self.pickerView.datePicker.maximumDate = nil;
            }
        }
        
        if( [VersionControl sharedInstance].screenHeight == 480 )
            [_step1ScrollView adjustOffsetToIdealIfNeeded];
        
    }
    else {
        [_step2ScrollView adjustOffsetToIdealIfNeeded];
    }
}

- (void)updateSecondNavBarEnable
{
    if(_currentStep == 2) {
        
        if( ((self.adresseLabel.text.length > 0)||(self.adresseText.length > 0)) && (self.descriptionTextView.text.length > 0) ) {
            [self setNavBarSecondButtonEnable:YES];
        }
        else {
            [self setNavBarSecondButtonEnable:NO];
        }
    }
    else {
        if( (self.startDateTextField.text.length > 0) && (self.endDateTextField.text.length > 0) ) {
            [self setNavBarSecondButtonEnable:YES];
        }
        else {
            [self setNavBarSecondButtonEnable:NO];
        }
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{    
    if(_currentStep == 1)
        return NO;
            
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(_currentStep == 1)
        return NO;
    
    // Check if textField empty
    if( textView == self.descriptionTextView ) {
        
        
        
        NSRange textFieldRange = NSMakeRange(0, [textView.text length]);
        if (NSEqualRanges(range, textFieldRange) && [text length] == 0) {
            [self setNavBarSecondButtonEnable:NO];
        }
        else  {
            
            NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
            
            if(newText.length > 0 && ((self.adresseLabel.text.length > 0)||(self.adresseText.length > 0)) ) {
                [self setNavBarSecondButtonEnable:YES];
            }

            
        }
    
    }
    
    return YES;
}

#pragma mark - UIImagePickerController Delegate

-(void) imagePickerController:(UIImagePickerController *)UIPicker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    UIImage *image = [[Config sharedInstance] imageWithMaxSize:info[@"UIImagePickerControllerOriginalImage"] maxSize:600];
    
    self.coverImage = image;
    modifiedCover = image;
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.image = image;
    
    [[VersionControl sharedInstance] dismissModalViewControllerFromRoot:UIPicker animated:YES];
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
        return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
            
    // Album photo
    if(buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [[VersionControl sharedInstance] presentModalViewController:picker fromRoot:self animated:YES];
}

#pragma mark - Getters & Setters

- (NSDateFormatter*)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"dd'/'MM'/'yyyy' - 'HH':'mm";
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
        _dateFormatter.calendar = [NSCalendar currentCalendar];
        _dateFormatter.timeZone = [NSTimeZone localTimeZone];
    }
    return _dateFormatter;
}

- (void)setAdresseText:(NSString *)adresseText {
    _adresseText = adresseText;
    
    NSInteger maxSize = 15, minSize = 11;
    UIColor *textColor = [Config sharedInstance].textColor;
    
    [self setLabelText:self.adresseLabel text:adresseText minFontSize:minSize maxFontSize:maxSize color:textColor];
    
    // Activer bouton si champs obligatoires remplis
    if(_currentStep == 2 && adresseText.length > 0 && self.descriptionTextView.text.length > 0) {
        [self setNavBarSecondButtonEnable:YES];
    }
}

#pragma mark - Actions

- (IBAction)clicPlaces {
    
    // Google Places
    PlacesViewController *places = [[PlacesViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:places animated:YES];
    
}

- (void)viewDidUnload {
    [self setAdresseButton:nil];
    [self setSwitchBackground:nil];
    [super viewDidUnload];
}
@end
