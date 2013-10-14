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
#import "CustomNavigationBarButton.h"

@interface CreationFicheViewController () {
    @private
    BOOL isEdition;
    BOOL adresseTextFieldShouldClear;
    BOOL alreadyClicked;
    
    UIImage *modifiedCover;
}

@end

@implementation CreationFicheViewController

#pragma mark - Init

- (void)updateNavBarForStep:(NSInteger)step
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    
    if([buttons count] == 1)
    {
        //UIImage *normal = nil;//, *selected = nil;
        NSString *normal = nil;
        UIColor *colorEnable = [Config sharedInstance].orangeColor;
        UIColor *colorDisabled = [Config sharedInstance].textColor;
        SEL action = NULL, backButton = NULL;
        BOOL secondButtonEnable = NO;
        
        // Second Button
        //UIButton *button = (UIButton*)[buttons[0] customView];
        //CustomNavigationBarButton *button = [[CustomNavigationBarButton alloc] initWithFrame:[buttons[0] customView].frame andIsLeftButton:NO];
        CustomNavigationBarButton *button = (CustomNavigationBarButton*)[buttons[0] customView];
        
        // Previous Button
        //UIButton *previousButton = (UIButton*)[buttons[1] customView];
                
        if(step == 1)
        {
            // Button Next
            //normal = [UIImage imageNamed:@"topbar_arrow_down_enable.png"];
            normal = [NSString stringWithFormat:NSLocalizedString(@"Next", nil)];
            action = @selector(clicNext);
            
            // Button Previous Disabled
            /*[UIView animateWithDuration:0.3 animations:^{
                button.alpha = 0;
                button.alpha = 1;
                previousButton.alpha = 0;
            }];
            [previousButton setEnabled:NO];*/
            
            // Second Button enable
            if( ((self.startDateTextField.text.length > 0) && (self.endDateTextField.text.length > 0)) ||
               (self.moment.dateDebut && self.moment.dateFin && [self.moment.dateDebut isEarlierThan:self.moment.dateFin]) ) {
                secondButtonEnable = YES;
            }
            
            //[[button subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            //NSArray *subviews = [self listSubviewsOfView:button];
            //NSLog(@"subviews = %@", subviews);
            [self removeSubviewsOfView:button];
            
            
            //[button setFrame:CGRectMake(0, 0, 70, 43)];
            [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, 90, 43)];
        }
        else
        {
            /*if(previousButton.hidden)
                previousButton.hidden = NO;*/
            
            // Button Valider
            //normal = [UIImage imageNamed:@"topbar_valider.png"];
            normal = [NSString stringWithFormat:NSLocalizedString(@"Finish", nil)];
            action = @selector(clicCreate);
            backButton = @selector(clicPrev);
            
            // Button Previous Enable
            /*[UIView animateWithDuration:0.3 animations:^{
                button.alpha = 1;
                button.alpha = 0;
                button.alpha = 1;
                previousButton.alpha = 1;
            }];
            [previousButton setEnabled:YES];*/
            
            // Second Button enable
            // Adresse et Description non obligatoire maintenant
            /*if( ((self.adresseLabel.text.length > 0)||(self.adresseText.length > 0)) && (self.descriptionTextView.text.length > 0) ) {
                secondButtonEnable = YES;
            }*/
            secondButtonEnable = YES;
            
            /*UIView *whiteLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 42.5)];
            UIView *darkGrayLine = [[UIView alloc] initWithFrame:CGRectMake(0.5, 0, 0.5, 42.5)];
            UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 0.5, 42.5)];
            whiteLine.backgroundColor = [UIColor colorWithHex:0xFDFDFD];
            darkGrayLine.backgroundColor = [UIColor colorWithHex:0xB8B8B8];
            grayLine.backgroundColor = [UIColor colorWithHex:0xBBBBBB];
            [button addSubview:whiteLine];
            [button addSubview:darkGrayLine];
            [button addSubview:grayLine];
            
            [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, 85, 43)];*/
        }
        
        // Navigation bar
        [CustomNavigationController setBackButtonChevronWithViewController:self withNewBackSelector:backButton];
        
        // Update
        //[button setBackgroundColor:[UIColor cyanColor]];
        //NSLog(@"Button Frame = %@", NSStringFromCGRect(button.frame));
        [button.titleLabel setFont:[[Config sharedInstance] defaultFontWithSize:16]];
        [button setTitle:normal forState:UIControlStateNormal];
        [button setTitleColor:colorDisabled forState:UIControlStateDisabled];
        [button setTitleColor:colorEnable forState:UIControlStateNormal];
        [button.titleLabel setTextAlignment:NSTextAlignmentRight];
        [button removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [button setEnabled:secondButtonEnable];
    }
    
}

