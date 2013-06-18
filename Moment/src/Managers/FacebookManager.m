//
//  FacebookManager.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FacebookManager.h"
#import "AFMomentAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "FacebookEvent.h"
#import "UserClass+Server.h"
#import "UserClass+Mapping.h"

@implementation FacebookManager

@synthesize httpClient = _httpClient;
@synthesize dateFormatter = _dateFormatter;
@synthesize defaultReadPermissions = _defaultReadPermissions;
@synthesize defaultPublishPermissions = _defaultPublishPermissions;
@synthesize tokenCachingStrategy = _tokenCachingStrategy;

static NSString *kFbGraphBaseURL = @"http://graph.facebook.com/";
static NSString *FBSessionStateChangedNotification = @"com.appMoment.Moment:FBSessionStateChangedNotification";

// Permissions
static NSString *kFbPermissionEmail = @"email";
static NSString *kFbPermissionAboutMe = @"user_about_me";
//static NSString *kFbPermissionUserHomeTown = @"user_hometown";
//static NSString *kFbPermissionUserLocation = @"user_location";
static NSString *kFbPermissionFriendLists = @"read_friendlists";
static NSString *kFbPermissionFriendAboutMe = @"friends_about_me";
static NSString *kFbPermissionFriendHomeTown = @"friends_hometown";
static NSString *kFbPermissionFriendLocation = @"friends_location";
static NSString *kFbPermissionUserEvents = @"user_events";

static NSString *kFbPermissionRsvpEvent = @"rsvp_event";
static NSString *kFbPermissionPublishAction = @"publish_actions";
static NSString *kFbPermissionPublishStream = @"publish_stream";
static NSString *kFbPermissionPhotoUpload = @"photo_upload";


#pragma mark - Singleton

static FacebookManager *sharedInstance = nil;

+ (FacebookManager*)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

#pragma mark - TokenCachingStrategy

- (BOOL)openActiveSessionWithPermissions:(NSArray*)perms
                                    type:(enum FacebookPermissionType)type
                            allowLoginUI:(BOOL)allowLoginUI
                       completionHandler:(void (^)(FBSession *session, FBSessionState status, NSError *error))completionHandler
{
    BOOL openSessionResult = NO;
    
    // Set up token strategy, if needed
    if(!self.tokenCachingStrategy) {
        self.tokenCachingStrategy = [[FacebookTokenCachingStrategy alloc] init];
    }
    
    // Initialize a session object with the tokenCacheStrategy
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:perms
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:self.tokenCachingStrategy];
    
    // If showing the login UI, or if a cached token is available,
    // then open the session.
    if (allowLoginUI || session.state == FBSessionStateCreatedTokenLoaded) {
        // For debugging purposes log if cached token was found
        if (session.state == FBSessionStateCreatedTokenLoaded) {
            NSLog(@"Cached token found.");
        }
        
        // Set the active session
        [FBSession setActiveSession:session];
        
        // Open the session.
        [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                completionHandler:completionHandler];
        
        // Return the result - will be set to open immediately from the session
        // open call if a cached token was previously found.
        openSessionResult = session.isOpen;
    }
    // If showing the login UI, or if a cached token is available,
    // then open the session.
    
    return openSessionResult;
}

#pragma mark - Facebook Connected

- (BOOL)facebookIsConnected {
    return [self openActiveSessionWithPermissions:@[] type:FacebookPermissionReadType allowLoginUI:NO completionHandler:nil];
}

#pragma mark - Login/Logout

