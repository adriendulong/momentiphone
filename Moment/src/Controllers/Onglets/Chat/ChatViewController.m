//
//  ChatViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatMessage+Server.h"
#import "ChatTableViewCell.h"
#import "ChatTableViewEmptyCell.h"
#import "Config.h"

@interface ChatViewController () {
    @private
    BOOL isEmpty;
    NSInteger emptyCellSize;
    BOOL isScrolling;
    CGFloat sendBoxDefaultHeight;
    BOOL isLoading;
    UIActivityIndicatorView *activityIndicatorView;
    NSInteger previousScrolledPoint;
    
    NSInteger keyboardTop;
}

@end

@implementation ChatViewController

@synthesize moment = _moment;
@synthesize messages = _messages;
@synthesize users = _users;

@synthesize nextPage = _nextPage;
@synthesize dateFormatter = _dateFormatter;

@synthesize tableView = _tableView;
@synthesize rootViewController = _rootViewController;
@synthesize keyboardScrollView = _keyboardScrollView;
@synthesize cellSizes = _cellSizes;

@synthesize sendboxView = _sendboxView;
@synthesize sendboxTextView = _sendboxTextView;
@synthesize sendboxTextBackgroundView = _sendboxTextBackgroundView;
@synthesize sendButton = _sendButton;

#pragma mark - Init