- (void)setNavBarSecondButtonEnable:(BOOL)enable
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    CustomNavigationBarButton *button = (CustomNavigationBarButton*)[buttons[0] customView];
    
    [button setEnabled:enable];
}

- (void)removeSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if (subviews.count != 0) {
        for (UIView *subview in subviews) {
            
            if (![[[subview class] description] isEqualToString:@"UIButtonLabel"]) {
                [subview removeFromSuperview];
            }
        }
    }
}

/*- (NSArray *)listSubviewsOfView:(UIView *)view {
    NSMutableArray *subviewToReturn = [NSMutableArray array];
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return nil;
    
    for (UIView *subview in subviews) {
        
        [subviewToReturn addObject:subview];
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
    
    return subviewToReturn;
}*/

- (id)initWithUser:(UserClass*)user withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    NSString *nibName = ([VersionControl sharedInstance].isIphone5)? @"CreationFicheViewController_4" : @"CreationFicheViewController_3_5";
    
    self = [super initWithNibName:nibName bundle:nil];
    if(self) {
        
        self.user = user;
        self.timeLineViewContoller = timeLine;
        viewHeight = [[VersionControl sharedInstance] screenHeight] - TOPBAR_HEIGHT;
        adresseTextFieldShouldClear = NO;
        alreadyClicked = NO;
        
        self.switchControlState = YES;
        
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    }
    return self;
}

- (id)initWithUser:(UserClass*)user withEventName:(NSString*)eventName withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [self initWithUser:user withTimeLine:timeLine];
    if(self) {
        self.nomEvent = eventName;
        isEdition = NO;
        
        [self initCover];
    }
    return self;
}

- (id)initWithUser:(UserClass*)user withMoment:(MomentClass*)moment withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [self initWithUser:user withTimeLine:timeLine];
    if(self) {
        self.moment = moment;
        isEdition = YES;
        
        
        
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
        
        [self initCover];
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
    //[CustomNavigationController setBackButtonWithViewController:self];
    
    //[CustomNavigationController setBackButtonWithTitle:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"Back", nil)] andColor:[UIColor grayColor] andFont:[[Config sharedInstance] defaultFontWithSize:16] withViewController:self withSelector:@selector(popViewControllerAnimated:) andWithTarget:nil];
    //[CustomNavigationController setBackButtonWithImage:[UIImage imageNamed:@"Navigation-Left.png"] withViewController:self withSelector:@selector(popViewControllerAnimated:) andWithTarget:nil];
    
    [CustomNavigationController setTitle:@"Création" withColor:[Config sharedInstance].orangeColor withViewController:self];
    
    CGRect frameButton = CGRectMake(0,0,43,43);
    
    // Bouton Previous
    ////UIButton *buttonPrevious = [[UIButton alloc] initWithFrame:frameButton];
    //UIImage *arrow_up_disable = [UIImage imageNamed:@"topbar_arrow_up_disable.png"];
    //UIColor *arrow_up_disable = [UIColor darkGrayColor];
    ////UIImage *arrow_up_normal = [UIImage imageNamed:@"topbar_arrow_up_enable.png"];
    //UIColor *arrow_up_normal = [UIColor colorWithHex:0xD28000];
    //[buttonPrevious setTitle:@"Précédent" forState:UIControlStateNormal];
    //[buttonPrevious setImage:arrow_up_disable forState:UIControlStateDisabled];
    //[buttonPrevious setTitleColor:arrow_up_disable forState:UIControlStateDisabled];
    ////[buttonPrevious setImage:arrow_up_normal forState:UIControlStateNormal];
    //[buttonPrevious setTitleColor:arrow_up_normal forState:UIControlStateNormal];
    ////[buttonPrevious addTarget:self action:@selector(clicPrev) forControlEvents:UIControlEventTouchUpInside];
    ////buttonPrevious.hidden = YES;
    //[buttonPrevious setBackgroundColor:[UIColor redColor]];
    ////UIBarButtonItem *buttonItemPrevious = [[UIBarButtonItem alloc] initWithCustomView:buttonPrevious];
    
    // 2e bouton
    //UIButton *secondButton = [[UIButton alloc] initWithFrame:frameButton];
    CustomNavigationBarButton *secondButton = [[CustomNavigationBarButton alloc] initWithFrame:frameButton andIsLeftButton:NO];
    UIBarButtonItem *secondBarButton = [[UIBarButtonItem alloc] initWithCustomView:secondButton];
    
    // Set buttons
    self.navigationItem.rightBarButtonItems = @[secondBarButton];//, buttonItemPrevious];
    
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
        
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
        range = NSMakeRange(1, [attributedString length]-1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
        [attributedString setTextColor:color];
        
        [label setAttributedText:attributedString];
    }
    return label;
}

