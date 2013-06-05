//
//  FeedViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FeedViewController.h"
#import "Feed.h"
#import "ProfilViewController.h"
#import "Config.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"

#import "FeedPhotoCell.h"
#import "FeedSmallCell.h"
#import "FeedChatCell.h"
#import "FeedFollowCell.h"
#import "FeedNewMomentCell.h"

#import "GAI.h"

#define TABLEVIEW_SCROLLVIEW_TAG_IDENTIFER -1

@interface FeedViewController () {
    @private
    BOOL isEmpty;
    NSInteger currentPage, nextPage;
}

@end

@implementation FeedViewController

@synthesize rootViewController = _rootViewController;
@synthesize feeds = _feeds;

- (id)initWithRootViewController:(RootTimeLineViewController*)rootViewController
{
    self = [super initWithNibName:@"FeedViewController" bundle:nil];
    if (self) {
        self.rootViewController = rootViewController;
        self.feeds = [[NSMutableArray alloc] init];
        currentPage = 1;
        nextPage = -1;
        isEmpty = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    self.tableView.frame = frame;
    self.tableView.tag = TABLEVIEW_SCROLLVIEW_TAG_IDENTIFER;
    self.tableView.scrollsToTop = YES; // Scroll to tap on clic on navigation bar
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    // Pull To Refresh
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    // Infinite Scroll
    __weak FeedViewController *weakCopy = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakCopy loadNextPageWithEnded:^{
            [weakCopy.tableView.infiniteScrollingView stopAnimating];
        }];
    }];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppDelegate updateActualViewController:self];
    [self reloadData];
}

#pragma mark - Load

- (void)loadDataAtPage:(NSInteger)page
         withSaveBlock:(void (^) (NSArray *feeds))saveBlock
             withEnded:(void (^) (void))endBlock
{
    [Feed getFeedsAtPage:nextPage withEnded:^(NSDictionary *feeds) {
        
        nextPage = [feeds[@"next_page"] intValue];
        
        if(saveBlock)
            saveBlock(feeds[@"feeds"]);
        
        [self.tableView reloadData];
        
        if(endBlock)
            endBlock();
    }];
}

- (void)loadNextPageWithEnded:(void (^) (void))block
{
    if(nextPage > currentPage) {
        
        // Load next page
        [self loadDataAtPage:nextPage withSaveBlock:^(NSArray *feeds) {
            [self.feeds addObjectsFromArray:feeds];
        } withEnded:block];
    }
    else {
        
        // Reload Current page
        [self loadDataAtPage:currentPage withSaveBlock:^(NSArray *feeds) {
            for(Feed *f in feeds)
            {                
                if(![self.feeds containsObject:f]) {
                    [self.feeds addObject:f];
                }
            }
        } withEnded:block];
    }
    
}

- (void)reloadDataWithEnded:(void (^) (void))block
{
    [self loadDataAtPage:1 withSaveBlock:^(NSArray *feeds) {
        self.feeds = feeds.mutableCopy;
    } withEnded:block];
}