- (id)initWithMoment:(MomentClass*)moment withRootViewController:(RootOngletsViewController*)rootViewController;
{
    self = [super initWithNibName:@"ChatViewController" bundle:nil];
    if(self) {
        self.moment = moment;
        self.messages = [[NSMutableArray alloc] init];
        self.cellSizes = [[NSMutableArray alloc] init];
        self.users = [[NSMutableArray alloc] init];
        self.rootViewController = rootViewController;
        self.nextPage = 1;
        isEmpty = YES;
        isScrolling = NO;
        isLoading = NO;
        
        keyboardTop = 216;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iPhone 5 Support    
    // View frame
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    
    // Keyboard ScrollView Size
    self.keyboardScrollView.contentSize = CGSizeMake(320, self.view.frame.size.height + 216);
    
    // TableView Frame
    self.tableView.frame = CGRectMake(0, 0, 320, frame.size.height - self.sendboxView.frame.size.height);
    emptyCellSize = frame.size.height - TOPBAR_HEIGHT - self.sendboxView.frame.size.height;
    
    // SendBoxView
    frame = self.sendboxView.frame;
    frame.origin.y = self.tableView.frame.size.height;
    self.sendboxView.frame = frame;
    self.sendboxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chat_sendbox_bg"]];
    sendBoxDefaultHeight = frame.size.height;
    
    // Strechable Background TextField
    UIImage *image = [[VersionControl sharedInstance] resizableImageFromImage:self.sendboxTextBackgroundView.image withCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    self.sendboxTextBackgroundView.image = image;
        
    // Suvbiews
    [self.keyboardScrollView addSubview:self.tableView];
    [self.keyboardScrollView addSubview:self.sendboxView];
    
    // Gesture Recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTouch)];
    [self.tableView addGestureRecognizer:tap];
    
    // Load infinite
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    frame = activityIndicatorView.frame;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
    frame.origin.y = -frame.size.height - 30;
    activityIndicatorView.frame = frame;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"ChatViewController_InfiniteScroll_LoadMore", nil);
    label.font = [[Config sharedInstance] defaultFontWithSize:12];
    label.textColor = [Config sharedInstance].textColor;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    frame = label.frame;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
    frame.origin.y = -frame.size.height - 10;
    label.frame = frame;
    
    [self.tableView addSubview:activityIndicatorView];
    [self.tableView addSubview:label];
    
    // Privacy
    // User State
    enum UserState state = self.moment.state.intValue;
    if(state == 0) {
        state = ([self.moment.owner.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]) ? UserStateOwner : UserStateNoInvited;
    }
     
    if(
       (
        (
         (self.moment.privacy.intValue == MomentPrivacyFriends)||(self.moment.privacy.intValue == MomentPrivacySecret))
        && (state != UserStateNoInvited)
        ) ||
       (self.moment.privacy.intValue == MomentPrivacyOpen)
       )
    {
        self.sendboxView.hidden = NO;
    }
    else {
        self.sendboxView.hidden = YES;
    }
    
    // Load Messages
    [self loadMessagesAtPosition:ChatViewControllerMessagePositionBottom];
}

- (void)viewDidUnload
{
    [self setMessages:nil];
    [self setMoment:nil];
    [self setSendboxTextBackgroundView:nil];
    [self setSendboxTextView:nil];
    [self setSendboxView:nil];
    [self setSendButton:nil];
    [self setTableView:nil];
    [self setDateFormatter:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self sendGoogleAnalyticsView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsView {
    [[[GAI sharedInstance] defaultTracker] sendView:@"Vue Chat"];
}

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Chat"
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
    int taille = [self.messages count];
    if(taille == 0) {
        isEmpty = YES;
        return 1;
    }
    isEmpty = NO;
    return taille;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *CellIdentifier = nil;
    if(isEmpty) {
        CellIdentifier = @"ChatTableViewEmptyCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
            cell = [[ChatTableViewEmptyCell alloc] initWithHeight:emptyCellSize reuseIdentifier:CellIdentifier];
    }
    else {
        
        // Message
        //int taille = [self.messages count];
        int index = indexPath.row; // taille - 1 - indexPath.row
        ChatMessage *message = self.messages[index];
        UserClass *user = message.user;
        
        // Cell ID
        CellIdentifier = [NSString stringWithFormat:@"ChatTableViewCell_%f_%@_%@_%@_%@", [message.date timeIntervalSince1970], user.userId, user.facebookId, user.nom, user.prenom ];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[ChatTableViewCell alloc]
                    initWithChatMessage:message
                    withDateFormatter:self.dateFormatter
                    withHeight:[self.cellSizes[index] floatValue]
                    reuseIdentifier:CellIdentifier
                    navigationController:self.rootViewController.navigationController];
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEmpty)
        return emptyCellSize;
    
    // Default = 93.0f
    return [self.cellSizes[indexPath.row] floatValue] + CHAT_CELL_OFFSET_HEIGHT;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect frame = self.sendboxView.frame;
    frame.origin.y = self.tableView.frame.size.height - frame.size.height;
    self.sendboxView.frame = frame;
    return self.sendboxView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.sendboxView.frame.size.height;
}
*/

- (void)reloadData
{    
    // Update size
    [self.tableView reloadData];
}

- (void)scrollToLastMessage
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messages.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Data

- (void)addMessage:(ChatMessage*)message atPosition:(enum ChatViewControllerMessagePosition)position
{
    // Si le message n'est pas déjà dans la conversation
    if(![self.messages containsObject:message]) {
        
        // Si le message doit etre mis à jour en local
        BOOL continuer = YES;
        for(ChatMessage *m in self.messages) {
            if(m.user && m.user.userId)
            {
                if( (m.messageId == nil) && [m.message isEqualToString:message.message] && [m.user.userId isEqualToNumber:message.user.userId] ) {
                    m.messageId = message.messageId;
                    m.date = message.date;
                    continuer = NO;
                    break;
                }
            }
        }
        
        if(continuer)
        {
            // Calulate cell size
            CGSize size = [message.message sizeWithFont:[[Config sharedInstance] defaultFontWithSize:12] constrainedToSize:CGSizeMake(203, 99999) lineBreakMode:NSLineBreakByTruncatingTail];
            
            // Set default size if needed
            CGFloat height = (size.height > 20)? size.height  : CHAT_CELL_DEFAULT_HEIGHT - CHAT_CELL_OFFSET_HEIGHT;
            
            // Position d'insertion
            NSInteger index = (position == ChatViewControllerMessagePositionTop)? 0 : [self.messages count];
            
            // Save size and data
            [self.cellSizes insertObject:@(height) atIndex:index];
            [self.messages insertObject:message atIndex:index];
            
            // Si l'utilisateur n'est pas déjà dans la conversation, on l'ajoute
            if( message.user && ![self.users containsObject:message.user]) {
                [self.users addObject:message.user];
            }
        }
        
        
    }
}

- (void)addMessagesFromArray:(NSArray*)messages atPosition:(enum ChatViewControllerMessagePosition)position
{
    int taille = [messages count];
    
    switch (position) {
        case ChatViewControllerMessagePositionTop:
            for(int i=0; i<taille; i++) {
                [self addMessage:messages[taille - 1 - i] atPosition:position];
            }
            break;
            
        case ChatViewControllerMessagePositionBottom:
            for(int i=0; i<taille; i++) {
                [self addMessage:messages[i] atPosition:position];
            }
            break;
    }
}

- (void)loadMessagesForPage:(NSInteger)page
                 atPosition:(enum ChatViewControllerMessagePosition)position
                  withEnded:(void (^) (void))block
{
    if(!block) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"MBProgressHUD_Loading", nil);
    }
    
    dispatch_queue_t loadingQueue = dispatch_queue_create("loadingQueue", NULL);
    dispatch_async(loadingQueue, ^{
        [ChatMessage getMessagesForMoment:self.moment atPage:page withEnded:^(NSDictionary *attributes) {
                        
            if(attributes[@"failure"]) {
                MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                overlay.delegate = (UIViewController <MTStatusBarOverlayDelegate> *)self;
                [overlay postImmediateErrorMessage:NSLocalizedString(@"StatusBarOverlay_LoadingFailure", nil) duration:1 animated:YES];
                
                // Supprimer du local !
#warning TODO
                
            }
            
            if(attributes)
            {
                [self addMessagesFromArray:attributes[@"chats"] atPosition:position];
                isEmpty = ([self.messages count] == 0);
                if(position == ChatViewControllerMessagePositionTop)
                    self.nextPage = [attributes[@"next_page"] intValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadData];
                    
                    // Show last message
                    if(position == ChatViewControllerMessagePositionBottom)
                        [self scrollToLastMessage];
                    
                    if(block)
                        block();
                    else
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
            else if(block)
                block();
            
        }];
    });
    dispatch_release(loadingQueue);
}

