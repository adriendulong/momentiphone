//
//  TimeLineViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "TimeLineViewController.h"
#import "InfoMomentViewController.h"
#import "Config.h"

#import "NSMutableAttributedString+FontAndTextColor.h"
#import "TTTAttributedLabel.h"
#import "NSDate+NSDateAdditions.h"
#import "MomentClass+Server.h"
#import "VersionControl.h"

#define bigCellHeight 263
#define smallCellHeight 130

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

#pragma mark - Reverse Array

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end

#pragma mark - TimeLineViewController

enum ClockState {
    ClockStateUp = 0,
    ClockStateDown = 1
    };

@implementation TimeLineViewController {
    //BOOL shouldUpdateClock;
    enum ClockState arrowClockActualState;
    BOOL bandeauAnimating;
    
    NSInteger rowForToday;
    BOOL beforeToday;
    
    CGFloat borderCellSize;
    BOOL isLoading;
    BOOL firstLoad;
    BOOL shouldReloadMoments;
    
    MomentClass *momentToDelete;
    
    UIImageView *overlay;
    UIButton *overlay_button;
}

@synthesize rootOngletsViewController = _rootOngletsViewController;
@synthesize tableView = _tableView;
@synthesize rootViewController = _rootViewController;
@synthesize navController = _navController;

@synthesize moments = _moments;
@synthesize user = _user;
@synthesize selectedIndex = _selectedIndex;
@synthesize size = _size;
@synthesize selectedMoment = _selectedMoment;
@synthesize shoulShowInviteView = _shoulShowInviteView;

@synthesize bandeauTitre = _bandeauTitre;
@synthesize bandeauIndex = _bandeauIndex;
@synthesize nomMomentLabel = _nomMomentLabel;
@synthesize nomOwnerLabel = _nomOwnerLabel;
@synthesize fullDateLabel = _fullDateLabel;
@synthesize nomMomentTTLabel = _nomMomentTTLabel;
@synthesize nomOwnerTTLabel = _nomOwnerTTLabel;
@synthesize fullDateTTLabel = _fullDateTTLabel;
@synthesize timeScroller = _timeScroller;
@synthesize B2PButton = _B2PButton;

@synthesize echelleFuturLabel = _echelleFuturLabel;
@synthesize echellePasseLabel = _echellePasseLabel;
@synthesize echelleTodayLabel = _echelleTodayLabel;

@synthesize overlay = _overlay;
@synthesize overlay_button = _overlay_button;

#pragma mark - Init

- (NSArray*)arrayWithEmptyObjectsAddedToArray:(NSArray*)array
{
    NSMutableArray *m = array.mutableCopy;
    [m addObject:[NSNull null]];
    [m insertObject:[NSNull null] atIndex:0];
    return m;
}

- (NSInteger)calculRowForToday:(NSArray*)moments beforeToday:(BOOL*)isBefore
{
    if([moments count] > 0) {
        NSInteger row = 0, tempRow = -1;
        NSDate *today = [NSDate date];
        NSTimeInterval timeInterval = [((MomentClass*)moments[0]).dateDebut timeIntervalSinceDate:today], temp = 0;
        
        for(MomentClass *m in moments)
        {
            tempRow++;
            temp = [m.dateDebut timeIntervalSinceDate:today];
            if ( abs(temp) < abs(timeInterval) ) {
                row = tempRow;
                timeInterval = temp;
            }
        }
        
        // Pour identifier si le moment est avant ou après aujourd'hui
        *isBefore = (timeInterval < 0)? YES : NO;
        
        return row + 1;
    }
    return nil;
}

- (id)initWithMoments:(NSArray*)momentsParam
            withStyle:(enum TimeLineStyle)style
             withUser:(UserClass*)user
             withSize:(CGSize)size
withRootViewController:(RootTimeLineViewController*)rootViewController
  shouldReloadMoments:(BOOL)reloadMoments
{    
    self = [super initWithNibName:@"TimeLineViewController" bundle:nil];
    if(self) {

        // Init
        self.moments = [self arrayWithEmptyObjectsAddedToArray:momentsParam];
        if(style == TimeLineStyleProfil)
            self.user = user;
        else
            self.user = [UserCoreData getCurrentUser];
        self.selectedMoment = nil;
        self.selectedIndex = -1;
        self.bandeauIndex = -1;
        arrowClockActualState =  ClockStateUp;
        rowForToday = [self calculRowForToday:momentsParam beforeToday:&beforeToday];
        //shouldUpdateClock= YES;
        bandeauAnimating = NO;
        isLoading = NO;
        firstLoad = YES;
        shouldReloadMoments = reloadMoments;
        self.shoulShowInviteView = NO;
        self.rootViewController = rootViewController;
        momentToDelete = nil;
        
        // Style TimeLine
        self.timeLineStyle = style;
        
        // Taille de la vue
        self.size = size;
        
        // Observer les changements de la cover
        if(style == TimeLineStyleComplete)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(notifChangeCover:)
                                                         name:kNotificationChangeCover
                                                       object:nil];
        }
        
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

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.masksToBounds  = NO;
}

- (void)sendEchelleLabelsToBack
{
    /*
    // Placer en fond
    [self.tableView sendSubviewToBack:self.echelleFuturLabel];
    [self.tableView sendSubviewToBack:self.echellePasseLabel];
    [self.tableView sendSubviewToBack:self.echelleTodayLabel];
     */
}

