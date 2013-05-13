//
//  UserClass+Server.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UserClass+Server.h"
#import "UserClass+Mapping.h"
#import "MomentCoreData+Model.h"
#import "AFMomentAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "DeviceModel.h"
#import "Photos.h"

#import "PushNotificationManager.h"
#import "LocalNotification.h"
#import "ParametreNotification.h"
#import "Config.h"

@implementation UserClass (Server)

#pragma mark - Register

+ (void)registerUserWithAttributes:(NSDictionary*)attributes withEnded:(void (^)(NSInteger status))block
{
    
    //NSLog(@"ON CREE LE USER !");
    
    NSString *path = @"register";
    
    NSMutableDictionary *params = attributes.mutableCopy;
    
    // Photo
    NSData *file = nil;
    if(attributes[@"photo"]) {
        
        if([attributes[@"photo"] isKindOfClass:[UIImage class]]) {
            file = UIImagePNGRepresentation(attributes[@"photo"]);
        }
        else if([attributes[@"photo"] isKindOfClass:[NSData class]]) {
            file = attributes[@"photo"];
        }
        
        [params removeObjectForKey:@"photo"];
    }
    
    // Push Notification Params
    NSDictionary *deviceData = [DeviceModel data];
    if(deviceData) {
        [params setValuesForKeysWithDictionary:deviceData];
    }
    
    NSMutableURLRequest *request = [[AFMomentAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        if(file)
            [formData appendPartWithFileData:file name:@"photo" fileName:@"photo.png" mimeType:@"image/png"];
    }];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:30.0];
    
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    /*
     [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
     NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
     }];
     */
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        [[AFMomentAPIClient sharedClient] saveHeaderResponse:operation.response];
        
        //NSLog(@"Reçu : %@", JSON);
        
        // Get User Id
        NSDictionary *webAttributes = (NSDictionary*)JSON;
        NSMutableDictionary *dico = [NSMutableDictionary dictionaryWithDictionary:attributes];
        [dico setValue:webAttributes[@"id"] forKey:@"userId"];
        
        // Create user en local
        [UserCoreData updateCurrentUserWithAttributes:dico ];
        if (block) {
            block(200);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if (block) {
            block(operation.response.statusCode);
        }
        
    }];
    
    [operation start];
    
}

#pragma mark - User Informations

+ (void)getUserFromServerWithId:(NSInteger)userId withEnded:(void (^) (UserClass *user))block
{
    NSString *path = [NSString stringWithFormat:@"user/%d", userId];
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        if(block && JSON) {
            //NSLog(@"JSON = %@", JSON);
            block([[UserClass alloc] initWithAttributesFromWeb:JSON]);
            //NSDictionary *mapped = [UserClass mappingToLocalAttributes:JSON];
            //UserClass *requested = [UserCoreData requestUserWithAttributes:mapped];
            //block(requested);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
}

+ (void)updateCurrentUserInformationsOnServerWithAttributes:(NSDictionary *)modifications
                                                  withEnded:(void (^) (BOOL success))block
{
    // Update Informations en local
    [UserCoreData updateCurrentUserWithAttributes:modifications];
    
    // Update information sur le server
    NSString *path = @"user";
    
    NSMutableDictionary *params = [UserClass mappingToWebWithAttributes:modifications].mutableCopy;
    
    // Photo
    NSData *file = nil;
    if(modifications[@"photo"]) {
        
        if([modifications[@"photo"] isKindOfClass:[UIImage class]]) {
            file = UIImagePNGRepresentation(modifications[@"photo"]);
        }
        else if([modifications[@"photo"] isKindOfClass:[NSData class]]) {
            file = modifications[@"photo"];
        }

        [params removeObjectForKey:@"photo"];
    }
        
    NSMutableURLRequest *request = [[AFMomentAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        if(file)
            [formData appendPartWithFileData:file name:@"photo" fileName:@"photo.png" mimeType:@"image/png"];
    }];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:30.0];
    
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    /*
     [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
     NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
     }];
     */
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        [[AFMomentAPIClient sharedClient] saveHeaderResponse:operation.response];
        
        NSLog(@"Response = %@", JSON);
        
        if (block) {
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if (block) {
            block(NO);
        }
        
    }];
    
    [operation start];
}

#pragma mark - Login