- (void)loginWithPermissions:(NSArray*)perms type:(enum FacebookPermissionType)type withEnded:(void (^) (BOOL success))block
{
    if (!FBSession.activeSession.isOpen) {
        // create a fresh session object
        FBSession.activeSession = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if ( FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded ) {
            
            //NSLog(@"permissions : %@", permissions);
            
            ///// Completion Handler of login
            void (^completionHandler)(FBSession *session, FBSessionState status, NSError *error) = [^(FBSession *session, FBSessionState status, NSError *error) {
                
                [self sessionStateChanged:session state:status error:error];
                
                if(error) {
                    NSLog(@"Facebook Login Error : %@", error.localizedDescription);
                    if(block)
                        block(NO);
                }
                
                // and here we make sure to update our UX according to the new session state
                else if(block) {
                    block(YES);
                }
                
            } copy];
            
            /*
            // Login by type
            switch (type) {
                    
                // Read
                case FacebookPermissionReadType: {
                    
                    // Default Permissions
                    NSMutableArray *permissions = self.defaultReadPermissions.mutableCopy;
                    if(perms)
                        [permissions addObjectsFromArray:perms];
                    
                    [FBSession openActiveSessionWithReadPermissions:permissions
                                                       allowLoginUI:YES
                                                  completionHandler:completionHandler];
                } break;
                    
                // Publish
                case FacebookPermissionPublishType: {
                    
                    // Default Permissions
                    NSMutableArray *permissions = self.defaultPublishPermissions.mutableCopy;
                    if(perms)
                        [permissions addObjectsFromArray:perms];
                    
                    [FBSession openActiveSessionWithPublishPermissions:permissions
                                                       defaultAudience:FBSessionDefaultAudienceFriends
                                                       allowLoginUI:YES
                                                  completionHandler:completionHandler];
                } break;
            }
            */
            
            [self openActiveSessionWithPermissions:perms type:type allowLoginUI:YES completionHandler:completionHandler];
            
            
        }else if(block) {
            block(YES);
        }
        
    }
    else if(block) {
        block(YES);
    }
}

- (void)loginReadPermissionsWithEnded:( void (^) (BOOL success) )block {
    [self loginWithPermissions:nil type:FacebookPermissionReadType withEnded:block];
}

- (void)loginPublishPermissionsWithEnded:( void (^) (BOOL success) )block {
    [self loginWithPermissions:nil type:FacebookPermissionPublishType withEnded:block];
}

- (void)logout
{    
    if ( [self facebookIsConnected] || FBSession.activeSession.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [FBSession.activeSession closeAndClearTokenInformation];
        NSLog(@"Logout FB");
    }
}

- (BOOL)isLogged
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    return appDelegate.session.isOpen;
}


#pragma mark - Permisions

- (void)readPermissions:(NSArray*)permissions withEnded:(void (^) (BOOL success))block
{
    [[FBSession activeSession] requestNewReadPermissions:permissions completionHandler:^(FBSession *session, NSError *error) {
        
        if(block) {
            block( error != nil );
        }
        
    }];
}

- (void)publishPermissions:(NSArray*)permissions defaultAudience:(FBSessionDefaultAudience)audience withEnded:(void (^) (BOOL success))block
{
    [[FBSession activeSession] requestNewPublishPermissions:permissions defaultAudience:audience completionHandler:^(FBSession *session, NSError *error) {
        
        if(block) {
            block( error != nil );
        }
        
    }];
}

- (void)loadPermissions:(NSArray*)permisions type:(enum FacebookPermissionType)type withEnded:( void (^) (BOOL success) )block
{
    
    // Ask only for knew permissions
    NSMutableArray *newPermissions = [[NSMutableArray alloc] init];
    for( NSString *perm in permisions)
    {
        if( [FBSession.activeSession.permissions indexOfObject:perm] == NSNotFound ) {
            // Add new Permission
            [newPermissions addObject:perm];
        }
    }
    
    //NSLog(@"new Permissions : %@", newPermissions);
    
    if([newPermissions count] > 0) {
        //NSLog(@"--> ask for new permissions <--");
        
        
        switch (type) {
                
                // Read
            case FacebookPermissionReadType: {
                
                [self readPermissions:newPermissions withEnded:^(BOOL success) {
                    if(block)
                        block(success);

                }];
                
            }  break;
                
                // Publish
            case FacebookPermissionPublishType: {
                
                [self publishPermissions:newPermissions defaultAudience:FBSessionDefaultAudienceFriends withEnded:^(BOOL success) {
                    if(block)
                        block(success);
                }];
                
            }  break;
                
        }
        
        
    }
    else if(block) {
        block(YES);
    }
    
}