- (void)placerEchelleLabels
{
    // -- Echelle Labels
    CGFloat contentWidth = self.view.frame.size.width;
    CGFloat contentHeight = self.view.frame.size.height;
    CGFloat division = 5.0f;
    /*
    CGRect todayRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:rowForToday inSection:0]];
    CGFloat originToday = todayRect.origin.y - todayRect.size.height/2.0f;
    
    // Placer sur la tableView
    if(self.echelleFuturLabel.superview != self.tableView)
    {
        // Remove parent
        [self.echelleFuturLabel removeFromSuperview];
        [self.echellePasseLabel removeFromSuperview];
        [self.echelleTodayLabel removeFromSuperview];
        
        // Attach
        [self.tableView addSubview:self.echelleFuturLabel];
        [self.tableView addSubview:self.echellePasseLabel];
        [self .tableView addSubview:self.echelleTodayLabel];
        [self.tableView sendSubviewToBack:self.tableView.backgroundView];
    }
     */
    
    //[self sendEchelleLabelsToBack];
    
    // Futur
    UIFont *echelleFont = [[Config sharedInstance] defaultFontWithSize:10];
    self.echelleFuturLabel.textColor = [UIColor whiteColor];
    [self addShadowToView:self.echelleFuturLabel];
    self.echelleFuturLabel.font = echelleFont;
    self.echelleFuturLabel.text = NSLocalizedString(@"TimeLineViewController_Echelle_FuturLabel", nil);
    [self.echelleFuturLabel sizeToFit];
    CGRect frame = self.echelleFuturLabel.frame;
    frame.origin.x = contentWidth - frame.size.width - 5;
    //frame.origin.y = (division-1)*(contentHeight - frame.size.height)/division + originToday;
    frame.origin.y = 5*(contentHeight - frame.size.height)/6.0;
    self.echelleFuturLabel.frame = frame;
    
    // Today
    self.echelleTodayLabel.textColor = [UIColor whiteColor];
    [self addShadowToView:self.echelleTodayLabel];
    self.echelleTodayLabel.font = echelleFont;
    self.echelleTodayLabel.text = NSLocalizedString(@"TimeLineViewController_Echelle_TodayLabel", nil);
    [self.echelleTodayLabel sizeToFit];
    frame = self.echelleTodayLabel.frame;
    frame.origin.x = contentWidth - frame.size.width - 5;
    //frame.origin.y = (contentHeight - frame.size.height)/2.0f + originToday;
    frame.origin.y = (contentHeight - frame.size.height)/2.0;
    self.echelleTodayLabel.frame = frame;
    
    // Passé
    self.echellePasseLabel.textColor = [UIColor whiteColor];
    [self addShadowToView:self.echellePasseLabel];
    self.echellePasseLabel.font = echelleFont;
    self.echellePasseLabel.text = NSLocalizedString(@"TimeLineViewController_Echelle_PasseLabel", nil);
    [self.echellePasseLabel sizeToFit];
    frame = self.echellePasseLabel.frame;
    frame.origin.x = contentWidth - frame.size.width - 5;
    //frame.origin.y =  (contentHeight - frame.size.height)/division + originToday;
    frame.origin.y = (contentHeight - frame.size.height)/6.0;
    self.echellePasseLabel.frame = frame;
}

- (void)drawBackground:(UIImage*)backgroundImage
{
    // Image de fond
    if(self.timeLineStyle == TimeLineStyleComplete)
    {
        UIGraphicsBeginImageContext(self.view.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // TableView Background Image
        backgroundImage = [[Config sharedInstance] scaleAndCropImage:backgroundImage forSize:self.view.frame.size];
        [backgroundImage drawInRect:self.tableView.frame];
        
        // Ligne Blanche au milieu
        CGContextSetStrokeColorWithColor(context, [[[UIColor whiteColor] colorWithAlphaComponent:0.4] CGColor] );
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, (self.size.width-1)/2.0, 0);
        CGContextAddLineToPoint(context, (self.size.width-1)/2.0, self.size.height);
        CGContextSetLineWidth(context, 2);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextStrokePath(context);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    else
        self.view.backgroundColor = [UIColor clearColor];
}

// Etre informé quand la cover change pour updater
- (void)notifChangeCover:(NSNotification*)notification
{
    [self drawBackground:notification.object];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    // Navigation controller
    self.navController =  self.rootViewController.navigationController ?: self.navigationController;
    
    self.view.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // Allocation tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelection = YES;
    self.tableView.clipsToBounds = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self.view sendSubviewToBack:self.tableView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Border Cell Size
    borderCellSize = self.view.frame.size.height/3.0;
    
    // Background -> Récupérer image from data
    [self drawBackground:[Config sharedInstance].coverImage];
    
    // Cacher bandeau de base
    self.bandeauTitre.alpha = 0;
    CGRect frame = self.bandeauTitre.frame;
    frame.origin.y -= frame.size.height;
    self.bandeauTitre.frame = frame;
    /*
    frame.origin.y += frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.bandeauTitre.alpha = 1;
        self.bandeauTitre.frame = frame;
    }];
    */
    
    // Bouton clock repositionnement - Support iPhone 5
    frame = self.B2PButton.frame;
    if(self.timeLineStyle == TimeLineStyleComplete) {
        frame.origin.y = self.size.height - frame.size.height - 63;
    }
    else {
        frame.origin.y = self.size.height - frame.size.height - 10;
    }
    self.B2PButton.frame = frame;
    
    //[self updateArrowClockToState:(self.view.frame.size.height/2.0 > rowForToday*smallCellHeight)?ClockStateUp:ClockStateDown animated:NO];
    
    // Update Arrow Center
    //self.arrowButton.layer.anchorPoint =  CGPointMake(0, 0);
    
    //[self hideScrollBar];
    
    // Time Scroller
    self.timeScroller = [[CustomTimeScroller alloc] initWithDelegate:self withTableView:self.tableView];
    self.timeScroller.frame = CGRectMake(self.view.frame.size.width - self.timeScroller.frame.size.width + 10, (self.view.frame.size.height - self.timeScroller.frame.size.height)/2.0f, self.timeScroller.frame.size.width, self.timeScroller.frame.size.height );
    [self.view addSubview:self.timeScroller];
    
    
    // Select Cell
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowForToday inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self.timeScroller scrollViewDidEndDecelerating];
    self.B2PButton.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
    
    // Placer labels
    [self placerEchelleLabels];
    
    //Premier lancement de l'application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasRunOnce = [defaults boolForKey:@"hasRunOnce"];
    NSLog(hasRunOnce ? @"Yes" : @"No");
    if (!hasRunOnce)
    {
        // Start Reload Moment
        if(shouldReloadMoments && !isLoading) {
            [self reloadDataWithWaitUntilFinished:NO withEnded:^(BOOL success) {
                [self showTutorialOverlayWithFrame:CGRectMake(0, -20, screenSize.width, screenSize.height)];
            }];
        }
        else {
            [self showTutorialOverlayWithFrame:CGRectMake(0, -20, screenSize.width, screenSize.height)];
        }
        
    }
    else {
        
        // Start Reload Moment
        if(shouldReloadMoments && !isLoading) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading_Moments", nil);
            [self reloadDataWithWaitUntilFinished:NO withEnded:^(BOOL success) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }
        else {
            // Update timeScroller
            [self.timeScroller scrollViewDidScroll];
        }
    }
    
    firstLoad = NO;
}

