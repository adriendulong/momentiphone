//
//  ChatViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MomentCoreData+Model.h"
#import "ChatMessageCoreData+Model.h"
#import "CustomChatTextView.h"
#import "RootOngletsViewController.h"

#define CHAT_CELL_DEFAULT_HEIGHT 56.0f
#define CHAT_CELL_OFFSET_HEIGHT 33.0f

enum ChatViewControllerMessagePosition {
    ChatViewControllerMessagePositionTop = 0,
    ChatViewControllerMessagePositionBottom = 1
};

@interface ChatViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, OngletViewController>

@property (nonatomic, strong) MomentClass* moment;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *users;

@property (nonatomic) NSInteger nextPage;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) RootOngletsViewController *rootViewController;
@property (nonatomic, weak) IBOutlet UIScrollView *keyboardScrollView;
@property (nonatomic, strong) NSMutableArray *cellSizes;

@property (nonatomic, strong) IBOutlet UIView *sendboxView;
@property (nonatomic, weak) IBOutlet UIImageView *sendboxTextBackgroundView;
@property (nonatomic, weak) IBOutlet CustomChatTextView *sendboxTextView;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;

- (id) initWithMoment:(MomentClass*)moment withRootViewController:(RootOngletsViewController*)rootViewController;

- (void)loadMessagesForPage:(NSInteger)page
                 atPosition:(enum ChatViewControllerMessagePosition)position
                  withEnded:(void (^) (void))block;

- (void)loadMessagesAtPosition:(enum ChatViewControllerMessagePosition)position;

@end
