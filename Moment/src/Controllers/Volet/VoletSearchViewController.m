//
//  VoletSearchViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "VoletSearchViewController.h"
#import "Config.h"
#import "UserClass+Server.h"
#import "ProfilViewController.h"

#import "VoletSearchCellMoment.h"
#import "VoletSearchCellUtilisateur.h"

@interface VoletSearchViewController () {
    @private
    BOOL isEmptyMoments;
    BOOL isEmptyUtilisateurs;
}

@end

@implementation VoletSearchViewController

@synthesize delegate = _delegate;
@synthesize moments = _moments;
@synthesize utilisateurs = _utilisateurs;
@synthesize nbPrivateMoments = _nbPrivateMoments;

@synthesize searchBarTextField = _searchBarTextField;
@synthesize annulerButton = _annulerButton;

@synthesize segementShadow = _segementShadow;
@synthesize buttonsView = _buttonsView;
@synthesize utilisateursButton = _utilisateursButton;
@synthesize momentsButton = _momentsButton;

@synthesize nbMomentsBackground = _nbMomentsBackground;
@synthesize nbMomentsLabel = _nbMomentsLabel;
@synthesize nbMomentsView = _nbMomentsView;

@synthesize nbUtilisateursBackground = _nbUtilisateursBackground;
@synthesize nbUtilisateursLabel = _nbUtilisateursLabel;
@synthesize nbUtilisateursView = _nbUtilisateursView;

#pragma mark - Init

- (id)initWithDelegate:(VoletViewController*)delegate
{
    self = [super initWithNibName:@"VoletSearchViewController" bundle:nil];
    if (self) {
        self.isShowingMoments = NO;
        self.moments = @[];
        self.utilisateurs = @[];
        self.nbPrivateMoments = 0;
        self.delegate = delegate;
    }
    return self;
}


