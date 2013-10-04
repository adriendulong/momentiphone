//
// REPhotoCollectionController.m
// REPhotoCollectionController
//
// Copyright (c) 2012 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REPhotoCollectionController.h"
#import "Config.h"
#import "RevivrePartagerViewController.h"

@interface REPhotoCollectionController ()

@end

@implementation REPhotoCollectionController

@synthesize datasource = _datasource;
@synthesize groupByDate = _groupByDate;
@synthesize thumbnailViewClass = _thumbnailViewClass;
//@synthesize events = _events;
@synthesize moments = _moments;
@synthesize timeLine = _timeLine;
@synthesize photosToUpload = _photosToUpload;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_ds && _ds.count == 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Cross.png"]];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Search_EmptyPhoto", nil);
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init Nav bar
    [self initNavigationBar];
    
    if (_ds && _ds.count > 0) {
        [self initFinishButton];
    }
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    self.photosToUpload = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Revivre Moments Photos Collection"];
    
    [AppDelegate updateActualViewController:self];
}

#pragma mark - Init view components

- (void)initFinishButton
{
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setBackgroundImage:[UIImage imageNamed:@"btn_revivre.png"]
                            forState:UIControlStateNormal];
    
    [finishButton addTarget:self
                     action:@selector(clicFinish)
           forControlEvents:UIControlEventTouchDown];
    
    [finishButton setTitle:@"Envoyer les photos !" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finishButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    finishButton.frame = CGRectMake(14, 0, 292, 42);
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [footerView addSubview:finishButton];
        
    [self.tableView setTableFooterView:footerView];
}

- (void)initNavigationBar
{
    [CustomNavigationController setBackButtonChevronWithViewController:self];
    [CustomNavigationController setTitle:@"Revivre" withColor:[Config sharedInstance].orangeColor withViewController:self];
    
    CGRect frameButton = CGRectMake(0,0,90,43);
    
    // 2e bouton
    UIButton *secondButton = [[UIButton alloc] initWithFrame:frameButton];
    UIBarButtonItem *secondBarButton = [[UIBarButtonItem alloc] initWithCustomView:secondButton];
    
    // Set buttons
    self.navigationItem.rightBarButtonItems = @[secondBarButton];
    
    [self updateNavBar];
}

- (void)updateNavBar
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    
    if(buttons.count == 1)
    {
        NSString *normal = [NSString stringWithFormat:NSLocalizedString(@"Next", nil)];
        UIColor *colorEnable = [Config sharedInstance].orangeColor;
        UIColor *colorDisabled = [Config sharedInstance].textColor;
        BOOL secondButtonEnable = NO;
        
        // Second Button
        UIButton *button = (UIButton*)[buttons[0] customView];
        
        //if(self.events && self.events.count > 0)
        if(self.moments && self.moments.count > 0)
        {
            secondButtonEnable = YES;
            
            [self removeSubviewsOfView:button];
            
            [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, 90, 43)];
        }
        
        // Update
        [button.titleLabel setFont:[[Config sharedInstance] defaultFontWithSize:16]];
        [button setTitle:normal forState:UIControlStateNormal];
        [button setTitleColor:colorDisabled forState:UIControlStateDisabled];
        [button setTitleColor:colorEnable forState:UIControlStateNormal];
        [button.titleLabel setTextAlignment:NSTextAlignmentRight];
        [button removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(clicNext) forControlEvents:UIControlEventTouchUpInside];
        [button setEnabled:secondButtonEnable];
    }
    
}

- (void)setNavBarSecondButtonEnable:(BOOL)enable
{
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    UIButton *button = (UIButton*)[buttons[0] customView];
    
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

#pragma mark - Actions

- (void)clicNext
{    
    CGRect footerBounds = [self.tableView.tableFooterView bounds];
    CGRect footerRectInTable = [self.tableView convertRect:footerBounds fromView:self.tableView.tableFooterView];
    
    [self.tableView scrollRectToVisible:footerRectInTable animated:YES];
}

- (void)clicFinish
{
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Terminer Sélection Revivre Moment"];
    
    // DEBUG
    //NSLog(@"Photos à uploader = %i",self.photosToUpload.count);
    
    /*for (Photo *photo in self.photosToUpload) {
        NSLog(@"photo.assetUrl = %@", photo.assetUrl);
    }
    
    NSLog(@"Finish !");*/
    
    if (self.photosToUpload.count == 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Cross.png"]];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Search_NoSelectedPhoto", nil);
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    } else {
        
        RevivrePartagerViewController *partagerViewController = [[RevivrePartagerViewController alloc] initWithTimeLine:self.timeLine moments:self.moments photos:self.photosToUpload.copy];
        
        [self.navigationController pushViewController:partagerViewController animated:YES];
    }
}