- (void)loadMessagesAtPosition:(enum ChatViewControllerMessagePosition)position {
    switch (position) {
        case ChatViewControllerMessagePositionBottom:
            [self loadMessagesForPage:1 atPosition:position withEnded:nil];
            break;
            
        case ChatViewControllerMessagePositionTop:
            [self loadMessagesForPage:self.nextPage atPosition:position withEnded:nil];
            break;
    }
    
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // Remonter Scroll View
    [self.keyboardScrollView scrollRectToVisible:CGRectMake(0, keyboardTop, 320, self.view.frame.size.height) animated:YES];
        
    // On réduit la taille de la vue pour voir les messages
    CGRect frame = self.tableView.frame;
    frame.origin.y = keyboardTop;
    frame.size.height = self.view.frame.size.height - keyboardTop - TOPBAR_HEIGHT;
    self.tableView.frame = frame;
    [self scrollToLastMessage];
    /*
    NSInteger realSize = self.view.frame.size.height - self.sendboxView.frame.size.height - keyboardTop;
    if(totalSize < realSize) {
        CGRect frame = self.tableView.frame;
        frame.size.height = totalSize;
        //frame.origin.y = realSize - totalSize + TOPBAR_HEIGHT + self.sendboxView.frame.size.height;
        frame.origin.y = self.view.frame.size.height - keyboardTop - totalSize + TOPBAR_HEIGHT + 7;
        self.tableView.frame = frame;
    }
    */
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Entrée Clavier" label:@"Ecrit dans le Chat" value:nil];
    
    [self updateSendBoxSize];
}