- (void)viewDidUnload
{
    [self setUser:nil];
    [self setMoments:nil];
    [self setSelectedMoment:nil];
    [self setTimeScroller:nil];
    [self setEchelleFuturLabel:nil];
    [self setEchelleTodayLabel:nil];
    [self setEchellePasseLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppDelegate updateActualViewController:self];
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [TimeLineViewController sendGoogleAnalyticsView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    // Remove notification
    if(self.timeLineStyle == TimeLineStyleComplete)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationChangeCover object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Google Analytics

+ (void)sendGoogleAnalyticsView {
    [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Timeline"];
}

+ (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Timeline"
     withAction:action
     withLabel:label
     withValue:value];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.moments count] <= 2) {
        self.B2PButton.enabled = NO;
        self.B2PButton.hidden = YES;
    }
    else if(!self.B2PButton.enabled) {
        self.B2PButton.enabled = YES;
        self.B2PButton.hidden = NO;
    }
    
    return [self.moments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    UITableViewCell *cell = nil;
    
    // 1er ou Derniere cell
    if( (indexPath.row == 0) || (indexPath.row == [self.moments count]-1) ) {
        
        // Cell ID
        CellIdentifier = @"TimeLineCell_BorderCell";
        
        // Load
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Create if needed
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        // Custom
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Cellule développée
    else if(indexPath.row == self.selectedIndex) {
        
        // Cell ID
        MomentClass *moment = self.selectedMoment;
        CellIdentifier = [NSString stringWithFormat:@"TimeLineCell_Developped_%@", moment.momentId];
        
        // Load
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Create if needed
        if(cell == nil) {
            cell = [[TimeLineDeveloppedCell alloc] initWithMoment:moment
                                                     withDelegate:self
                                                  reuseIdentifier:CellIdentifier];
        }
        
        
    }
    
    // Cellulle classique
    else {
        
        // Cell ID
        MomentClass *moment = self.moments[indexPath.row];
        CellIdentifier = [NSString stringWithFormat:@"TimeLineCell_Classique_%@", moment.momentId];
        
        // Load
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Create if needed
        if(cell == nil) {
            cell = [[TimeLineCell alloc] initWithMoment:moment
                                           withDelegate:self
                                                withRow:indexPath.row
                                        reuseIdentifier:CellIdentifier];
        }
        
    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( (indexPath.row == 0) || (indexPath.row == [self.moments count]-1) ) // 1er ou Derniere cell
        return borderCellSize;
    else if(indexPath.row == self.selectedIndex)
        return bigCellHeight;
    else
        return smallCellHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Si une cellule est selectionnée, la deselectionner
    if(self.selectedIndex != -1)
    {
        // Google Analytics
        [TimeLineViewController sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Diminution Moment" value:nil];
        
        NSIndexPath *previousIndex = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        self.selectedIndex = -1;
        self.selectedMoment = nil;
        TimeLineDeveloppedCell* cell = (TimeLineDeveloppedCell*)[self.tableView cellForRowAtIndexPath:previousIndex];
        [cell willDisappear];
        [self.tableView reloadRowsAtIndexPaths:@[previousIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self cacherBandeau];
    }
}

#pragma mark - TimeLineDelegate

#pragma mark Update TimeLine

- (void)reloadDataWithWaitUntilFinished:(BOOL)waitUntilFinished withEnded:(void (^) (BOOL success))block
{
    if(!isLoading)
    {
        isLoading = YES;
        
        if(self.timeLineStyle == TimeLineStyleComplete) {
            [MomentClass getMomentsServerWithEnded:^(BOOL success) {
                if(success) {
                    NSArray *array = [MomentCoreData getMoments];
                    [self reloadDataWithMoments:array];
                }
                
                isLoading = NO;
                
                if(block) {
                    block(success);
                }
            } waitUntilFinished:NO];
        }
        else {
            [MomentClass getMomentsForUser:self.user withEnded:^(NSArray *moments) {
                if(moments) {
                    [self reloadDataWithMoments:moments];
                }
                
                isLoading = NO;
                
                if(block) {
                    block(moments != nil);
                }
            }];
        }
        
    }
}

- (void)reloadDataWithWaitUntilFinished:(BOOL)waitUntilFinished {
    [self reloadDataWithWaitUntilFinished:waitUntilFinished withEnded:nil];
}

- (void)reloadData {
    [self reloadDataWithWaitUntilFinished:NO];
}

- (void)reloadMomentPicture:(MomentClass*)momentParam
{
    NSInteger index;
    if( (index = [self.moments indexOfObject:momentParam]) != NSNotFound ) {
        MomentClass* moment = self.moments[index];
        moment.imageString = momentParam.imageString;
        
        NSString *identifier = [NSString stringWithFormat:@"TimeLineCell_Classique_%@", moment.momentId];
        TimeLineCell *cSmall = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if(cSmall) {
            [cSmall.medallion setImage:nil imageString:momentParam.imageString withSaveBlock:^(UIImage *image) {
                moment.uimage = image;
            }];
        }
        
        identifier = [NSString stringWithFormat:@"TimeLineCell_Developped_%@", moment.momentId];
        TimeLineDeveloppedCell *cBig = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if(cBig) {
            [cBig.medallion setImage:nil imageString:momentParam.imageString withSaveBlock:^(UIImage *image) {
                moment.uimage = image;
            }];
        }
    }
}

- (void)reloadDataWithMoments:(NSArray*)moments
{
    self.moments = [self arrayWithEmptyObjectsAddedToArray:moments];
    rowForToday = [self calculRowForToday:moments beforeToday:&beforeToday];
    
    [self.tableView reloadData];
    [self placerEchelleLabels];
    // Update timeScroller
    [self.timeScroller scrollViewDidScroll];
}

- (void)selectActualMiddleCell {
    
    CGPoint point = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    point = [self.view convertPoint:point toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        
    if(self.selectedIndex != indexPath.row) {
        [self updateSelectedMoment:self.moments[indexPath.row] atRow:indexPath.row];
    } else if(self.bandeauTitre.alpha == 0) {
        [self afficherBandeau];
    }
        
}

- (void)updateSelectedMoment:(MomentClass*)moment atRow:(NSInteger)row
{    
    
    // Calcul de l'index si il n'est pas passé en paramètre
    if(row < 0) {
        NSUInteger index = [self.moments indexOfObject:moment];
        if(index != NSNotFound) {
            row = (NSInteger)index;
            NSLog(@"row = %d", row);
        }
        else
            NSLog(@"NOT FOUND %@", moment);
    }
    
    
    //First we check if a cell is already expanded.
    //If it is we want to minimize make sure it is reloaded to minimize it back
    if(self.selectedIndex >= 0)
    {
        NSIndexPath *previousPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        self.selectedIndex = row;
        self.selectedMoment = moment;
        
        TimeLineDeveloppedCell* cell = (TimeLineDeveloppedCell*)[self.tableView cellForRowAtIndexPath:previousPath];
        [cell willDisappear];
        
        [self.tableView reloadRowsAtIndexPaths:@[previousPath] withRowAnimation:UITableViewRowAnimationFade];
        //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
    //Finally set the selected index to the new selection and reload it to expand
    self.selectedIndex = row;
    self.selectedMoment = moment;
        
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    TimeLineCell* cell = (TimeLineCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell willDisappear];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    TimeLineDeveloppedCell* bigCell = (TimeLineDeveloppedCell*)[self.tableView cellForRowAtIndexPath:
                                                             [NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    
    [bigCell didAppear];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    // Update & affiche (en synchronisation avec les animations)
    [self performSelector:@selector(updateBandeauWithMoment:) withObject:self.selectedMoment afterDelay:0.2];
    [self performSelector:@selector(afficherBandeau) withObject:nil afterDelay:0.4];
    
    // Placer au fond
    //[self sendEchelleLabelsToBack];
    
}

#pragma mark Redirection Onglets

- (void)showOnglet:(enum OngletRank)onglet forMoment:(MomentClass*)moment
{
    // Si une nouvelle cellule a été selectionnée
    /*
    if( (!self.rootOngletsViewController) || (self.rootOngletsViewController.moment != moment) ) {
        self.rootOngletsViewController = [[RootOngletsViewController alloc]
                                          initWithMoment:moment
                                          withOnglet:onglet
                                          withTimeLine:self];
    }
    else
        [self.rootOngletsViewController addAndScrollToOnglet:onglet];
    */
    // Création
    self.rootOngletsViewController = [[RootOngletsViewController alloc]
                                      initWithMoment:moment
                                      withOnglet:onglet
                                      withTimeLine:self];
    
    if(self.shoulShowInviteView) {
        self.rootOngletsViewController.shouldShowInviteViewController = YES;
        self.shoulShowInviteView = NO;
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navController pushViewController:self.rootOngletsViewController animated:NO];
    }
    else
        [self.navController pushViewController:self.rootOngletsViewController animated:YES];
    
    
}

- (void)showInfoMomentView:(MomentClass*)moment {
    [self showOnglet:OngletInfoMoment forMoment:moment];
}

- (void)showPhotoView:(MomentClass*)moment {
    [self showOnglet:OngletPhoto forMoment:moment];
}

- (void)showTchatView:(MomentClass*)moment {
    [self showOnglet:OngletChat forMoment:moment];
}

#pragma mark Modification Model

- (void)deleteMoment:(MomentClass*)moment {
    
    // On enregistre le moment qui doit etre supprimé pour pouvoir y accéder via l'alertView
    momentToDelete = moment;
    
    // AlertView de confirmation
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TimeLineViewController_DeleteMomentAlertView_Title", nil)
                                message:NSLocalizedString(@"TimeLineViewController_DeleteMomentAlertView_Message", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_NO", nil)
                      otherButtonTitles:NSLocalizedString(@"AlertView_Button_YES", nil), nil]
     show];
    
}

#pragma mark Redirection Profonde

- (void)showInviteViewControllerWithMoment:(MomentClass *)moment
{
    self.shoulShowInviteView = YES;
    [self.navController popToRootViewControllerAnimated:NO];
    [self.rootViewController.ddMenuViewController showRootController:YES];
    [self showInfoMomentView:moment];
}

- (BOOL)hasMoment:(MomentClass*)moment
{
    return [self.moments containsObject:moment];
}

#pragma mark - Bandeau

- (void)setNomMomentLabelText:(NSString*)texteLabel
{
    texteLabel = [texteLabel uppercaseString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:18 ] range:range];
        range = NSMakeRange(1, taille-1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:14] range:range];
        [attributedString setTextColor:[[Config sharedInstance] textColor]];
        
        [self.nomMomentLabel setAttributedText:attributedString];
        self.nomMomentLabel.textAlignment = kCTLeftTextAlignment;
    }
    else
    {
        //NSLog(@"nomMomentLabel = %@", self.nomMomentLabel);
        if(self.nomMomentTTLabel) {
           [self.nomMomentTTLabel removeFromSuperview];
            self.nomMomentTTLabel = nil;
        }
        
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.nomMomentLabel.frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            

            Config *cf = [Config sharedInstance];
            
            // 1er Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:18 onRange:NSMakeRange(0, 1)];
            
            // Autres Lettres Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:14 onRange:NSMakeRange(1, taille-1 )];
            
            // Autres lettres couleurs
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [self.nomMomentLabel.superview addSubview:tttLabel];
        self.nomMomentLabel.hidden = YES;
        self.nomMomentTTLabel = tttLabel;
        
        //[self.titreLabel setAttributedTextFromString:texteLabel withFontSize:InfoMomentFontSizeMedium];
        //self.titreLabel.textAlignment = NSTextAlignmentLeft;
    }
}

-(void)setNomOwnerLabelText:(NSString*)texteLabel
{
    texteLabel = [NSString stringWithFormat:@"PAR %@",[texteLabel uppercaseString]];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 3);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:10] range:range];
        range = NSMakeRange(4, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:16] range:range];
        range = NSMakeRange(5, taille-5);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:12] range:range];
        [attributedString setTextColor:[[Config sharedInstance] orangeColor]];
        
        [self.nomOwnerLabel setAttributedText:attributedString];
        self.nomOwnerLabel.textAlignment = kCTLeftTextAlignment;
    }
    else
    {
        //NSLog(@"nomOwnerLabel = %@", self.nomOwnerLabel);
        if(self.nomOwnerTTLabel) {
            [self.nomOwnerTTLabel removeFromSuperview];
            self.nomOwnerTTLabel = nil;
        }
        
        /*
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.nomOwnerLabel.frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:10 onRange:NSMakeRange(0, 3)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:16 onRange:NSMakeRange(4, 1 )];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:12 onRange:NSMakeRange(5, taille-5 )];
            
            // Autres lettres couleurs
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.orangeColor onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [self.nomOwnerLabel.superview addSubview:tttLabel];
        self.nomOwnerLabel.hidden = YES;
        self.nomOwnerTTLabel = tttLabel;
        */
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.nomOwnerLabel.frame];
        label.text = texteLabel;
        label.font = [[Config sharedInstance] defaultFontWithSize:12];
        label.textColor = [Config sharedInstance].orangeColor;
        label.textAlignment = NSTextAlignmentLeft;
        self.nomOwnerTTLabel = label;
        [self.nomOwnerLabel.superview addSubview:label];
        self.nomOwnerLabel.hidden = YES;
         
        //[self.titreLabel setAttributedTextFromString:texteLabel withFontSize:InfoMomentFontSizeMedium];
        //self.titreLabel.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)setDateLabelTextFromDate:(NSDate*)date;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.calendar = [NSCalendar currentCalendar];
    formatter.dateFormat = @"dd";
    
    NSString* jour = [formatter stringFromDate:date];
    NSInteger jourVal = jour.intValue;
    formatter.dateFormat = @"MMMM";
    NSString* month = [formatter stringFromDate:date];
    formatter.dateFormat = @"HH";
    NSString* hour = [formatter stringFromDate:date];
    NSInteger hourVal = hour.intValue;
    formatter.dateFormat = @"mm";
    NSString* minutes = [formatter stringFromDate:date];
    
    NSMutableString *texteLabel = [[NSMutableString alloc] init];
    [texteLabel appendFormat:@"%d %@", jourVal, month.uppercaseString];
    if([hour length] > 0) {
        [texteLabel appendFormat:@" %d:%@", hourVal, minutes];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    //NSInteger taille = [texteLabel length];
    NSInteger rank = (jourVal >= 10)? 2 : 1;
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, rank);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:15] range:range];
        range = NSMakeRange(rank, month.length+1);
        rank += month.length+1;
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:11] range:range];
        
        if([hour length] > 0) {
            range = NSMakeRange(rank, 4 + ((hourVal >= 10)?2:1) );
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:15] range:range];
        }
        
        [attributedString setTextColor:[[Config sharedInstance] textColor]];
        
        [self.fullDateLabel setAttributedText:attributedString];
        self.fullDateLabel.textAlignment = NSTextAlignmentRight;
    }
    else
    {
        if(self.fullDateTTLabel) {
            [self.fullDateTTLabel removeFromSuperview];
            self.fullDateTTLabel = nil;
        }
        
        /*
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.fullDateLabel.frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // 1er Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:15 onRange:NSMakeRange(0, rank)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:11 onRange:NSMakeRange(rank, month.length+1 )];
            
            if([hour length] > 0) {
                NSInteger end = (hourVal >= 10)? 2 : 1;
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:11 onRange:NSMakeRange(rank, end)];
            }
            
            // Autres lettres couleurs
            [cf updateTTTAttributedString:mutableAttributedString withColor:cf.textColor onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [self.fullDateLabel.superview addSubview:tttLabel];
        self.fullDateLabel.hidden = YES;
        self.fullDateTTLabel = tttLabel;
        */
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.fullDateLabel.frame];
        label.text = texteLabel;
        label.font = [[Config sharedInstance] defaultFontWithSize:12];
        label.textColor = [Config sharedInstance].textColor;
        label.textAlignment = NSTextAlignmentRight;
        self.fullDateTTLabel = label;
        [self.fullDateLabel.superview addSubview:label];
        self.fullDateLabel.hidden = YES;
        
        //[self.titreLabel setAttributedTextFromString:texteLabel withFontSize:InfoMomentFontSizeMedium];
        //self.titreLabel.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)updateBandeauWithMoment:(MomentClass*)moment
{
    if(self.timeLineStyle == TimeLineStyleComplete)
    {
        [self setNomMomentLabelText:moment.titre];
        
        if(moment.owner) {
            [self setNomOwnerLabelText:moment.owner.formatedUsername];
        }
        else {
            //[self setNomOwnerLabelText:@""];
            self.nomOwnerLabel.text = @"";
            self.nomOwnerTTLabel.text = @"";
        }
        
        [self setDateLabelTextFromDate:moment.dateDebut];
        
    }
}