- (void)reloadData
{
    [self reloadDataWithEnded:nil];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    // Google Analytics
    [FeedViewController sendGoogleAnalyticsEvent:@"Swipe" label:@"Rechargement" value:nil];
    
    [self reloadDataWithEnded:^{
        [refreshControl endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int taille = [self.feeds count];
    if(taille == 0) {
        isEmpty = YES;
        self.tableView.scrollEnabled = NO;
        return 1;
    }
    
    isEmpty = NO;
    self.tableView.scrollEnabled = YES;
    return taille;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if(isEmpty)
       return self.tableView.frame.size.height;
    
    Feed *feed = self.feeds[indexPath.row];
    
    switch (feed.type) {
        case FeedTypePhoto:
            return 366.0f;
            break;
        
        case FeedTypeFollow:
            return 104.0f;
            break;
            
        case FeedTypeChat: {
            FeedMessage *fm = (FeedMessage*)feed;
            return fm.shouldUseLargeView ? 141.0f : 108.0f;
        } break;
            
        case FeedTypeNewEvent:
            return 155.0f;
        break;
            
        default:
            return 163.0f;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    UITableViewCell *cell = nil;
    
    if(isEmpty)
    {
        CellIdentifier = @"FeedViewController_EmptyCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = cell.frame;
            frame.size = self.tableView.frame.size;
            cell.frame = frame;
            
            UILabel *label = [[UILabel alloc] init];
            label.text = @"Aucun feed actuellement ...";
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
    else
    {
        Feed *feed = self.feeds[indexPath.row];
        
        switch (feed.type) {
            case FeedTypePhoto:
                
                CellIdentifier = [NSString stringWithFormat:@"FeedViewController_PhotoCell_%d", feed.feedId];
                
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if(cell == nil) {
                    cell = [[FeedPhotoCell alloc] initWithFeed:(FeedPhoto*)feed
                                             reuseIdentifier:CellIdentifier
                                                    delegate:self
                                                       index:indexPath.row];
                }
                
                break;
                
            case FeedTypeChat: {
                
                CellIdentifier = [NSString stringWithFormat:@"FeedViewController_ChatCell_%d", feed.feedId];
                
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if(cell == nil) {
                    cell = [[FeedChatCell alloc] initWithFeed:(FeedMessage*)feed
                                               reuseIdentifier:CellIdentifier
                                                      delegate:self];
                }
            
            } break;
                
            case FeedTypeFollow: {
                
                CellIdentifier = [NSString stringWithFormat:@"FeedViewController_FollowCell_%d", feed.feedId];
                
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if(cell == nil) {
                    cell = [[FeedFollowCell alloc] initWithFeed:(FeedFollow*)feed
                                               reuseIdentifier:CellIdentifier
                                                      delegate:self];
                }
                
            } break;
                
            case FeedTypeNewEvent: {
                
                CellIdentifier = [NSString stringWithFormat:@"FeedViewController_NewMomentCell_%d", feed.feedId];
                
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if(cell == nil) {
                    cell = [[FeedNewMomentCell alloc] initWithFeed:feed
                                                reuseIdentifier:CellIdentifier
                                                       delegate:self];
                }
                
            } break;
                
            default:
                
                CellIdentifier = [NSString stringWithFormat:@"FeedViewController_Cell_%d", feed.feedId];
                
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if(cell == nil) {
                    cell = [[FeedSmallCell alloc] initWithFeed:feed
                                               reuseIdentifier:CellIdentifier
                                                      delegate:self];
                }
                
                break;
        }
        
        
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = self.feeds[indexPath.row];
    
    switch (feed.type) {
            
        case FeedTypeChat:
            
            // Google Analytics
            [FeedViewController sendGoogleAnalyticsEvent:@"Clic Motif" label:@"Motif - Chat" value:nil];
            
            [self showTchatView:feed.moment];
            break;
    
        case FeedTypePhoto:
            
            // Google Analytics
            [FeedViewController sendGoogleAnalyticsEvent:@"Clic Motif" label:@"Motif - Photo" value:nil];
            
            [self showPhotoView:feed.moment];
            break;
            
        case FeedTypeGoing:
            
            // Google Analytics
            [FeedViewController sendGoogleAnalyticsEvent:@"Clic Motif" label:@"Motif - Va à un Moment" value:nil];
            
        case FeedTypeInvited:
            
            // Google Analytics
            [FeedViewController sendGoogleAnalyticsEvent:@"Clic Motif" label:@"Motif - Invitation" value:nil];
            
        case FeedTypeNewEvent:
            
            // Google Analytics
            [FeedViewController sendGoogleAnalyticsEvent:@"Clic Motif" label:@"Motif - Nouveau Moment" value:nil];
            
            [self showInfoMomentView:feed.moment];
            break;
            
        default:
            break;
    }
}

#pragma mark - FeedViewController Delegate

- (void)showProfile:(UserClass*)user
{
    ProfilViewController *profile = [[ProfilViewController alloc] initWithUser:user];
    [self.rootViewController.navController pushViewController:profile animated:YES];
}

- (NSString*)timePastSinceDate:(NSDate*)date
{
    static NSDateFormatter *dateFormatter = nil;
    
    NSTimeInterval delta = [NSDate timeIntervalSinceReferenceDate] - [date timeIntervalSinceReferenceDate];
    NSString *texte = nil;
    
    // Il y a moins d'une minute
    if(delta <= 60)
    {
        texte = @"A L'INSTANT";
    }
    // Il y a moins d'une heure
    else if(delta < 60*60)
    {
        delta /= 60.0; // Nombre de minutes
        NSInteger minutes = (NSInteger)floor(delta); // Supprime décimales
        texte = [NSString stringWithFormat:@"IL Y A %d min", minutes];
    }
    // Il y a moins d'un jour
    else if(delta < 24*60*60)
    {
        delta /= 60.0*60.0; // Nombre d'heures
        NSInteger heures = (NSInteger)floor(delta); // Supprime décimales
        texte = [NSString stringWithFormat:@"IL Y A %dh", heures];
    }
    // Il y a moins d'une semaine
    else if(delta < 7*24*60*60)
    {
        delta /= 24.0*60.0*60.0; // Nombre de jours
        NSInteger jours = (NSInteger)floor(delta);
        texte = [NSString stringWithFormat:@"IL Y A %d J", jours];
    }
    // Afficher date
    else
    {
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale currentLocale];
            dateFormatter.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.calendar = [NSCalendar currentCalendar];
            dateFormatter.dateFormat = @"dd/MM/yyyy";
        }
        
        texte = [dateFormatter stringFromDate:date];
    }
    
    return texte;
}

#pragma mark - Google Analytics

+ (void)sendGoogleAnalyticsView {
    [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Feed"];
}

+ (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Feed"
     withAction:action
     withLabel:label
     withValue:value];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Si ce n'est pas la scroll view principale mais une des scroll view des photos
    if(scrollView.tag != TABLEVIEW_SCROLLVIEW_TAG_IDENTIFER)
    {
        // Force à s'arreter sur une photo
        NSInteger index = lrintf(targetContentOffset->x/BIGFEED_SCROLL_WIDTH);
        targetContentOffset->x = index * (BIGFEED_SCROLL_OFFSET + BIGFEED_SCROLL_WIDTH);
    }

}


#pragma mark Redirection Onglets

- (void)showOnglet:(enum OngletRank)onglet forMoment:(MomentClass*)moment
{
    // Si une nouvelle cellule a été selectionnée
    if( (!self.ongletsViewController) || (self.ongletsViewController.moment != moment) ) {
        self.ongletsViewController = [[RootOngletsViewController alloc]
                                      initWithMoment:moment
                                      withOnglet:onglet
                                      withTimeLine:self.rootViewController.privateTimeLine];
    }
    else
        [self.ongletsViewController addAndScrollToOnglet:onglet];
    
    [self.rootViewController.navController pushViewController:self.ongletsViewController animated:YES];
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

#pragma mark Redirection Profonde

- (void)showInviteViewControllerWithMoment:(MomentClass *)moment
{
    [self.rootViewController.navController popToRootViewControllerAnimated:NO];
    [self.rootViewController.ddMenuViewController showRootController:YES];
    [self showInfoMomentView:moment];
}

@end
