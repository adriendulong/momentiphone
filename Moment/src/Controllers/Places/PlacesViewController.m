//
//  PlacesViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PlacesViewController.h"
#import "Config.h"
#import "Place.h"
#import "PlacesTableViewCell.h"

@interface PlacesViewController () {
    @private
    BOOL isEmpty;
    BOOL emptyTextField;
}

@end

@implementation PlacesViewController

- (id)initWithDelegate:(id <CreationFicheViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"PlacesViewController" bundle:nil];
    if(self) {
        
        self.delegate = delegate;
        isEmpty = YES;
        emptyTextField = YES;
        self.results = [[NSMutableArray alloc] init];
        
        [CustomNavigationController setBackButtonWithViewController:self];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    frame = self.tableView.frame;
    frame.origin.y = 50;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.tableView.frame = frame;
    
    // Si une recherche a déjà été faite, on part ce cette recherche
    if(self.delegate.adresseText && self.delegate.adresseText.length > 0) {
        self.searchTextField.text = self.delegate.adresseText;
        emptyTextField = NO;
        [self loadAutocompletion:self.delegate.adresseText];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Show Keyboard
    [self.searchTextField becomeFirstResponder];
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
    if(emptyTextField) {
        isEmpty = YES;
        self.tableView.scrollEnabled = NO;
        return 1;
    }

    isEmpty = NO;
    self.tableView.scrollEnabled = YES;
    return [self.results count]+1;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *CellIdentifier = nil;
    if(isEmpty) {
        CellIdentifier = @"PlacesTableViewCell_Empty";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = cell.frame;
            frame.size = self.tableView.frame.size;
            cell.frame = frame;
            
            UILabel *label = [[UILabel alloc] init];
            label.text = NSLocalizedString(@"PlacesViewController_EmptyCell", nil);
            label.backgroundColor = [UIColor clearColor];
            label.font = [[Config sharedInstance] defaultFontWithSize:14];
            label.textColor = [Config sharedInstance].textColor;
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            frame = cell.frame;
            frame.size.width -= 20;
            frame.size.height = cell.frame.size.height/3.0;
            frame.origin.x = (cell.frame.size.width - frame.size.width)/2.0;
            frame.origin.y = 0;
            label.frame = frame;
            [cell addSubview:label];
        }
    }
    else {
        
        // Première Cellule ==> Résultat Perso
        if(indexPath.row== 0)
        {
            cell = [[PlacesTableViewCell alloc] initWithCustomAdresse:self.searchTextField.text];
        }
        // Google Place Results
        else
        {
            Place* place = self.results[indexPath.row-1];
            
            // Cell ID
            CellIdentifier = [NSString stringWithFormat:@"PlacesTableViewCell_%@", place.placeId];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if(cell == nil) {
                cell = [[PlacesTableViewCell alloc] initWithPlace:place
                                                  reuseIdentifier:CellIdentifier
                                                            index:indexPath.row];
            }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!isEmpty)
    {
        // Return Result
        self.delegate.adresseText = (indexPath.row == 0)? self.searchTextField.text : [(Place*)(self.results[indexPath.row-1]) adresse];
        [self.searchTextField resignFirstResponder];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Load

- (void)loadAutocompletion:(NSString*)newString {
    
    [Place autocompletionForQuery:newString withEnded:^(NSArray *results) {
        
        if(results) {
            [self.results removeAllObjects];
            [self.results addObjectsFromArray:results];
            [self.tableView reloadData];
        }
        else {
            [[MTStatusBarOverlay sharedInstance]
             postImmediateErrorMessage:NSLocalizedString(@"Error_Classic", nil)
             duration:1
             animated:YES];
        }
        
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // Vide
    if(newString.length == 0) {
        emptyTextField = YES;
        [self.tableView reloadData];
    }
    // Autocompletion
    else {
        emptyTextField = NO;
        
        // Démarer autocompletion à la 3e lettre
        if(newString.length >= 3) {
            [self loadAutocompletion:newString];
        }
        else {
            [self.results removeAllObjects];
            [self.tableView reloadData];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    emptyTextField = YES;
    [self.results removeAllObjects];
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    return YES;
}

- (IBAction)clicSearchButton {
    [self.searchTextField resignFirstResponder];
}

@end