- (void)afficherBandeau
{
    if(self.timeLineStyle == TimeLineStyleComplete) {
        // Afficher bandeau
        if(self.bandeauTitre.alpha == 0 && !bandeauAnimating) {
            bandeauAnimating = YES;
            CGRect frame = self.bandeauTitre.frame;
            frame.origin.y += frame.size.height;
            [UIView animateWithDuration:0.5 animations:^{
                self.bandeauTitre.alpha = 1;
                self.bandeauTitre.frame = frame;
            } completion:^(BOOL finished) {
                bandeauAnimating = NO;
            }];
        }
    }
}

- (void)cacherBandeau
{
    if(self.timeLineStyle == TimeLineStyleComplete)
    {
        // Cacher bandeau
        if(self.bandeauTitre.alpha == 1 && !bandeauAnimating) {
            bandeauAnimating = YES;
            CGRect frame = self.bandeauTitre.frame;
            frame.origin.y -= frame.size.height;
            [UIView animateWithDuration:0.35 animations:^{
                self.bandeauTitre.alpha = 0;
                self.bandeauTitre.frame = frame;
            } completion:^(BOOL finished) {
                bandeauAnimating = NO;
            }];
        }
    }
}

#pragma mark - Scroll Infinite Load

- (void)updateCellsRowWithDecalage:(NSInteger)decalage {
    
    NSInteger taille = [self.moments count];
    if(taille <= 2)
        return;
    if(taille == 3) {
        // Cell ID
        MomentClass *moment = self.moments[1];
        NSString *cellId = [NSString stringWithFormat:@"TimeLineCell_Classique_%@", moment.momentId];
        // Load
        TimeLineCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
        if(cell) {
            [cell decallerRow:decalage];
        }
    }
    else {
        taille = taille - 1;
        NSInteger i;
        for(i = 1; i < taille; i++) {
            MomentClass *moment = self.moments[i];
            NSString *cellId = [NSString stringWithFormat:@"TimeLineCell_Classique_%@", moment.momentId];
            // Load
            TimeLineCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
            if(cell) {
                [cell decallerRow:decalage];
            }
        }
        
    }
}

