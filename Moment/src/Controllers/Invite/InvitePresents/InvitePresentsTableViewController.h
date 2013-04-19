//
//  InvitePresentsTableViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCoreData+Model.h"
#import "MomentClass.h"

@interface InvitePresentsTableViewController : UITableViewController

@property (nonatomic, weak) UINavigationController *navController;
@property (nonatomic, strong) UserClass *owner;
@property (nonatomic, strong) MomentClass *moment;
@property (nonatomic, strong) NSArray *invites;
@property (nonatomic) BOOL adminAuthorisation;

- (id)initWithOwner:(UserClass*)owner
         withMoment:(MomentClass*)moment
   withInvitedUsers:(NSArray*)invites
withAdminAuthoristion:(BOOL)adminAuthorisation
navigationController:(UINavigationController*)navController;

- (void)updateUserAtRow:(NSInteger)row asAdmin:(BOOL)admin withEnded:( void (^) (BOOL success) )block;

@end