- (void)designNbMomentsAndUtilisateursViews
{
    const short int height = 19;
    
    CGSize maxSize = CGSizeMake(35, height);
    NSString *texte = nil;
    CGSize expectedSize;
    CGRect frame;
    
    // Moments
    int taille = [self.moments count];
    if(taille == 0)
        self.nbMomentsView.hidden = YES;
    else
    {
        self.nbMomentsView.hidden = NO;
        texte = [NSString stringWithFormat:@"%d", taille];
        self.nbMomentsLabel.text = texte;
        expectedSize = [texte sizeWithFont:self.nbMomentsLabel.font constrainedToSize:maxSize];
        expectedSize.width = MAX(height, expectedSize.width);
        expectedSize.height = height;
        frame.size = expectedSize;
        frame.origin.y = (self.momentsButton.frame.size.height - height + 1)/2.0;
        frame.origin.x = self.momentsButton.frame.size.width - (expectedSize.width + 4);
        self.nbMomentsView.frame = frame;
        frame.origin = CGPointZero;
        self.nbMomentsLabel.frame = frame;
        self.nbMomentsBackground.frame = frame;
    }
    
    // Invitations
    taille = [self.utilisateurs count];
    if(taille == 0)
        self.nbUtilisateursView.hidden = YES;
    else
    {
        self.nbUtilisateursView.hidden = NO;
        texte = [NSString stringWithFormat:@"%d", taille];
        self.nbUtilisateursLabel.text = texte;
        expectedSize = [texte sizeWithFont:self.nbUtilisateursLabel.font constrainedToSize:maxSize];
        expectedSize.width = MAX(height, expectedSize.width);
        expectedSize.height = height;
        frame.size = expectedSize;
        frame.origin.y = (self.utilisateursButton.frame.size.height - height + 1)/2.0;
        frame.origin.x = self.utilisateursButton.frame.size.width - (expectedSize.width + 4);
        self.nbUtilisateursView.frame = frame;
        frame.origin = CGPointZero;
        self.nbUtilisateursLabel.frame = frame;
        self.nbUtilisateursBackground.frame = frame;
    }
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Number utilisateurs / moments
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:12];
    self.nbUtilisateursLabel.font = font;
    self.nbMomentsLabel.font = font;
    [self.utilisateursButton addSubview:self.nbUtilisateursView];
    [self.momentsButton addSubview:self.nbMomentsView];
    
    font = [[Config sharedInstance] defaultFontWithSize:13];
    self.momentsButton.titleLabel.font = font;
    self.utilisateursButton.titleLabel.font = font;
    
    UIImage *bgNotif = [UIImage imageNamed:@"bg_notif"];
    bgNotif = [[VersionControl sharedInstance] resizableImageFromImage:bgNotif withCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    
    self.nbUtilisateursBackground.image = bgNotif;
    self.nbUtilisateursBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.nbMomentsBackground.image = bgNotif;
    self.nbMomentsBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicUtilisateurs)];
    [self.nbUtilisateursView addGestureRecognizer:tap];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicMoments)];
    [self.nbMomentsView addGestureRecognizer:tap];
    
    [self designNbMomentsAndUtilisateursViews];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_volet"]];
    
    [self.searchBarTextField setPlaceholder:NSLocalizedString(@"VoletSearchViewController_Placeholder_Search", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppDelegate updateActualViewController:self];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBarTextField becomeFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setMoments:nil];
    [self setUtilisateurs:nil];
    [self setButtonsView:nil];
    [self setSegementShadow:nil];
    [self setUtilisateursButton:nil];
    [self setMomentsButton:nil];
    [self setNbMomentsBackground:nil];
    [self setNbMomentsLabel:nil];
    [self setNbMomentsView:nil];
    [self setNbUtilisateursBackground:nil];
    [self setNbUtilisateursLabel:nil];
    [self setNbUtilisateursView:nil];
    [self setAnnulerButton:nil];
    [self setSearchBarTextField:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int taille;
    
    // Moments
    if(self.isShowingMoments) {
        taille = [self.moments count];
        
        // Eemtpy
        if(taille == 0) {
            isEmptyMoments = YES;
            tableView.scrollEnabled = NO;
            return 1;
        }
        isEmptyMoments = NO;
        tableView.scrollEnabled = YES;
        return taille;
    }

    // Utilisateurs
    taille = [self.utilisateurs count];
    
    // Empty
    if(taille == 0) {
        isEmptyUtilisateurs = YES;
        tableView.scrollEnabled = NO;
        return 1;
    }
    isEmptyUtilisateurs = NO;
    tableView.scrollEnabled = YES;
    return taille;
}