+ (void)getLoggedUserFromServerWithEnded:( void (^) (UserClass *user) )block waitUntilFinished:(BOOL)waitUntilFinished
{
    //NSLog(@"GET USER INFO");
    NSString *path = @"user";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *attributes = (NSDictionary*)JSON;
        if(block) {
            
            NSDictionary *localAttr = [UserClass mappingToLocalAttributes:attributes];
            NSLog(@"Local Attributes : %@", localAttr);
            [UserCoreData updateCurrentUserWithAttributes:localAttr];
            
            UserClass *user = [UserCoreData getCurrentUser];
            NSLog(@"user = %@", user);
            
            block(user);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"MIDDLE");
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    } waitUntilFinisehd:waitUntilFinished];
}

+ (void)getLoggedUserFromServerWithEnded:( void (^) (UserClass *user) )block
{
    [self getLoggedUserFromServerWithEnded:block waitUntilFinished:NO];
}

+ (void)loginUserWithUsername:(NSString *)username withPassword:(NSString *)password withEnded:(void (^)(NSInteger status))block {
    
    
    //NSLog(@"ON LOG LE USER !");
    
    NSString *path = @"login";
    
    NSMutableDictionary *params = @{
                                    @"email" : username,
                                    @"password" : password
                                    }.mutableCopy;
    
    // Push Notification Params
    NSDictionary *deviceData = [DeviceModel data];
    if(deviceData) {
        [params setValuesForKeysWithDictionary:deviceData];
    }
    
    //NSLog(@"Envoyé : %@", params);
    
    [[AFMomentAPIClient sharedClient] postPath:path parameters:params encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if( operation.response.statusCode == 200 ){
            
            // User logged
            // -> On ne doit pas se déconnecter
            [DeviceModel setDeviceShouldLogout:NO];
            
            // On récupère l'id du user
            NSDictionary *attributes = (NSDictionary*)JSON;
            int userId = [attributes[@"id"] intValue];
            UserClass* user = [UserCoreData getCurrentUser];
                        
            // Si l'utilisateur n'est pas celui qui est stocké, on charge les informations du nouveau user
            if( !user || user.userId.intValue != userId ) {
                [UserClass getLoggedUserFromServerWithEnded:^(UserClass *userServer) {
                                        
                    if(userServer) {
                        if(block) {
                            block(200);
                        }
                    }
                    else {
                        
                        NSLog(@"Fail to laod user informations");
                        if(block) {
                            block(500);
                        }
                        
                    }
                    
                }];
            }
            else if(block) {
                block(200);
            }
            
            
        }
        else {
            NSLog(@"STATUS AUTRE : %d", operation.response.statusCode);
            if (block) {
                block(operation.response.statusCode);
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.request);
        
        HTTP_ERROR(operation, error);
        if (block) {
            block(operation.response.statusCode);
        }
    }];
    
    
}

#pragma mark - Logout

+ (void)logoutCurrentUserWithEnded:(void (^) (void))block
{
    NSLog(@"LOGOUT");
    
    UserCoreData *user = [UserCoreData getCurrentUserAsCoreData];
    if(user)
    {
        // Delete Current User
        [[Config sharedInstance].managedObjectContext deleteObject:user];
        [[Config sharedInstance] saveContext];
        
        // Clear data
        [MomentCoreData resetMomentsLocal];
        [ChatMessageCoreData resetChatMessagesLocal];
        
        // Suppression cookie de connexion automatique
        [[AFMomentAPIClient sharedClient] clearConnexionCookie];
        
        // Unsubscribe to local notifications
        [[PushNotificationManager sharedInstance] removeNotifications];
        
        // Suppression des préférences des push notifications
        [ParametreNotification clearSettingsLocal];
        
        // Prévenir Server d'arreter Push Notifications
        [DeviceModel logout];
    }
    
    if(block)
        block();
    
}

#pragma mark - Lost Password

+ (void)requestNewPasswordAtEmail:(NSString*)email withEnded:(void (^) (BOOL success))block
{
    NSString *path = [NSString stringWithFormat:@"lostpass/%@", email];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(block)
            block(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
        
    }];
    
}

#pragma mark - Invites