- (void)askForPermissions:(NSArray*)permisions type:(enum FacebookPermissionType)type withEnded:( void (^) (BOOL success) )block
{    
    if ( !FBSession.activeSession.isOpen ) {
        [self loginWithPermissions:permisions type:type withEnded:block];
    }
    else {
        [self loadPermissions:permisions type:type withEnded:block];
    }
}

#pragma mark - User Facebook

- (void)getCurrentUserInformationsWithEnded:(void (^) (UserClass* user))block
{
    
    if(block)
    {
        // Ask Permissions for Events
        [self askForPermissions:@[] type:FacebookPermissionReadType withEnded:^(BOOL success) {
            
            // Permissions Obtenue
            if(success)
            {
                // Get list events
                [FBRequestConnection
                 startWithGraphPath:@"me?fields=first_name,email,id,last_name,picture.height(600).width(600),gender"
                 completionHandler:^(FBRequestConnection *connection,
                                     id result,
                                     NSError *error) {
                     
                     if (!error) {
                         
                         UserClass *user = [[UserClass alloc] init];
                         user.prenom = result[@"first_name"];
                         user.nom = result[@"last_name"];
                         user.facebookId = result[@"id"];
                         user.email = result[@"email"];
                         user.imageString = result[@"picture"][@"data"][@"url"];
                         user.sex = ([result[@"gender"] isEqualToString:@"male"])? UserSexMale : UserSexFemale;
                         
                         block(user);
                     }
                     else{
                         
                         NSLog(@"Facebook Get User Informations Error : %@", error.localizedDescription);
                         NSLog(@"Response = %@", connection.urlResponse);
                         NSLog(@"Headers = %@", connection.urlResponse.allHeaderFields);
                         NSLog(@"Request = %@", connection.urlRequest);
                         NSLog(@"Connection = %@", connection);
                         
                         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_Title", nil)
                                                     message:[error localizedDescription]
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
                          show];
                         
                         if (block) {
                             block(nil);
                         }
                     }
                 }];
            
            }
            // Permission refusée
            else {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_Title", nil)
                                            message:@"Erreur lors de l'obtention des permissions"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
                 show];
            }
            
        }];
        
    }
}

- (void)getCurrentUserFacebookIdWithEnded:(void (^) (NSString *fbId))block
{
    if(block)
    {
        [self getCurrentUserInformationsWithEnded:^(UserClass *user) {
            if(user)
                block(user.facebookId);
            else
                block(nil);
        }];
    }
}

- (void)updateCurrentUserFacebookIdOnServer:(void (^) (BOOL success))block {
    UserClass *user = [UserCoreData getCurrentUser];
    
    // Block Update
    typedef void (^UpdateBlock) (void);
    UpdateBlock localBlock = [^ {
        [self getCurrentUserFacebookIdWithEnded:^(NSString *fbId) {
            if(fbId) {
                if (![fbId isEqualToString:user.facebookId]) {
                    // Update Server & CoreData
                    [UserClass updateCurrentUserInformationsOnServerWithAttributes:@{@"facebookId":fbId} withEnded:nil];
                    
                    if(block)
                        block(YES);
                } else {
                    if(block)
                        block(YES);
                }
            }
            else if(block) {
                block(NO);
            }
        }];
    } copy];
    
    // Save FB id
    if(user)
    {
        if(!user.facebookId || [user.facebookId intValue] == 0)
            localBlock();
        else if(user.facebookId)
            localBlock();
        else if(block)
            block(YES);
    }
    else {
        // Load User Informations
        [UserClass getLoggedUserFromServerWithEnded:^(UserClass *user) {
            if(user)
                localBlock();
            else if(block)
                block(NO);
        }];
    }
}