#pragma mark - Data source

- (void)reloadData
{
    if (!_groupByDate) {
        REPhotoGroup *group = [[REPhotoGroup alloc] init];
        group.month = 1;
        group.year = 1900;
        [_ds removeAllObjects];
        for (NSObject *object in _datasource) {
            [group.items addObject:object];
        }
        [_ds addObject:group];
        return;
    }
    NSArray *sorted = [_datasource sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSObject <REPhotoObjectProtocol> *photo1 = obj1;
        NSObject <REPhotoObjectProtocol> *photo2 = obj2;
        return ![photo1.date compare:photo2.date];
    }];
    [_ds removeAllObjects];
    for (NSObject *object in sorted) {
        NSObject <REPhotoObjectProtocol> *photo = (NSObject <REPhotoObjectProtocol> *)object;
        //NSLog(@"photo.assetUrl = %@", [photo.assetUrl absoluteString]);
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
                                        NSMonthCalendarUnit | NSYearCalendarUnit fromDate:photo.date];
        NSUInteger day = [components day];
        NSUInteger month = [components month];
        NSUInteger year = [components year];
        REPhotoGroup *group = ^REPhotoGroup *{
            for (REPhotoGroup *group in _ds) {
                if (group.month == month && group.year == year && group.day == day) {
                    return group;
                }
            }
            return nil;
        }();
        
        /*if (self.events) {
            for (FacebookEvent *fbEvent in self.events) {
                
                if (fbEvent.startTime) {
                    NSDateComponents *fbEventComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
                                                           NSMonthCalendarUnit | NSYearCalendarUnit fromDate:fbEvent.startTime];
                    
                    
                    NSUInteger dayEvent = fbEventComponents.day;
                    NSUInteger monthEvent = fbEventComponents.month;
                    NSUInteger yearEvent = fbEventComponents.year;
                    
                    //NSLog(@"fbEvent.name = %@", fbEvent.name);
                    //NSLog(@"dayEvent = %ui", dayEvent);
                    //NSLog(@"monthEvent = %ui", monthEvent);
                    //NSLog(@"yearEvent = %ui", yearEvent);
                    
                    if (month == monthEvent && year == yearEvent && day == dayEvent) {
                        
                        //NSLog(@"La photo correspond à la date de l'event !");
                        
                        
                        
                        if (group == nil) {
                            group = [[REPhotoGroup alloc] init];
                            group.name = fbEvent.name;
                            group.day = day;
                            group.month = month;
                            group.year = year;
                            group.momentId = [self getMomentIdFromFBEventId:fbEvent.eventId];
                            [group.items addObject:photo];
                            [_ds addObject:group];
                        } else {
                            [group.items addObject:photo];
                        }
                    }
                }
            }
        }*/
        if (self.moments) {
            for (MomentClass *moment in self.moments) {
                
                if (moment.dateDebut) {
                    NSDateComponents *fbEventComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
                                                           NSMonthCalendarUnit | NSYearCalendarUnit fromDate:moment.dateDebut];
                    
                    
                    NSUInteger dayEvent = fbEventComponents.day;
                    NSUInteger monthEvent = fbEventComponents.month;
                    NSUInteger yearEvent = fbEventComponents.year;
                    
                    //NSLog(@"fbEvent.name = %@", fbEvent.name);
                    //NSLog(@"dayEvent = %ui", dayEvent);
                    //NSLog(@"monthEvent = %ui", monthEvent);
                    //NSLog(@"yearEvent = %ui", yearEvent);
                    
                    if (month == monthEvent && year == yearEvent && day == dayEvent) {
                        
                        //NSLog(@"La photo correspond à la date de l'event !");
                        
                        
                        
                        if (group == nil) {
                            group = [[REPhotoGroup alloc] init];
                            group.name = moment.titre;
                            group.day = day;
                            group.month = month;
                            group.year = year;
                            group.momentId = moment.momentId;
                            photo.momentId = moment.momentId;
                            [group.items addObject:photo];
                            [_ds addObject:group];
                        } else {
                            photo.momentId = group.momentId;
                            [group.items addObject:photo];
                        }
                    }
                }
            }
        }
    }
    
    [self.tableView reloadData];
    
    [self updateNavBar];
}