- (void)designTitreLabel:(CustomLabel*)label
{
    NSString *texteLabel = label.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
    NSInteger maxSize = 18, minSize = 14;
    
    // Attributs du label
    NSRange range = NSMakeRange(0, 1);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
    [attributedString setTextColor:[Config sharedInstance].orangeColor range:range];
    range = NSMakeRange(1, taille-2);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
    range = NSMakeRange(1, taille-1);
    [attributedString setTextColor:[[Config sharedInstance] textColor] range:range];
    range = NSMakeRange(taille-2, 1);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
    
    [label setAttributedText:attributedString];
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
    
    [self.changerCoverButton setTitle:NSLocalizedString(@"CreationFicheViewController_ChangeCover", nil) forState:UIControlStateNormal];
    self.changerCoverButton.titleLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
    self.changerCoverButton.titleLabel.textColor = [Config sharedInstance].orangeColor;
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
    UIColor *orangeColor = [Config sharedInstance].orangeColor;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.hashtagLabel.text];
    NSInteger taille = [self.hashtagLabel.text length];

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
    
    // Info HashTag Label
    attributedString = [[NSMutableAttributedString alloc] initWithString:self.infoHashtagLabel.text];
    taille = [self.infoHashtagLabel.text length];
    minSize = 8;
    maxSize = 10;
    
    // Attributs du label
    NSRange range = NSMakeRange(0, 52);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
    range = NSMakeRange(52, 1);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:maxSize] range:range];
    range = NSMakeRange(53, taille - 53);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:minSize] range:range];
    [attributedString setTextColor:textColor];
    
    [self.infoHashtagLabel setAttributedText:attributedString];
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
    
    if ([VersionControl sharedInstance].supportIOS7) {
        CGRect frame = self.view.frame;
        frame.origin.y += STATUS_BAR_HEIGHT;
        self.view.frame = frame;
        
        viewHeight += STATUS_BAR_HEIGHT;
    }
    
    self.currentStep = 1;
    self.globalScrollView.contentSize = CGSizeMake(320, 2*viewHeight);
    
    // ---- Step 1 ----
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ---- CustomNavigationBar init ----
    [self initNavigationBar];
}
#pragma mark - Util