- (void)getUserInformationsWithId:(NSString*)facebookId withEnded:(void (^) (UserClass* user))block
{
    if(block)
    {
        // Ask Permissions for Events
        [self askForPermissions:@[] type:FacebookPermissionReadType withEnded:^(BOOL success) {
            
            // Permissions Obtenue
            if(success)
            {
                NSString *path = [NSString stringWithFormat:@"%@?fields=name,picture.height(600).width(600)", facebookId];
                
                //NSLog(@"path = %@", path);
                
                // Get list events
                [FBRequestConnection
                 startWithGraphPath:path
                 completionHandler:^(FBRequestConnection *connection,
                                     id result,
                                     NSError *error) {
                     
                     if (!error) {
                         
                         UserClass *user = [[UserClass alloc] init];
                         //user.prenom = result[@"name"];
                         user.nom = result[@"name"];
                         user.facebookId = facebookId;
                         user.imageString = result[@"picture"][@"data"][@"url"];
                         
                         block(user);
                     }
                     else{
                         
                         NSLog(@"Facebook Get User Informations Error : %@", error.localizedDescription);
                         NSLog(@"Response = %@", connection.urlResponse);
                         NSLog(@"Headers = %@", connection.urlResponse.allHeaderFields);
                         NSLog(@"Request = %@", connection.urlRequest);
                         NSLog(@"Connection = %@", connection);
                         
                         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_Title", nil)
                                                     message:[error localizedDescription]
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
                          show];
                         
                         if (block) {
                             block(nil);
                         }
                     }
                 }];
                
            }
            // Permission refusée
            else {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error_Title", nil)
                                            message:@"Erreur lors de l'obtention des permissions"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
                 show];
            }
            
        }];
    }
}

#pragma mark - Friends List

- (NSString*) mappingLocationToLocalFromFacebookAttributes:(id <FBGraphLocation>)location
{
    NSMutableString *text = [[NSMutableString alloc] init];
    if(location.street)
        [text appendFormat:@"%@ ", location.street];
    if(location.city)
        [text appendFormat:@"%@ ", location.city];
    if(location.country)
        [text appendFormat:@"%@ ", location.country];
    
    if([text length] > 0)
        return text;
    
    return nil;
}

- (NSDictionary*) mappingUserToLocalFromFacebookAttributes:(NSDictionary<FBGraphUser>*)friend
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    // Attributes
    attributes[@"facebookId"] = friend.id;
    if(friend.first_name)
        attributes[@"prenom"] = [friend.first_name uppercaseString];
    if(friend.last_name)
        attributes[@"nom"] = [friend.last_name uppercaseString];
    
    // Location
    if(friend.location.location) {
        attributes[@"adresse"] = [self mappingLocationToLocalFromFacebookAttributes:friend.location.location];
    }
    
    return attributes;
}

- (NSArray*)mappingArrayToLocalFromFacebook:(NSArray*)array
{        
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    
    for( NSDictionary<FBGraphUser>* attr in array ) {
        [newArray addObject:[self mappingUserToLocalFromFacebookAttributes:attr]];
    }
    
    // Sort by firstname
    [newArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        NSString *prenom1 = obj1[@"prenom"];
        NSString *prenom2 = obj2[@"prenom"];
        
        return [prenom1 compare:prenom2];
    }];
    
    return newArray;
}