- (void)loadMomentsInFuture
{
    if(!isLoading && !firstLoad)
    {
        // Si il y a des moments dans la timeLine
        int taille = [self.moments count];
        if(taille > 2) {
            
            // Load les moments dans le futur (fin du tableau)
            isLoading = YES;
            //NSLog(@"Moments After : début = %@ || fin = %@", [self.moments[taille - 2] dateDebut], [self.moments[taille - 2] dateFin]);
            UserClass *user = (self.timeLineStyle == TimeLineStyleProfil) ? self.user : nil;
            
            [MomentClass getMomentsServerAfterDateOfMoment:self.moments[taille - 2]
                                             timeDirection:TimeDirectionFutur
                                                      user:user
                                                 withEnded:^(NSArray *moments) {
                
                // Si il y a des moments à charger
                if([moments count] > 0)
                {
                    // Merge des tableau
                    NSMutableArray *array = self.moments.mutableCopy;
                    
                    // Supprime cellules vides
                    [array removeObjectAtIndex:0];
                    [array removeLastObject];
                    
                    // Ajout à la fin du tableau
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([array count], [moments count])];
                    [array insertObjects:moments atIndexes:indexSet];
                    
                    // Reload data
                    [self reloadDataWithMoments:array];
                    [self updateCellsRowWithDecalage:-[moments count]];
                    NSLog(@"Chargement dans le futur fini");
                }
                
                isLoading = NO;
            }];
            
        }
    }
}

