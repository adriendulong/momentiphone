//
//  Cagnotte4ViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Cagnotte4ViewController.h"
#import "Config.h"
#import "Cagnotte4TableViewCell.h"
#import "ProfilViewController.h"

@interface Cagnotte4ViewController () {
    @private
    BOOL isEmpty;
}

@end

@implementation Cagnotte4ViewController

@synthesize parametres = _parametres;

- (id)initWithParametres:(NSMutableDictionary *)parametres
{
    self = [super initWithNibName:@"Cagnotte4ViewController" bundle:nil];
    if (self) {
        self.parametres = parametres;
        self.participants = parametres[@"participants"];
        self.product = parametres[@"cadeau"];
        isEmpty = YES;
        
        [CustomNavigationController setBackButtonWithViewController:self];;
    }
    return self;
}

- (void)deplacerView:(UIView*)view delta:(NSInteger)delta
{
    CGRect frame = view.frame;
    frame.origin.y += delta;
    view.frame = frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;

    // Bandeau
    self.bandeauLabel.text = self.parametres[@"titre"];
    self.bandeauView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_panier"]];
    self.bandeauView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Cover
    [self.coverImage setImage:nil imageString:self.product.imageURL placeHolder:[UIImage imageNamed:@"cagnotte_defaut"] withSaveBlock:^(UIImage *image) {
        if(self.product)
            self.product.image = image;
    }];
    
    // Bénéficiaire
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:11];
    self.organisePourLabel.font = font;
    self.organisePourLabel.text = [NSString stringWithFormat:@"Organisé pour %@", [self.parametres[@"beneficiaire"] uppercaseString]];
    
    // Prix
    self.cagnotteLabel.font = font;
    self.cagnotteLabel.text = [NSString stringWithFormat:@"Cagnotte de %@", self.parametres[@"montant"]];
    
    // Description
    font = [[Config sharedInstance] defaultFontWithSize:13];
    NSString *descriptionString = self.parametres[@"description"];
    CGSize descriptionSize = [descriptionString sizeWithFont:font constrainedToSize:(CGSize){self.descriptionLabel.frame.size.width, 9999}];
    self.descriptionLabel.text = descriptionString;
    self.descriptionLabel.font = font;
    
    // On enregistre la différence de taille pour pouvoir déplacer les autres éléments
    NSInteger delta = descriptionSize.height - self.descriptionLabel.frame.size.height;
    
    frame = self.descriptionLabel.frame;
    frame.size = descriptionSize;
    self.descriptionLabel.frame = frame;
    frame = self.descriptionBackgroundView.frame;
    frame.size.height = self.descriptionLabel.frame.size.height + 2*6;
    self.descriptionBackgroundView.frame = frame;
    
    // On déplace les autres éléments
    [self deplacerView:self.argentImage delta:delta];
    [self deplacerView:self.argentLabel delta:delta];
    [self deplacerView:self.argentInfoLabel delta:delta];
    [self deplacerView:self.participantsImage delta:delta];
    [self deplacerView:self.participantsLabel delta:delta];
    [self deplacerView:self.participantsInfoLabel delta:delta];
    [self deplacerView:self.tempsImage delta:delta];
    [self deplacerView:self.tempsLabel delta:delta];
    [self deplacerView:self.tempsInfoLabel delta:delta];
    [self deplacerView:self.recupereButton delta:delta];
    [self deplacerView:self.participeButton delta:delta];
    
    // Argent
    font = [[Config sharedInstance] defaultFontWithSize:11];
    self.argentLabel.font = self.argentInfoLabel.font = self.participantsLabel.font = self.participantsInfoLabel.font = self.tempsLabel.font = self.tempsInfoLabel.font = font;
    self.argentLabel.text = [NSString stringWithFormat:@"%d€", rand()%([self.parametres[@"montant"] intValue] + 1)];
    
    // Participants
    self.participantsLabel.text = [NSString stringWithFormat:@"%d", [self.participants count]];
    
    // Temps
    self.tempsLabel.text = [NSString stringWithFormat:@"%d J", rand()%(31 - 2 + 1)+2 ];
    
    // Header View
    frame = self.headerView.frame;
    frame.size.height = self.recupereButton.frame.origin.y + self.recupereButton.frame.size.height + 11;
    self.headerView.frame = frame;
    
    // TableView
    self.tableView.frame = self.view.frame;
    [self.view addSubview:self.tableView];
    
    // Shadow
    frame = self.shadowView.frame;
    frame.origin.y = self.headerView.frame.size.height;
    self.shadowView.frame = frame;
    [self.tableView addSubview:self.shadowView];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int taille = [self.participants count];
    if(taille == 0) {
        isEmpty = YES;
        self.tableView.scrollEnabled = NO;
        return 1;
    }
    isEmpty = NO;
    self.tableView.scrollEnabled = YES;
    return taille;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *CellIdentifier = nil;
    if(isEmpty) {
        CellIdentifier = @"Cagnotte4TableViewCell_Empty";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = cell.frame;
            frame.size = self.tableView.frame.size;
            cell.frame = frame;
            
            UILabel *label = [[UILabel alloc] init];
            label.text = NSLocalizedString(@"Cagnotte4ViewController_EmptyCell", nil);
            label.backgroundColor = [UIColor clearColor];
            label.font = [[Config sharedInstance] defaultFontWithSize:14];
            label.textColor = [Config sharedInstance].textColor;
            [label sizeToFit];
            frame = label.frame;
            frame.origin.x = (cell.frame.size.width - frame.size.width)/2.0;
            frame.origin.y = (cell.frame.size.height - frame.size.height)/4.0;
            label.frame = frame;
            [cell addSubview:label];
        }
    }
    else {
        
        UserClass* user = self.participants[indexPath.row];
        // Cell ID
        CellIdentifier = [NSString stringWithFormat:@"Cagnotte4TableViewCell_%@", user.userId];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[Cagnotte4TableViewCell alloc] initWithUser:user
                                                       delegate:self
                                                          index:indexPath.row
                                                reuseIdentifier:CellIdentifier];
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmpty)
        return self.tableView.frame.size.height;
    
    return 50.0f;
}

#pragma mark - Cagnotte 4 Delegate

- (void)clicProfile:(UserClass*)user {
    if(user) {
        ProfilViewController *profile = [[ProfilViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:profile animated:YES];
    }
}

#pragma mark - Actions

- (void)backToTimeLine {
    NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
    NSInteger nb = self.product ? 4 : 3; // On revient 3 ou 4 view controllers en arrière
    for(unsigned short int i=0; i<nb; i++) {
        [viewControllers removeLastObject];
    }
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (IBAction)clicParticipeButton {
    [self backToTimeLine];
}

- (IBAction)clicRecupereButton {
    [self backToTimeLine];
}

@end