- (void)loadFriends:( void (^) (NSArray* friends) )block
{
    // Update Facebook Id
    [self updateCurrentUserFacebookIdOnServer:^(BOOL success) {
        
        // Permissions
        [self askForPermissions:@[kFbPermissionFriendAboutMe ,kFbPermissionFriendHomeTown, kFbPermissionFriendLocation]
                           type:FacebookPermissionReadType
                      withEnded:^(BOOL success) {
                          
                          FBRequest* friendsRequest = [FBRequest requestForMyFriends];
                          friendsRequest.session = [FBSession activeSession];
                          
                          [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                                        NSDictionary* result,
                                                                        NSError *error) {
                              if(!error) {
                                  NSArray* friends = result[@"data"];
                                  
                                  if(block) {
                                      
                                      NSArray *users = [UserClass arrayOfUsersWithArrayOfAttributesFromLocal:[self mappingArrayToLocalFromFacebook:friends]];
                                      
                                      block(users);
                                  }
                              }
                              else {
                                  NSLog(@"Facebook Get Friends Error : %@", error.localizedDescription);
                                  NSLog(@"Response = %@", connection.urlResponse);
                                  NSLog(@"Headers = %@", connection.urlResponse.allHeaderFields);
                                  NSLog(@"Request = %@", connection.urlRequest);
                                  NSLog(@"Connection = %@", connection);
                                  if(block) block(nil);
                              }
                              
                          }];
                      }];
        
    }];
}

- (void)getFriendsWithEnded:(void (^) (NSArray* friends) )block
{
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        [self loginReadPermissionsWithEnded:^(BOOL success) {
            if(success)
                [self loadFriends:block];
        }];
    }
    else {
        [self loadFriends:block];
    }
    
}

- (void)getFriendProfilePrictureURL:(NSString*)facebookId withEnded:(void (^) (NSString* url) )block
{
    NSString *path = [NSString stringWithFormat:@"%@/picture", facebookId];
    
    NSDictionary *params = @{@"type" : @"normal",
                             @"redirect" : @"false"};
    
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:path parameters:params];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:30.0];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        //NSLog(@"Reçu : %@", JSON);
    
        if(block) {
            
            NSDictionary *attr = (NSDictionary*)JSON;
            NSString *url = attr[@"data"][@"url"];
            
            block(url);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //[MessageServeur showMessage:operation withError:error];
        NSLog(@"url = %@", operation.request.URL);
        NSLog(@"Operation %s fail : %@", __PRETTY_FUNCTION__, [error localizedDescription] );

        
    }];
    
    [operation start];
}

#pragma mark - Events