- (BOOL)formIsValid
{
    if( self.dateDebut && self.dateFin )
    //&& (self.adresseText.length > 0) && (self.descriptionTextView.text.length > 0) ) // Adresse et Description NON obligatoire maintenant
    {
        return YES;
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Champs invalides"
                                    message:@"Veuillez remplir tous les champs obligatoires"
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
    
    if ([VersionControl sharedInstance].supportIOS7) {
        [self.globalScrollView scrollRectToVisible:CGRectMake(0, self.currentStep*viewHeight-STATUS_BAR_HEIGHT, 320, viewHeight) animated:YES];
    } else {
        [self.globalScrollView scrollRectToVisible:CGRectMake(0, self.currentStep*viewHeight, 320, viewHeight) animated:YES];
    }
    self.currentStep++;
        
    [self updateNavBarForStep:self.currentStep];
    
    //[CustomNavigationController setBackButtonWithTitle:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"Back", nil)] andColor:[UIColor grayColor] andFont:[[Config sharedInstance] defaultFontWithSize:16] withViewController:self withSelector:@selector(clicPrev) andWithTarget:self];
    //[CustomNavigationController setBackButtonWithImage:[UIImage imageNamed:@"Navigation-Left.png"] withViewController:self withSelector:@selector(clicPrev) andWithTarget:self];
}

- (void)clicPrev
{
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Création Event 1"];
    
    // Cacher clavier
    [self.view endEditing:YES];
    
    self.currentStep--;
    [self updateNavBarForStep:self.currentStep];
    [self.globalScrollView scrollRectToVisible:CGRectMake(0, (self.currentStep-1)*viewHeight, 320, viewHeight) animated:YES];
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
    // Empecher le clic successif sur le bouton
    if(!alreadyClicked)
    {
        alreadyClicked = YES;
        
        // Cacher clavier
        [self.view endEditing:YES];
        
        // Update dates
        if ( self.startDateTextField.text.length > 0 )
            self.dateDebut = [self.dateFormatter dateFromString:self.startDateTextField.text];
        if ( self.endDateTextField.text.length > 0 )
            self.dateFin = [self.dateFormatter dateFromString:self.endDateTextField.text];
        
        if([self formIsValid])
        {
            
            NSMutableDictionary *attributes = @{
                                                @"titre":_nomEvent,
                                                @"dateDebut":_dateDebut,
                                                @"dateFin":_dateFin,
                                                }.mutableCopy;
            
            if([_adresseLabel.text length] > 0)
                attributes[@"adresse"] = _adresseLabel.text;
            if([_infoLieuTextField.text length] > 0)
                attributes[@"infoLieu"] = _infoLieuTextField.text;
            if([_descriptionTextView.text length] > 0)
                attributes[@"descriptionString"] = _descriptionTextView.text;
#ifdef HASHTAG_ENABLE
            if([_hashtagTextField.text length] > 0)
                attributes[@"hashtag"] = _hashtagTextField.text;
#endif
            if(self.moment && self.moment.facebookId)
                attributes[@"facebookId"] = self.moment.facebookId;
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
                        alreadyClicked = NO;
                        
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
                        alreadyClicked = NO;
                        
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
        else {
            alreadyClicked = NO;
        }
        
    }// Fin Already CLicked
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
    
    if(self.currentStep == 2)
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
    if((self.currentStep == 1) && (textField.text.length > 0)) {

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
    if(self.currentStep == 1) {
        
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
    if(self.currentStep == 1 )
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
                self.pickerView.datePicker.maximumDate = [self.dateFin dateByAddingTimeInterval:-15*60];
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
        } else {
            
            if(self.startDateTextField == textField) {
                [self.startDateTextField setText:[self.dateFormatter stringFromDate:[self getRoundedDate:self.pickerView.datePicker.date]]];
            } else {
                [self.endDateTextField setText:[self.dateFormatter stringFromDate:[self getRoundedDate:self.pickerView.datePicker.date]]];
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
    if(self.currentStep == 2) {
        
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
    if(self.currentStep == 1)
        return NO;
            
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(self.currentStep == 1)
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
    
    [UIPicker dismissViewControllerAnimated:YES completion:nil];
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
    
    [self presentViewController:picker animated:YES completion:nil];
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

- (NSDate *)getRoundedDate:(NSDate *)inDate
{
    NSInteger minuteInterval = 15;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:inDate];
    NSInteger minutes = [dateComponents minute];
    
    float minutesF = [[NSNumber numberWithInteger:minutes] floatValue];
    float minuteIntervalF = [[NSNumber numberWithInteger:minuteInterval] floatValue];
    
    // Determine whether to add 0 or the minuteInterval to time found by rounding down
    NSInteger roundingAmount = (fmodf(minutesF, minuteIntervalF)) > minuteIntervalF/2.0 ? minuteInterval : 0;
    NSInteger minutesRounded = ( (NSInteger)(minutes / minuteInterval) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded + roundingAmount - minutes) sinceDate:inDate];
    
    return roundedDate;
}

- (void)setAdresseText:(NSString *)adresseText {
    _adresseText = adresseText;
    
    NSInteger maxSize = 15, minSize = 11;
    UIColor *textColor = [Config sharedInstance].textColor;
    
    [self setLabelText:self.adresseLabel text:adresseText minFontSize:minSize maxFontSize:maxSize color:textColor];
    
    // Activer bouton si champs obligatoires remplis
    if(self.currentStep == 2 && adresseText.length > 0 && self.descriptionTextView.text.length > 0) {
        [self setNavBarSecondButtonEnable:YES];
    }
}

#pragma mark - Actions

- (IBAction)clicPlaces {
    
    // Google Places
    PlacesViewController *places = [[PlacesViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:places animated:YES];
    
}

@end