+ (void)inviteNewGuest:(NSArray*)users toMoment:(MomentClass*)moment withEnded:( void (^) (BOOL success) )block
{
    NSString *path = [NSString stringWithFormat:@"newguests/%d", moment.momentId.intValue];
    
    // Mapping
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:[users count]];
    for( UserClass *u in users) {
        [params addObject:[u mappingToWeb]];
    }
    
    [[AFMomentAPIClient sharedClient] postPath:path parameters:@{@"users":params} encoding:AFJSONParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
                
        if(block)
            block(YES);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
    }];
}

// --- Local Conversions ----

// Englobe sous la forme @{@"user":user, @"isAdmin":@(isAdmin)}
+ (NSMutableDictionary*)englobeUserWithAdminAttributeFromWeb:(NSDictionary*)userAttriubtes admin:(BOOL)isAdmin
{
    NSMutableDictionary *dico = [[NSMutableDictionary alloc] initWithCapacity:2];
    dico[@"user"] = [[UserClass alloc] initWithAttributesFromWeb:userAttriubtes];
    dico[@"isAdmin"] = @(isAdmin);
    return dico;
}

// Array avec la forme d'au dessus
+ (NSArray*)englobeUserArrayWithAdminAttributesFromWeb:(NSArray*)users admin:(BOOL)isAdmin
{
    NSMutableArray *final = [[NSMutableArray alloc] initWithCapacity:[users count]];
    for( NSDictionary* user in users ) {
        NSMutableDictionary *newUser = [UserClass englobeUserWithAdminAttributeFromWeb:user admin:isAdmin];
        [final addObject:newUser];
    }
    return final;
}

// -----

+ (void)getInvitedUsersToMoment:(MomentClass*)moment
         withAdminEncapsulation:(BOOL)adminEncapsulation
                      withEnded:( void (^) (NSDictionary* invites) )block
{
    NSString *path = [NSString stringWithFormat:@"guests/%d", moment.momentId.intValue];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding
                                      success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                          
        if(block) {
            NSArray *ownerArray = (NSArray*)JSON[@"owner"];
            id owner = nil;
            if([ownerArray count] > 0) {
                owner = ownerArray[0];
            }
            NSArray *maybe = (NSArray*)JSON[@"maybe"];
            NSArray *coming = (NSArray*)JSON[@"coming"];
            NSArray *not_coming = (NSArray*)JSON[@"not_coming"];
            NSArray *unknown = (NSArray*)JSON[@"unknown"];
            NSArray *admin = (NSArray*)JSON[@"admin"];
            
            if(adminEncapsulation)
            {
                // Update Admins As Admin
                admin = [UserClass englobeUserArrayWithAdminAttributesFromWeb:admin admin:YES];
                if(owner)
                    owner = [UserClass englobeUserWithAdminAttributeFromWeb:owner admin:YES];
                
                // Convert non admins
                maybe = [UserClass englobeUserArrayWithAdminAttributesFromWeb:maybe admin:NO];
                coming = [UserClass englobeUserArrayWithAdminAttributesFromWeb:coming admin:NO];
                not_coming = [UserClass englobeUserArrayWithAdminAttributesFromWeb:not_coming admin:NO];
                unknown = [UserClass englobeUserArrayWithAdminAttributesFromWeb:unknown admin:NO];
            }
            else {
                admin = [UserClass arrayOfUsersWithArrayOfAttributesFromWeb:admin];
                if(owner)
                    owner = [[UserClass alloc] initWithAttributesFromWeb:owner];
                maybe = [UserClass arrayOfUsersWithArrayOfAttributesFromWeb:maybe];
                coming = [UserClass arrayOfUsersWithArrayOfAttributesFromWeb:coming];
                not_coming = [UserClass arrayOfUsersWithArrayOfAttributesFromWeb:not_coming];
                unknown = [UserClass arrayOfUsersWithArrayOfAttributesFromWeb:unknown];
            }
            
            NSMutableDictionary *dico = [[NSMutableDictionary alloc] init];
            if(owner) dico[@"owner"] = owner;
            if(maybe) dico[@"maybe"] = maybe;
            if(coming) dico[@"coming"] = coming;
            if(not_coming) dico[@"not_coming"] = not_coming;
            if(unknown) dico[@"unknown"] = unknown;
            if(admin) dico[@"admin"] = admin;
                        
            block(dico);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
}

+ (void)getInvitedUsersToMoment:(MomentClass*)moment withEnded:( void (^) (NSDictionary* invites) )block {
    [self getInvitedUsersToMoment:moment withAdminEncapsulation:YES withEnded:block];
}

+ (void)getFavorisUsersWithEnded:( void (^) (NSArray* favoris) )block
{
    NSString *path = @"favoris";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *usersAttributes = (NSArray*)([JSON objectForKey:@"favoris"]);
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:[usersAttributes count]];
        
        for( NSDictionary *attributes in usersAttributes ) {
            [users addObject:[UserCoreData requestUserWithAttributes:[UserClass mappingToLocalAttributes:attributes]]];
        }
        
        if(block) {
            block(users);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
    }];
    
}