- (void)loadMomentsInPast
{
    if(!isLoading && !firstLoad)
    {
        // Si il y a des moments dans la timeLine
        int taille = [self.moments count];
        if(taille > 2) {
            
            // Load les moments dans le passé (début du tableau)
            isLoading = YES;
            
            UserClass *user = (self.timeLineStyle == TimeLineStyleProfil) ? self.user : nil;
            [MomentClass getMomentsServerAfterDateOfMoment:self.moments[1]
                                             timeDirection:TimeDirectionPast
                                                      user:user
                                                 withEnded:^(NSArray *moments) {
                
                // Si il y a des moments à charger
                if([moments count] > 0)
                {
                    // Merge des tableau
                    NSMutableArray *array = self.moments.mutableCopy;
                    
                    // Supprime cellules vides
                    [array removeObjectAtIndex:0];
                    [array removeLastObject];
                    
                    // Ajout au début du tableau
                    moments = [moments reversedArray]; // Inverser le tableau
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [moments count])];
                    [array insertObjects:moments atIndexes:indexSet];
                    
                    // Moment précédement sélectionné
                    MomentClass *actualMoment = (self.selectedIndex > 0) ? self.moments[self.selectedIndex] : nil;
                    
                    // Reload data
                    [self reloadDataWithMoments:array];
                    [self updateCellsRowWithDecalage:[moments count]];
                    
                    if(actualMoment) {
                        // Sélectionner le moment précedement selectionné
                        [self updateSelectedMoment:actualMoment atRow:([moments count]+1+self.selectedIndex)];
                    }
                    // Scroll à la position précédente
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([moments count]+1) inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                    
                    NSLog(@"Chargement dans le passé fini");
                    
                }
                
                isLoading = NO;
            }];
            
        }
    }
}