/*- (NSNumber *)getMomentIdFromFBEventId:(NSString *)eventId
{
    NSLog(@"fbEvent.eventId = %@", eventId);
    
    for (MomentClass *moment in self.moments) {
        NSLog(@"moment.facebookId = %@", moment.facebookId);
        
        if ([eventId isEqualToString:moment.facebookId]) {
            NSLog(@"fbEvent.eventId = moment.facebookId = %@", moment.facebookId);
            
            NSLog(@"moment.momentId = %@", moment.momentId);
            
            return moment.momentId;
        }
    }
    
    return 0;
}*/

#pragma mark -
#pragma mark UITableViewController functions

- (void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _ds = [[NSMutableArray alloc] init];
        self.groupByDate = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (id)initWithDatasource:(NSArray *)datasource
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.datasource = [NSMutableArray arrayWithArray:datasource];
    }
    return self;
}

- (id)initWithDatasource:(NSArray *)datasource moments:(NSArray *)moments timeLine:(UIViewController <TimeLineDelegate> *)timeLine andThumbnailViewClass:(Class)thumbnailViewClass
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.moments = [NSArray arrayWithArray:moments];
        self.timeLine = timeLine;
        self.thumbnailViewClass = thumbnailViewClass;
        self.datasource = [NSMutableArray arrayWithArray:datasource];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_ds count] == 0) return 0;
    if (!_groupByDate) return 1;
    
    if ([self tableView:self.tableView numberOfRowsInSection:[_ds count] - 1] == 0) {
        return [_ds count] - 1;
    }
    return [_ds count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    REPhotoGroup *group = (REPhotoGroup *)[_ds objectAtIndex:section];
    return ceil(group.items.count / 4.0f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"REPhotoThumbnailsCell";
    REPhotoThumbnailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        // DEBUG
        //NSLog(@"La cell est vide.. On la créée | section = %i - row = %i",indexPath.section, indexPath.row);
        cell = [[REPhotoThumbnailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier thumbnailViewClass:_thumbnailViewClass];
        cell.imageView.userInteractionEnabled = YES;
        cell.imageView.tag = indexPath.row;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    REPhotoGroup *group = (REPhotoGroup *)[_ds objectAtIndex:indexPath.section];
    // DEBUG
    //NSLog(@"group.momentId = %@",group.momentId);
    
    int startIndex = indexPath.row * 4;
    int endIndex = startIndex + 4;
    if (endIndex > group.items.count)
        endIndex = group.items.count;
    
    [cell removeAllPhotos];
    for (int i = startIndex; i < endIndex; i++) {
        NSObject <REPhotoObjectProtocol> *photo = [group.items objectAtIndex:i];
        [cell addPhoto:photo];
    }
    [cell refresh];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return !_groupByDate ? 0 : 31;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    REPhotoGroup *group = (REPhotoGroup *)[_ds objectAtIndex:section];
    
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%i-%i-1", group.year, group.month]];
    
    //[dateFormatter setDateFormat:@"MMMM yyyy"];
    //NSString *resultString = [dateFormatter stringFromDate:date];
    //return resultString;
    
    return group.name;
}*/

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    REPhotoGroup *group = (REPhotoGroup *)[_ds objectAtIndex:section];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(5, 4, tableView.bounds.size.width, 23);
    label.textColor = [UIColor whiteColor];
    label.font = [[Config sharedInstance] defaultFontWithSize:16];
    label.text = group.name;
    label.backgroundColor = [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 31)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bandeau_titre.png"]];
    //[headerView setBackgroundColor:[Config sharedInstance].orangeColor];
    
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //NSLog(@"section = %i | _ds.count = %i", section, _ds.count);
    /*if (section == _ds.count-1) {
        NSLog(@"viewForFooterInSection BOTTOM");
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        view.backgroundColor = [UIColor redColor];
        [view addSubview:self.finishButton];
        
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
        return view;
    }*/
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 5)];
    return view;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - REPhotoThumbnailsCell delegate

- (void)tableViewCell:(REPhotoThumbnailsCell *)tableViewCell addPhotoToUpload:(Photo *)photo
{
    if (![self.photosToUpload containsObject:photo]) {
        [self.photosToUpload addObject:photo];
    }
}

- (void)tableViewCell:(REPhotoThumbnailsCell *)tableViewCell removePhotoToUpload:(Photo *)photo
{
    if ([self.photosToUpload containsObject:photo]) {
        [self.photosToUpload removeObject:photo];
    }
}

@end