- (void)loadEvents:( void (^) (NSArray *events) )block
{
    if(block)
    {
        // Ask Permissions for Events
        [self askForPermissions:@[kFbPermissionUserEvents] type:FacebookPermissionReadType
                          withEnded:^(BOOL success) {
                              
                              // Permissions Obtenue
                              if(success)
                              {
                                  // Get list events
                                  [FBRequestConnection
                                   startWithGraphPath:@"me/events?fields=id,cover,description,is_date_only,name,owner,location,privacy,rsvp_status,start_time,end_time,admins,picture.type(large)"
                                   completionHandler:^(FBRequestConnection *connection,
                                                       id result,
                                                       NSError *error) {
                                       
                                       if (!error) {
                                           
                                           NSArray *webList = [result[@"data"] mutableCopy];
                                           
                                           int taille = [webList count];
                                           if (taille == 0) {
                                               if (block)
                                                   block(nil);
                                           } else {
                                               NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:taille];
                                               NSMutableArray *ownerIdsArray = [NSMutableArray arrayWithCapacity:taille];
                                               
                                               
                                               __block int i = 0;
                                               for (NSDictionary *attr in webList)
                                               {
                                                   // Owner attributes
                                                   NSDictionary *owner = @{@"facebookId":attr[@"owner"][@"id"]};
                                                   
                                                   [UserClass getUsersWhoAreOnMoment:@[owner] withEnded:^(NSArray *usersOnMoment) {
                                                       
                                                       //  ------> Create Event
                                                       FacebookEvent *event = [[FacebookEvent alloc] initWithAttributes:attr];
                                                       // Save Event
                                                       [mutableArray addObject:event];
                                                       // Save Owner ID
                                                       [ownerIdsArray addObject:[NSString stringWithFormat:@"%@", attr[@"owner"][@"id"]]];
                                                       
                                                       
                                                       //  ------> User is on Moment
                                                       if([usersOnMoment count] == 1) {
                                                           event.ownerAttributes = usersOnMoment[0];
                                                       }
                                                       
                                                       // ************** >Last event < *************
                                                       if(i == taille-1) {
                                                           
                                                           
                                                           ///////////////////////////////////////////////////////////////////////
                                                           // --------- Récupérer Owners informations depuis Server Facebook -----
                                                           ///////////////////////////////////////////////////////////////////////
                                                           [FacebookEvent arrayWithArrayOfEvents:mutableArray withArrayOfOwnerId:ownerIdsArray withEnded:^(NSArray *events) {
                                                               
                                                               
                                                               //NSLog(@"events = %@", events);
                                                               
                                                               NSMutableArray *finalArray = events.mutableCopy;
                                                               
                                                               // Sort By Date
                                                               [finalArray sortUsingComparator:^NSComparisonResult(FacebookEvent *obj1, FacebookEvent *obj2) {
                                                                   return [obj1.startTime compare:obj2.startTime];
                                                               }];
                                                               
                                                               // Final block
                                                               block(finalArray);
                                                               
                                                           }];
                                                           
                                                       }
                                                       
                                                       i++;
                                                   }];
                                               }
                                           }
                                       }
                                       else{
                                           NSLog(@"Facebook Load Events Error : %@", error.localizedDescription);
                                           NSLog(@"Response = %@", connection.urlResponse);
                                           NSLog(@"Headers = %@", connection.urlResponse.allHeaderFields);
                                           NSLog(@"Request = %@", connection.urlRequest);
                                           NSLog(@"Connection = %@", connection);
                                           
                                           /*
                                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                            message:[error localizedDescription]
                                            delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
                                            show];
                                            */
                                           
                                           if (block) {
                                               block(nil);
                                           }
                                       }
                                   }];
                                  
                              }
                              // Permission refusée
                              else {
                                  /*
                                   [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                   message:@"Erreur lors de l'obtention des permissions"
                                   delegate:nil
                                   cancelButtonTitle:nil
                                   otherButtonTitles:NSLocalizedString(@"OK", nil), nil]
                                   show];
                                   */
                              }
                              
                          }];
        
        }
}

- (void)getEventsWithEnded:(void (^) (NSArray* events) )block
{
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        [self loginReadPermissionsWithEnded:^(BOOL success) {
            if(success) {
                [self loadEvents:block];
            }
        }];
    }
    else {
        [self loadEvents:block];
    }
    
}

#pragma mark - RSVP

- (void)getRSVP:(MomentClass*)moment withEnded:(void (^) (enum UserState rsvp))block
{
    if(!moment) {
        if(block)
            block(-1);
        return;
    }
        
    enum UserState currentState = moment.state.intValue;
    if(moment.facebookId && !( (currentState == UserStateAdmin) || ([moment.owner.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]) ) )
    {
        // Connection
        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
        FBRequest *request = [FBRequest requestForGraphPath:@"fql"];
        
        // Requete
        NSString *query = [NSString stringWithFormat:@"SELECT rsvp_status FROM event_member WHERE eid=%@ AND uid=me()",  moment.facebookId];
        [request.parameters setObject:query forKey:@"q"];
        
        // Completion
        [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(block) {
                if(error) {
                    NSLog(@"GET RSVP FB ERROR : %@", error.localizedDescription);
                    block(-1);
                }
                else {
                    
                    // Result
                    if(result[@"data"] && ([result[@"data"] count] > 0) && result[@"data"][0][@"rsvp_status"])
                    {
                        NSString *rsvp = result[@"data"][0][@"rsvp_status"];
                        enum UserState state;
                        
                        // Identification
                        if([rsvp isEqualToString:@"attending"]) {
                            state = UserStateValid;
                        }
                        else if([rsvp isEqualToString:@"declined"]) {
                            state = UserStateRefused;
                        }
                        else {
                            state = UserStateWaiting;
                        }
                        
                        block(state);
                    }else {
                        block(-1);
                    }
                    
                }
            }
        }];
        
        [connection start];
    }
    else if(block) {
        block(-1);
    }
}