- (UITableViewCell*)emptyCellWithReuseIdentifier:(NSString*)reuseIdentifier
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = cell.frame;
    frame.size = self.tableView.frame.size;
    cell.frame = frame;
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_volet"]];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = (self.isShowingMoments) ? NSLocalizedString(@"VoletSearchViewController_EmptyCell_Moments", nil) : NSLocalizedString(@"VoletSearchViewController_EmptyCell_Utilisateurs", nil);
    label.backgroundColor = [UIColor clearColor];
    label.font = [[Config sharedInstance] defaultFontWithSize:14];
    label.textColor = [Config sharedInstance].textColor;
    label.numberOfLines = 0;
    label.contentMode = UIViewContentModeCenter;
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    label.textAlignment = NSTextAlignmentCenter;
    frame = cell.frame;
    frame.size.height -= 180;
    frame.size.width -= 30;
    frame.origin.y = 0;
    frame.origin.x = (cell.frame.size.width - frame.size.width)/2.0;
    label.frame = frame;
    [cell addSubview:label];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    UITableViewCell *cell = nil;
    
    // Moments
    if(self.isShowingMoments)
    {
        if(isEmptyMoments)
        {
            CellIdentifier = @"VoletSearchViewController_EmptyCell_Moments";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
                cell = [self emptyCellWithReuseIdentifier:CellIdentifier];
        }
        else
        {
            
            // Private Moment
            if(indexPath.row < self.nbPrivateMoments) {
                // Private
            }
            else
            {
                // Public
            }
            
            CellIdentifier = [NSString stringWithFormat:@"VoletSearchViewController_CellMoment_%@_%f", [self.moments[indexPath.row] momentId], [NSDate timeIntervalSinceReferenceDate]];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if(cell == nil) {
                cell = [[VoletSearchCellMoment alloc] initWithMoment:self.moments[indexPath.row] reuseIdentifier:CellIdentifier];
            }
        }
    }
    // Utilisateurs
    else
    {
        if(isEmptyUtilisateurs)
        {
            CellIdentifier = @"VoletSearchViewController_EmptyCell_Utilisateurs";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
                cell = [self emptyCellWithReuseIdentifier:CellIdentifier];
        }
        else
        {
            CellIdentifier = [NSString stringWithFormat:@"VoletSearchViewController_CellUtilisateur_%@_%f", [self.utilisateurs[indexPath.row] userId], [NSDate timeIntervalSinceReferenceDate]];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if(cell == nil) {
                cell = [[VoletSearchCellUtilisateur alloc] initWithUser:self.utilisateurs[indexPath.row]
                                                        reuseIdentifier:CellIdentifier];
            }
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( (self.isShowingMoments && isEmptyMoments) || (!self.isShowingMoments && isEmptyUtilisateurs) )
        return self.tableView.frame.size.height;
    return 50.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.searchBarTextField isFirstResponder])
        [self.searchBarTextField resignFirstResponder];
    
    // Clic Moment
    if(self.isShowingMoments && !isEmptyMoments) {
        [self.delegate showInfoMomentFromSearch:self.moments[indexPath.row]];
    }
    // Clic Utilisateur
    else if(!self.isShowingMoments && !isEmptyUtilisateurs) {
        [self.delegate showUserProfileFromVoletSearch:self.utilisateurs[indexPath.row]];
    }
}

#pragma mark - Actions

- (void)searchForQuery:(NSString*)query
{
    [self.searchBarTextField resignFirstResponder];
    
    [UserClass search:query withEnded:^(NSArray *users, NSArray *moments, NSInteger nbPrivateMoments) {
        
        self.utilisateurs = users;
        self.moments= moments;
        self.nbPrivateMoments = nbPrivateMoments;
        
        // Design buttons
        [self designNbMomentsAndUtilisateursViews];
        
        int nbMoments = [self.moments count];
        int nbUtilisateurs = [self.utilisateurs count];
        
        // Si on est sur moment et qu'il n'y a pas de moment mais qu'il y a des users -> on va sur utilisateurs
        if(self.isShowingMoments && (nbMoments == 0) && (nbUtilisateurs > 0) )
            [self clicUtilisateurs];
        // Si on est sur utilisateurs et qu'il n'y a pas d'utilisateur mais qu'il y a des moments -> on va sur moment
        else if( !self.isShowingMoments && (nbUtilisateurs == 0) && (nbMoments>0) )
            [self clicMoments];
        // Sinon, on met à jour la vue actuelle
        else
            [self.tableView reloadData];
    }];
}

- (IBAction)clicAnnuler {
    
    if([self.searchBarTextField isFirstResponder])
        [self.searchBarTextField resignFirstResponder];
    
    self.utilisateurs = @[];
    self.moments = @[];
    self.nbPrivateMoments = 0;
    self.searchBarTextField.text = nil;
    [self designNbMomentsAndUtilisateursViews];
    [self.tableView reloadData];
    

    // Fade animaton
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:@"VoletSearchAnimation"];
    
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (IBAction)clicMoments
{
    if(!self.momentsButton.isSelected) {
        [self.momentsButton setSelected:YES];
        [self.utilisateursButton setSelected:NO];
        
        self.isShowingMoments = YES;
        [self.tableView reloadData];
    }
}

- (IBAction)clicUtilisateurs
{
    if(!self.utilisateursButton.isSelected) {
        [self.utilisateursButton setSelected:YES];
        [self.momentsButton setSelected:NO];
        
        self.isShowingMoments = NO;
        [self.tableView reloadData];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length > 0)
        [self searchForQuery:textField.text];
    return YES;
}

@end