- (void)updateSendBoxSize {
    // Calcul de la taille
    CGSize size = [self.sendboxTextView.text sizeWithFont:self.sendboxTextView.font constrainedToSize:CGSizeMake(self.sendboxTextView.frame.size.width, 200)];
    CGFloat lineHeight = [self.sendboxTextView.font lineHeight];
    CGFloat delta = ceilf(size.height/lineHeight);
    
    CGFloat height = MAX( delta*lineHeight, sendBoxDefaultHeight );
    
    // Si la taille change
    if( height != self.sendboxTextView.frame.size.height) {
        
        // Change View Frame
        CGRect frame = self.sendboxView.frame;
        frame.size.height = height;
        frame.origin.y = self.view.frame.size.height - height;
        self.sendboxView.frame = frame;
        
        // Background textview
        CGRect frame2 = self.sendboxTextBackgroundView.frame;
        frame2.origin.y = 5;
        frame2.size.height = frame.size.height - 2*5;
        self.sendboxTextBackgroundView.frame = frame2;
        
        // Change TextView frame
        frame2.origin.x += 8;
        frame2.size.width -= 2*16;
        frame2.origin.y += 4;
        frame2.size.height -= 4 + 3;
        self.sendboxTextView.frame = frame2;
        
        // TableView Frame
        frame = self.tableView.frame;
        frame.origin.y = keyboardTop;
        frame.size.height = self.view.frame.size.height - keyboardTop - TOPBAR_HEIGHT;
        self.tableView.frame = frame;
        [self scrollToLastMessage];
        
        // Button Frame
        frame = self.sendButton.frame;
        frame.origin.y = self.sendboxView.frame.size.height - frame.size.height - 5;
        self.sendButton.frame = frame;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Descendre Scroll View
    [self.keyboardScrollView scrollRectToVisible:CGRectMake(0, 0, 320, self.view.frame.size.height) animated:YES];
    
    // Rétablir la taille de la tableView
    CGRect frame = self.tableView.frame;
    frame.origin.y = 0;
    frame.size.height = self.view.frame.size.height - self.sendboxView.frame.size.height;
    self.tableView.frame = frame;
}

- (void)cancelTouch {
    [self.sendboxTextView resignFirstResponder];
}

#pragma mark - Getters

- (NSDateFormatter*)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [NSLocale currentLocale];
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _dateFormatter.calendar = [NSCalendar currentCalendar];
    }
    return _dateFormatter;
}

#pragma mark - Actions

- (IBAction)clicSendMessage
{
    if([self.sendboxTextView.text length] > 0) {
        
        // Google Analytics
        [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Post un Chat" value:nil];
        
        // Ajout du message en local
        ChatMessage *message = [[ChatMessage alloc] initWithText:self.sendboxTextView.text withDate:[NSDate date] withUser:[UserCoreData getCurrentUser] withId:nil];
        [ChatMessage sendNewMessageForMoment:self.moment withText:self.sendboxTextView.text withEnded:nil];
        
        self.sendboxTextView.text = @"";
        [self updateSendBoxSize];
        [self addMessage:message atPosition:ChatViewControllerMessagePositionBottom];
        [self reloadData];
        [self scrollToLastMessage];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( (!isLoading) && (scrollView.contentOffset.y < previousScrolledPoint) && (scrollView.contentOffset.y < -50) ) {
        
        isLoading = YES;
        [activityIndicatorView startAnimating];
        
        // Google Analytics
        [self sendGoogleAnalyticsEvent:@"Swipe" label:@"Recharge le Chat" value:nil];
        
        [self loadMessagesForPage:self.nextPage atPosition:ChatViewControllerMessagePositionTop withEnded:^ {
            [activityIndicatorView stopAnimating];
            isLoading = NO;
        }];
    }
    previousScrolledPoint = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if( [self.sendboxTextView isFirstResponder] ) {
        [self.sendboxTextView resignFirstResponder];
    }
}

@end