- (void)updateRSVP:(enum UserState)rsvp
            moment:(MomentClass*)moment
         withEnded:(void (^) (BOOL success))block
{
    if(moment.facebookId)
    {
        NSString *path = nil;
        
        // Identifier RSVP
        switch (rsvp) {
            case UserStateAdmin:
            case UserStateOwner:
            case UserStateValid:
                path = @"attending";
                break;
                
            case UserStateRefused:
                path = @"declined";
                break;
                
            case UserStateUnknown:
            case UserStateWaiting:
                path = @"maybe";
                break;
                
            default:
                break;
        }
        
        if(path)
        {
            // Ask For Permission
            [self askForPermissions:@[kFbPermissionRsvpEvent] type:FacebookPermissionPublishType withEnded:^(BOOL success) {
                
                // Get Permission
                if(success) {
                    
                    // Request Config
                    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", moment.facebookId, path];
                    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                    FBRequest *request = [[FBRequest alloc]
                                          initWithSession:[FBSession activeSession]
                                          graphPath:fullPath
                                          parameters:nil
                                          HTTPMethod:@"POST"];
                    
                    // Comptetion Handler
                    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if(block) {
                            
                            if(error) {
                                NSLog(@"RSVP FB ERROR : %@", error.localizedDescription);
                                [TestFlight passCheckpoint:[NSString stringWithFormat:@"FAIL TO CHANGE FB RSVP : Moment %@ - RSVP : %@", moment.facebookId, path]];
                            }
                            
                            block(error == nil);
                        }
                    }];
                    
                    // Launch Request
                    [connection start];
                }
                // Permission Refused Or Fail
                else if(block) {
                    block(NO);
                }
                
            }];
        }
        
    }
}

#pragma mark - Publish

- (void)getPublishPermissions
{
    [self askForPermissions:@[kFbPermissionPublishAction, kFbPermissionPublishStream, kFbPermissionPhotoUpload, kFbPermissionRsvpEvent]
                       type:FacebookPermissionPublishType
                  withEnded:^(BOOL success) {
        
    }];
}

- (void)postMessageOnEventWall:(MomentClass*)moment
                    parameters:(NSDictionary*)params
                     withEnded:(void (^) (BOOL success))block
{
    if(moment.facebookId && params)
    {
        // Ask For Permissions
        [self askForPermissions:@[kFbPermissionPublishAction, kFbPermissionPublishStream] type:FacebookPermissionPublishType withEnded:^(BOOL success) {
            
            // Success
            if(success) {
                FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                                
                // Post Request
                /*
                FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:@"454455871307842/feed" parameters:params HTTPMethod:@"POST"];
                */
                
                FBRequest *request = [[FBRequest alloc]
                                      initWithSession:[FBSession activeSession]
                                      graphPath:[NSString stringWithFormat:@"%@/feed", moment.facebookId]
                                      parameters:params HTTPMethod:@"POST"];
                
                
                // Completion Handler
                [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if(block) {
                        block(error == nil);
                    }
                }];
                
                // Send Request
                [connection start];
            }
            // Failure
            else if(block) {
                block(NO);
            }
            
        }];
    }
}

- (void)postMessageOnEventWall:(MomentClass*)moment
                       message:(NSString*)message
                     withEnded:(void (^)(BOOL success))block
{
    if(message) {
        
        message = [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self postMessageOnEventWall:moment parameters:@{@"message":message} withEnded:block];
    }
}

