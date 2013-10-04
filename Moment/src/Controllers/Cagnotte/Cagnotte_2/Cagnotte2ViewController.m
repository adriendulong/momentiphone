//
//  Cagnotte2ViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Cagnotte2ViewController.h"
#import "Cagnotte2TableViewCell.h"
#import "SVPullToRefresh.h"
#import "Config.h"
#import "Cagnotte3ViewController.h"

@interface Cagnotte2ViewController () {
    @private
    BOOL isEmpty;
    NSInteger startIndex;
}

@end

@implementation Cagnotte2ViewController

@synthesize parametres = _parametres;
@synthesize products = _products;
@synthesize bandeauView = _bandeauView;

- (id)initWitParametres:(NSMutableDictionary *)parametres
{
    self = [super initWithNibName:@"Cagnotte2ViewController" bundle:nil];
    if (self) {
        self.parametres = parametres;
        isEmpty = YES;
        self.products = [[NSMutableArray alloc] init];
        startIndex = -1;
        
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
    frame.origin.y = 98;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.tableView.frame = frame;
    
    // Bandeau
    self.bandeauView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_panier"]];
    self.bandeauView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Bandeau Label
    self.bandeauLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
    
    // Infinite Scroll
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if(!isEmpty) {
            [self loadNextPageWithEnded:^{
                [self.tableView.infiniteScrollingView stopAnimating];
            }];
        }
        else {
            [self.tableView.infiniteScrollingView stopAnimating];
        }
    }];
    
    //[self.searchTextField becomeFirstResponder];
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
    int taille = [self.products count];
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
        CellIdentifier = @"Cagnotte2TableViewCell_Empty";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = cell.frame;
            frame.size = self.tableView.frame.size;
            cell.frame = frame;
            
            UILabel *label = [[UILabel alloc] init];
            label.text = NSLocalizedString(@"Cagnotte2ViewController_EmptyCell", nil);
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
        
        CagnotteProduct* product = self.products[indexPath.row];
        // Cell ID
        CellIdentifier = [NSString stringWithFormat:@"Cagnotte2TableViewCell_%@", product.googleId];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[Cagnotte2TableViewCell alloc] initWithProduct:product
                                                   reuseIdentifier:CellIdentifier
                                                             index:indexPath.row];
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
        self.parametres[@"cadeau"] = self.products[indexPath.row];
        Cagnotte3ViewController *cagnotte = [[Cagnotte3ViewController alloc] initParametres:self.parametres];
        [self.navigationController pushViewController:cagnotte animated:YES];
    }
}

#pragma mark - Load

- (void)searchForCurrentQueryWithStartIndex:(NSInteger)startIndexParam
                              withSaveBlock:(void (^) (NSArray *prodcuts))saveBlock
                                  withEnded:(void (^) (void))endBlock
{
    if( self.searchTextField.text.length == 0)
        return;
    
    [CagnotteProduct searchForQuery:self.searchTextField.text withStartIndex:startIndexParam withEnded:^(NSDictionary *results) {
                
        if(results && results[@"products"])
        {
            if(saveBlock)
                saveBlock(results[@"products"]);
            
            if(results[@"startIndex"]) {
                startIndex = [results[@"startIndex"] intValue];
            }
            else {
                startIndex = -1;
            }
            
            [self.tableView reloadData];
            
        }
        
        if(endBlock)
            endBlock();
        
    }];
    
}

- (void)searchForCurrentQuery {
    
    // -------- Loading
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
    
    [self searchForCurrentQueryWithStartIndex:1 withSaveBlock:^(NSArray *prodcuts) {
        self.products = prodcuts.mutableCopy;
    } withEnded:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)loadNextPageWithEnded:(void (^) (void))block {
    
    if(startIndex > 0)
    {
        [self searchForCurrentQueryWithStartIndex:startIndex withSaveBlock:^(NSArray *prodcuts) {
            [self.products addObjectsFromArray:prodcuts];
        } withEnded:block];
    }
    else if(block)
        block();
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.tableView scrollsToTop];
    [textField resignFirstResponder];
    [self searchForCurrentQuery];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *total = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.searchButton.enabled = (total.length > 0);
    
    return YES;
}

#pragma mark - Actions

- (IBAction)clicSearchButton {
    [self.tableView scrollsToTop];
    [self.searchTextField resignFirstResponder];
    [self searchForCurrentQuery];
}

@end