#pragma mark - UIScrollViewDelegateMethods

- (void)scrollToNearestCell
{
    CGPoint point = CGPointMake(160, self.view.frame.size.height/2.0);
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: [self.tableView convertPoint:point fromView:self.view] ];
    //NSLog(@"row = %d", indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    // Update & affiche si cell valide
    if( (indexPath.row != 0) && (indexPath.row != [self.moments count]-1) ) {
        self.bandeauIndex = indexPath.row;
        [self updateBandeauWithMoment:self.moments[indexPath.row]];
        // Selectionner cellule
        [self performSelector:@selector(selectActualMiddleCell) withObject:nil afterDelay:0.2];
    }
    
    // Rétracter timeScroller
    [self.timeScroller performSelector:@selector(scrollViewDidEndDecelerating) withObject:nil afterDelay:0.3];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // ----------- Time Scroller ----------
    //The TimeScroller needs to know what's happening with the UITableView (UIScrollView)
    [self.timeScroller scrollViewDidScroll];
    
    // -------- B2P Bouton Rotation -------
    // Milieu
    CGFloat milieu = self.view.frame.size.height/2.0f + scrollView.contentOffset.y;
    
    // Today
    CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:rowForToday inSection:0]];
    CGFloat today = rect.origin.y + rect.size.height/2.0f;
    
    // Différence
    CGFloat delta = milieu - today;
        
    // Rotate Button
    CGFloat tailleTotale = scrollView.contentSize.height;
    self.B2PButton.transform = CGAffineTransformMakeRotation(((tailleTotale-delta)*M_PI)/(2*tailleTotale) );
    
    // --------- Scroll infinite ---------
    if(!isLoading) {
        // Si on est sur la cellule du haut
        if(scrollView.contentOffset.y <= -10) {
            [self loadMomentsInPast];
        }
        // Si on est sur la cellule du bas
        else if(scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height + 10) {
            [self loadMomentsInFuture];
        }
    }
    
    // ----------   Bandeau  -------------
    // Cacher bandeau quand on scoll
    [self cacherBandeau];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self scrollToNearestCell];
    //[self updateSelectedMoment:self.moments[self.bandeauIndex] atRow:self.bandeauIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timeScroller scrollViewWillBeginDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        
        [self scrollToNearestCell];
    }
}

#pragma mark - TimeScrollerDelegate Methods

//You should return an NSDate related to the UITableViewCell given. This will be
//the date displayed when the TimeScroller is above that cell.
- (NSDate *)dateForCell:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if( (indexPath.row>0) && (indexPath.row<[self.moments count]-2) ) {
        MomentClass *m = (self.moments)[indexPath.row];
        return m.dateDebut;
    }
    return nil;
}

/*
#pragma mark - Button Clock

-(void)hideArrowClockAnimated:(BOOL)animated
{
    if(self.B2PButton.alpha == 1) {
        if(animated) {
            [UIView beginAnimations:@"hideClockArrow" context:nil];
            self.B2PButton.alpha = 0;
            [UIView commitAnimations];
        }
        else
            self.B2PButton.alpha = 0;
        
        self.B2PButton.enabled = NO;
    }
}

- (void)updateArrowClockToState:(enum ClockState)state animated:(BOOL)animated
{
    if(shouldUpdateClock)
    {
        
        if(self.B2PButton.alpha == 0)
        {
            if(animated) {
                [UIView beginAnimations:@"showClockArrow" context:nil];
                self.B2PButton.alpha = 1;
                [UIView commitAnimations];
            }
            else {
                self.B2PButton.alpha = 1;
            }
            
            self.B2PButton.enabled = YES;
        }
        
        if(arrowClockActualState != state)
        {
            // Si on la fleche était cachée, on l'affiche
            if(animated) {
                
                // Rotation
                [UIView animateWithDuration:0.3 animations:^{
                    self.B2PButton.transform = CGAffineTransformRotate(self.B2PButton.transform, (state==ClockStateUp)?(M_PI):(5*M_PI) );
                }];
            }
            else {
                
                // Rotation
                self.B2PButton.transform = CGAffineTransformRotate(self.B2PButton.transform, (state==ClockStateUp)?(M_PI):(5*M_PI) );
            }
            
            // Update
            arrowClockActualState = state;
        }
        
        
    }
        
}
*/
 
- (IBAction)clicButtonClock
{
    if([self.moments count] > 3) {
        
        // Google Analytics
        [TimeLineViewController sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Today" value:nil];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowForToday inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self updateBandeauWithMoment:self.moments[rowForToday]];
        [self performSelector:@selector(selectActualMiddleCell) withObject:nil afterDelay:0.3];        
        [self.timeScroller scrollViewDidEndDecelerating];
    }
}

#pragma mark - UIAlertView Delegate -> Suppression Moment

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Confirmation de suppression
    if(buttonIndex == 1)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Deleting", nil);
        
        // Delete From Server
        [momentToDelete deleteWithEnded:^(BOOL success) {
            
            if(success)
            {
                // Récupère l'index
                NSInteger index = [self.moments indexOfObject:momentToDelete];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView beginUpdates];
                
                // Delete From local data
                NSMutableArray *newMoments = self.moments.mutableCopy;
                [newMoments removeObject:momentToDelete];
                self.moments = newMoments;
                
                // Delete From CoreData
                [MomentCoreData deleteMoment:momentToDelete];
                
                // Remove Cell
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView endUpdates];
                
                // Réinit
                self.selectedIndex = -1;
                self.selectedMoment = nil;
                momentToDelete = nil;
                
                // Patienter pour laisser le temps à l'UI de s'actualiser proprement
                double delayInSeconds = .5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self reloadDataWithWaitUntilFinished:YES];
                });
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            else
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [[[UIAlertView alloc]
                  initWithTitle:NSLocalizedString(@"Error_Title", nil)
                  message:NSLocalizedString(@"TimeLineViewController_DeleteMoment_Fail_Message", nil)
                  delegate:self
                  cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                  otherButtonTitles: nil]
                 show];
            }
                
        }];
        
        
    }
    
}