- (void)postMessageOnEventWall:(MomentClass *)moment
                         photo:(Photos*)photo
                     withEnded:(void (^)(BOOL success))block
{
    if(photo) {
        
        NSString *message = [[NSString stringWithFormat:@"Je viens d'ajouter une photo à cet évènement sur Moment. %@", photo.uniqueURL] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *picture = [photo.urlOriginal stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *params = @{@"message":message,
                                 @"picture":picture,
                                 @"name":moment.titre,
                                 @"type":@"photo",
                                 @"caption":@"L'application Moment vous permet d'organisez, vivre et revivre tout vos évènements entre proche.",
                                 @"link":photo.uniqueURL};
        
        [self postMessageOnEventWall:moment parameters:params withEnded:block];
    }
}

- (void)postMessageOnEventWall:(MomentClass *)moment
                          chat:(ChatMessage*)chat
                     withEnded:(void (^)(BOOL success))block
{
    if(chat) {
        
        NSString *message = [[NSString stringWithFormat:@"Nouveau Message sur %@ :\n\"%@\"\n-- Moment --", moment.titre, chat.message] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [self postMessageOnEventWall:moment message:message withEnded:block];
    }
}

#pragma mark - Getters

- (AFHTTPClient*)httpClient {
    if(!_httpClient) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[kFbGraphBaseURL copy]]];
    }
    return _httpClient;
}

- (NSArray*)defaultReadPermissions {
    if(!_defaultReadPermissions) {
        _defaultReadPermissions = @[kFbPermissionEmail,
                                kFbPermissionAboutMe,
                                kFbPermissionFriendLists,
                                kFbPermissionFriendLocation,
                                kFbPermissionFriendHomeTown];
    }
    return _defaultReadPermissions;
}

- (NSArray*)defaultPublishPermissions {
    if(!_defaultPublishPermissions) {
        _defaultPublishPermissions = @[kFbPermissionPublishAction];
    }
    return _defaultPublishPermissions;
}

- (NSDateFormatter*)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.calendar = [NSCalendar currentCalendar];
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _dateFormatter.locale = [NSLocale currentLocale];
    }
    return _dateFormatter;
}

#pragma mark - FBSample

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateOpen: {
            // FBSample logic
            // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
            // responsiveness when the user tags their friends.
            
            // Save FB id
            [self updateCurrentUserFacebookIdOnServer:nil];
            
        }
            break;
        case FBSessionStateClosed: {
            // FBSample logic
            // Once the user has logged out, we want them to be looking at the root view.
            
            [FBSession.activeSession closeAndClearTokenInformation];
        }
            break;
        case FBSessionStateClosedLoginFailed: {
            // if the token goes invalid we want to switch right back to
            // the login view, however we do it with a slight delay in order to
            // account for a race between this and the login view dissappearing
            // a moment before
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification.copy
                                                        object:session];
    
    if (error) {
        
        UIAlertView *alertView = nil;
        
        // Gestion des erreurs
        switch (error.code) {
                
            // Login impossible -> Facebook Refusé ?
            case FBErrorLoginFailedOrCancelled: {
                
                // Marche à suivre selon l'OS
                NSString *localizedKey = [[VersionControl sharedInstance] supportIOS6] ?@"FacebookManager_ErrorLoginFailed_Message_iOS6" : @"FacebookManager_ErrorLoginFailed_Message";
                
                alertView = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"FacebookManager_ErrorLoginFailed_Title", nil)
                             message:NSLocalizedString(localizedKey, nil)
                             delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                             otherButtonTitles:nil];
                }   break;
                
            // Autre Erreur
            default:
                
                alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@",
                                                                [FacebookManager FBErrorCodeDescription:error.code]]
                                                       message:error.localizedDescription
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                             otherButtonTitles:nil];
                
                break;
        }
        
        if(alertView)
            [alertView show];
    }
}

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }
        case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        default:
            return @"[Unknown]";
    }
}

@end