#pragma mark - Users On Moment

+ (void)getUsersWhoAreOnMoment:(NSArray *)users withEnded:(void (^) (NSArray *usersOnMoment))block
{
    NSString *path = @"usersmoment";
    
    NSDictionary *params = @{@"users":users};
    
    [[AFMomentAPIClient sharedClient] postPath:path parameters:params encoding:AFJSONParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *usersAttributes = (NSArray*)(JSON[@"moment_users"]);
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:[usersAttributes count]];
        
        for( NSDictionary *attributes in usersAttributes ) {
            [users addObject:[UserClass mappingToLocalAttributes:attributes]];
        }
        
        if(block) {
            block(users);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
    }];
}

#pragma mark - Follows / Followers

- (void)getFollowsWithEnded:(void (^) (NSArray *follows))block
{
    NSString *path = [NSString stringWithFormat:@"follows/%@", self.userId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *usersAttributes = (NSArray*)(JSON[@"follows"]);
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:[usersAttributes count]];
        
        for( NSDictionary *attributes in usersAttributes ) {
            [users addObject:[[UserClass alloc] initWithAttributesFromWeb:attributes]];
        }
        
        if(block) {
            block(users);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
    }];
}

- (void)getFollowersWithEnded:(void (^) (NSArray *followers))block
{
    NSString *path = [NSString stringWithFormat:@"followers/%@", self.userId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *usersAttributes = (NSArray*)(JSON[@"followers"]);
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:[usersAttributes count]];
        
        for( NSDictionary *attributes in usersAttributes ) {
            [users addObject:[[UserClass alloc] initWithAttributesFromWeb:attributes]];
        }
        
        if(block) {
            block(users);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
    }];
}

- (void)toggleFollowWithEnded:(void (^) (BOOL success))block
{
    NSString *path = [NSString stringWithFormat:@"addfollow/%@", self.userId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        self.is_followed = @(!self.is_followed.boolValue);
        
        [UserCoreData currentUserNeedsUpdate];
        
        if(block) {
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
    }];
}

#pragma mark - Photos

- (void)getPhotosWithEnded:(void (^) (NSArray *photos))block
{
    NSString *path = [NSString stringWithFormat:@"photosuser/%@", self.userId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *photos = [Photos arrayWithArrayFromWeb:JSON[@"photos"]];
        
        if(block) {
            block(photos);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
    }];
    
}

#pragma mark - Recherche

+ (void)search:(NSString*)query
     withEnded:(void (^) (NSArray *users, NSArray *moments, NSInteger nbPrivateMoments))block
{
    
    if(block)
    {
        NSString *path = [NSString stringWithFormat:@"search/%@", [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"path = %@", path);
        
        [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            NSArray *users = [UserClass arrayOfUsersWithArrayOfAttributesFromWeb:JSON[@"users"]];
            NSArray *publicMoments = [MomentClass arrayOfMomentsWithArrayOfAttributesFromWeb:JSON[@"public_moments"]];
            NSMutableArray *moments = [MomentClass arrayOfMomentsWithArrayOfAttributesFromWeb:JSON[@"user_moments"]].mutableCopy;
            
            // Nombre de moments privés (ils seront au début de tableau)
            NSInteger nbPrivateMoments = [moments count];
            
            // Ajout des moments publics
            [moments addObjectsFromArray:publicMoments];
            
            NSLog(@"users = \n%@\n\nmoments = \n%@\n\nnbPrivate = %d", users, moments, nbPrivateMoments);
            
            block(users, moments, nbPrivateMoments);

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            HTTP_ERROR(operation, error);
            
            block(nil, nil, -1);
        }];
        
    }
    
}

@end