- (void)showTutorialOverlayWithFrame:(CGRect)frame {
    UIImage *image_overlay;
    self.overlay = [[UIImageView alloc] initWithFrame:frame];
    
    if ([[VersionControl sharedInstance] isIphone5]) {
        image_overlay = [UIImage imageNamed:@"tuto_overlay"];
    } else {
        image_overlay = [UIImage imageNamed:@"tuto_overlay_iphone4"];
    }
    
    [self.overlay setImage:image_overlay];
    
    // Finally set the alpha value
    [self.overlay setAlpha:0.9];
    [self.navController.view addSubview:self.overlay];
    
    self.overlay_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.overlay_button setFrame:self.overlay.frame];
    [self.overlay_button addTarget:self action:@selector(hideTutorialOverlay) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navController.view addSubview:self.overlay_button];
    
    
    UILabel *overlay_label1_1 = [[UILabel alloc] initWithFrame:CGRectMake(65, 20, 200, 30)];
    UILabel *overlay_label1_2 = [[UILabel alloc] initWithFrame:CGRectMake(65, 40, 200, 30)];
    [overlay_label1_1 setBackgroundColor:[UIColor clearColor]];
    [overlay_label1_2 setBackgroundColor:[UIColor clearColor]];
    [overlay_label1_1 setTextAlignment:NSTextAlignmentLeft];
    [overlay_label1_2 setTextAlignment:NSTextAlignmentLeft];
    [overlay_label1_1 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
    [overlay_label1_2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
    [overlay_label1_1 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label1", nil)];
    [overlay_label1_2 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label2", nil)];
    [overlay_label1_1 setTextColor:[UIColor whiteColor]];
    [overlay_label1_2 setTextColor:[UIColor whiteColor]];
    
    [self.overlay addSubview:overlay_label1_1];
    [self.overlay addSubview:overlay_label1_2];
    
    
    UILabel *overlay_label2_1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 135, 230, 30)];
    UILabel *overlay_label2_2 = [[UILabel alloc] initWithFrame:CGRectMake(80, 155, 230, 30)];
    [overlay_label2_1 setBackgroundColor:[UIColor clearColor]];
    [overlay_label2_2 setBackgroundColor:[UIColor clearColor]];
    [overlay_label2_1 setTextAlignment:NSTextAlignmentRight];
    [overlay_label2_2 setTextAlignment:NSTextAlignmentRight];
    [overlay_label2_1 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
    [overlay_label2_2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
    [overlay_label2_1 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label3", nil)];
    [overlay_label2_2 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label4", nil)];
    [overlay_label2_1 setTextColor:[UIColor whiteColor]];
    [overlay_label2_2 setTextColor:[UIColor whiteColor]];
    [overlay_label2_1 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-2))];
    [overlay_label2_2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-2))];
    
    [self.overlay addSubview:overlay_label2_1];
    [self.overlay addSubview:overlay_label2_2];
    
    
    
    if ([[VersionControl sharedInstance] isIphone5]) {
        UILabel *overlay_label3_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 380, 260, 30)];
        UILabel *overlay_label3_2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 400, 260, 30)];
        [overlay_label3_1 setBackgroundColor:[UIColor clearColor]];
        [overlay_label3_2 setBackgroundColor:[UIColor clearColor]];
        [overlay_label3_1 setTextAlignment:NSTextAlignmentCenter];
        [overlay_label3_2 setTextAlignment:NSTextAlignmentCenter];
        [overlay_label3_1 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
        [overlay_label3_2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
        [overlay_label3_1 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label5", nil)];
        [overlay_label3_2 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label6", nil)];
        [overlay_label3_1 setTextColor:[UIColor whiteColor]];
        [overlay_label3_2 setTextColor:[UIColor whiteColor]];
        [overlay_label3_1 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-9))];
        [overlay_label3_2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-9))];
        
        [self.overlay addSubview:overlay_label3_1];
        [self.overlay addSubview:overlay_label3_2];
    } else {
        UILabel *overlay_label3_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, 260, 30)];
        UILabel *overlay_label3_2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 320, 260, 30)];
        [overlay_label3_1 setBackgroundColor:[UIColor clearColor]];
        [overlay_label3_2 setBackgroundColor:[UIColor clearColor]];
        [overlay_label3_1 setTextAlignment:NSTextAlignmentCenter];
        [overlay_label3_2 setTextAlignment:NSTextAlignmentCenter];
        [overlay_label3_1 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
        [overlay_label3_2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:16.0]];
        [overlay_label3_1 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label5", nil)];
        [overlay_label3_2 setText:NSLocalizedString(@"TimeLineViewController_Overlay_Label6", nil)];
        [overlay_label3_1 setTextColor:[UIColor whiteColor]];
        [overlay_label3_2 setTextColor:[UIColor whiteColor]];
        [overlay_label3_1 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-9))];
        [overlay_label3_2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-9))];
        
        [self.overlay addSubview:overlay_label3_1];
        [self.overlay addSubview:overlay_label3_2];
    }
}

- (void)hideTutorialOverlay {
    [UIView animateWithDuration:0.4
                     animations:^{self.overlay.alpha = 0.0;}
                     completion:^(BOOL finished)
     {
         
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         BOOL hasRunOnce = [defaults boolForKey:@"hasRunOnce"];
         
         if (!hasRunOnce)
         {
             [defaults setBool:YES forKey:@"hasRunOnce"];
         }
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         [self.overlay_button removeFromSuperview];
         [self.overlay removeFromSuperview];
         
     }];
}

@end 
