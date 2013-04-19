//
//  UserCoreData+Model.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 04/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "UserCoreData+Model.h"
#import "UserClass+Mapping.h"
#import "Config.h"
#import "MomentCoreData+Model.h"
#import "AFMomentAPIClient.h"
#import "PushNotificationManager.h"
#import "UserClass+Server.h"
#import "LocalNotificationCoreData+Model.h"
#import "ParametreNotification.h"

#define NB_USERS_STORED 10

#define UPDATE_USER_DIFFERENCE_TIME (5*60) // 5 minutes

@implementation UserCoreData (Model)

static NSTimeInterval lastUpdateTime = 0;

#pragma mark - Init

- (void)setupWithUser:(UserClass*)user {
    
    self.userId = user.userId;
    self.nom = user.nom;
    self.prenom = user.prenom;
    self.imageString = user.imageString;
    self.email = user.email;
    self.secondEmail = user.secondEmail;
    self.numeroMobile = user.numeroMobile;
    self.secondPhone = user.secondPhone;
    self.state = user.state;
    self.facebookId = user.facebookId;
    [self setDataImageWithUIImage:user.uimage];
    self.nb_follows = user.nb_follows;
    self.nb_followers = user.nb_followers;
    self.is_followed = user.is_followed;
    self.descriptionString = user.descriptionString;
}

- (void)setupWithAttributes:(NSDictionary*)attributes
{
    if(attributes[@"userId"])
        self.userId = @([attributes[@"userId"] intValue]);
    if(attributes[@"nom"])
        self.nom = attributes[@"nom"];
    if(attributes[@"prenom"])
        self.prenom = attributes[@"prenom"];
    if(attributes[@"imageString"])
        self.imageString = attributes[@"imageString"];
    
    if(attributes[@"email"])
        self.email = attributes[@"email"];
    if(attributes[@"secondEmail"])
        self.secondEmail = attributes[@"secondEmail"];
    if(attributes[@"numeroMobile"])
        self.numeroMobile = attributes[@"numeroMobile"];
    if(attributes[@"secondPhone"])
        self.secondPhone = attributes[@"secondPhone"];
    if(attributes[@"state"])
        self.state = @([attributes[@"state"] intValue]);
    if(attributes[@"facebookId"])
        self.facebookId = [NSString stringWithFormat:@"%@", attributes[@"facebookId"]];
    if(attributes[@"nb_follows"])
        self.nb_follows =   attributes[@"nb_follows"];
    if(attributes[@"nb_followers"])
        self.nb_followers = attributes[@"nb_followers"];
    if(attributes[@"is_followed"])
        self.is_followed = @([attributes[@"is_followed"] boolValue]);
    if(attributes[@"description"])
        self.descriptionString = attributes[@"description"];
}

#pragma mark - Persist

+ (UserCoreData*)insertUser:(UserClass*)user
{
    UserCoreData* storedUser = [NSEntityDescription insertNewObjectForEntityForName:@"UserCoreData" inManagedObjectContext:[Config sharedInstance].managedObjectContext];
    
    [storedUser setupWithUser:user];
    
    [[Config sharedInstance] saveContext];
    
    return storedUser;
}

+ (UserCoreData*)insertWithMemoryReleaseNewUser:(UserClass*)user
{
    // Release old moment if needed
    [self releaseUsersAfterIndex:NB_USERS_STORED];
    
    // Store new moment
    UserCoreData *storedUser = [self insertUser:user];
    
    return storedUser;
}

+ (UserClass*)newUserWithAttributes:(NSDictionary*)attributes
{
    UserClass *user = [[UserClass alloc] initWithAttributesFromLocal:attributes];
    [self insertWithMemoryReleaseNewUser:user];
    
    return user;
}

+ (void)updateUser:(UserClass*)user
{
    UserCoreData *userCoreData = [UserCoreData requestUserAsCoreDataWithUser:user];
    [userCoreData setupWithUser:user];
    [[Config sharedInstance] saveContext];
    NSLog(@"USERCOREDATA : %@ - %@ - %@ - %@ - %@", userCoreData.userId, userCoreData.prenom, userCoreData.nom, userCoreData.facebookId, userCoreData.nb_follows);
}

#pragma mark - Current User

+ (void)currentUserNeedsUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCurrentUserNeedsUpdate object:nil];
}

+ (UserCoreData*)getCurrentUserAsCoreData
{
    static BOOL isLoading = NO;
    
    //NSLog(@"GET CURRENT USER");
    // Vérifier si l'utilisateur existe déjà
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCoreData"];
    request.returnsObjectsAsFaults = NO;    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"userId" ascending:YES];
    request.sortDescriptors = @[sort];
    request.predicate = [NSPredicate predicateWithFormat:@"state = %@", @(UserStateCurrent)];
    
    
    NSError *error = nil;
    NSArray *match = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    __block UserCoreData *user = nil;
    
    if(!match) {
        NSLog(@"Error Fetch Request getCurrentUser : %@", error.localizedDescription);
        abort();
    }
    else if( [match count] > 0 ) {
        //NSLog(@"User founded");
        
        user = match[0];
    }
    
    
    // Si ca fait un moment qu'on a pas rechargé les infos, on recharge depuis le server
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if( !isLoading && ( (now - lastUpdateTime > UPDATE_USER_DIFFERENCE_TIME) ||
       // Ou si les données du user sont incomplète
       !(user && user.userId && user.email && user.nom && user.prenom && user.nb_follows && user.nb_followers) ) )
    {
        //NSLog(@"----- UPDATE CURRENT USER BECAUSE OF %f DIFFERENCE TIME (force = %d) -----", now - lastUpdateTime, currentUserNeedsUpdateCoreData);
        lastUpdateTime = now;
        // Ask Server
        isLoading = YES;
        [UserClass getLoggedUserFromServerWithEnded:^(UserClass *userServer) {
            if(userServer)
            {
                if(!user)
                    user = [UserCoreData insertUser:userServer];
                else
                    [user setupWithUser:userServer];
                [[Config sharedInstance] saveContext];
                
                // Update did happen, udpate view
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCurrentUserDidUpdate object:nil];
                isLoading = NO;
            }
        } waitUntilFinished:YES];
        
    }
    
    return user;
}

+ (UserClass*)getCurrentUser {
    
    // Update si ca fait longtemps
    UserCoreData *user = [self getCurrentUserAsCoreData];
        
    return [user localCopy];
}


+ (void)updateCurrentUserWithAttributes:(NSDictionary*)attributes
{    
    // Get Current
    UserClass *current = [UserCoreData getCurrentUser];
        
    // Update attributes
    NSMutableDictionary *dico = attributes.mutableCopy;
    dico[@"state"] = @(UserStateCurrent);
    if(attributes[@"userId"])
        dico[@"userId"] = attributes[@"userId"];
        
    if(!current) {
        current = [UserCoreData newUserWithAttributes:dico];
    }
    else {
        [current setupWithAttributesFromLocal:dico];
    }
    
    // Update user
    [self updateUser:current];
    
}

#pragma mark - Count

+ (NSInteger)count {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCoreData"];
    [request setIncludesSubentities:NO];
    
    NSError *error = NULL;
    NSInteger count = [[Config sharedInstance].managedObjectContext countForFetchRequest:request error:&error];
    
    if(error || (count == NSNotFound) ) {
        NSLog(@"Error Count Users : %@", error.localizedDescription);
        abort();
    }
    
    return count;
}

+ (NSArray*)getUsersAsCoreDataWithLimit:(NSInteger)limit {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCoreData"];
    if(limit > 0)
        request.fetchLimit = limit;
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    //NSLog(@"Local moments = %@", matches);
    
    if( !matches )
    {
        NSLog(@"Error GetUsers : %@", error.localizedDescription);
        abort();
    }
    else {
        //NSLog(@"matches = %@", matches);
        return matches;
    }
    
    
    return nil;
}

#pragma mark - Request

+ (UserCoreData*)requestUserAsCoreDataWithAttributes:(NSDictionary*)attributes {
        
    // Vérifier si l'utilisateur existe déjà
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCoreData"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"userId" ascending:YES];
    request.sortDescriptors = @[sort];
    
    if(attributes[@"userId"])
        request.predicate = [NSPredicate predicateWithFormat:@"userId = %@", attributes[@"userId"] ];
    else if(attributes[@"facebookId"])
        request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", attributes[@"facebookId"] ];
    else if(attributes[@"nom"] && attributes[@"prenom"])
        request.predicate = [NSPredicate predicateWithFormat:@"(nom = %@) AND (prenom = %@)",
                               attributes[@"nom"], attributes[@"prenom"]];
    else if(attributes[@"fullname"])
        request.predicate = [[NSPredicate predicateWithFormat:@"(nom IN $FULLNAME) AND (prenom IN $FULLNAME)"]
                             predicateWithSubstitutionVariables:@{@"FULLNAME":attributes[@"fullname"]}];
    else
        return nil;
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    //NSLog(@"Matches owner = %@", matches);
    
    if(!matches) {
        NSLog(@"Error RequestUserWithAttributes : %@", error.localizedDescription);
        abort();
    }
    else if( [matches count] == 0 ){
        UserClass *user = [[UserClass alloc] initWithAttributesFromLocal:attributes];
        return [self insertWithMemoryReleaseNewUser:user];
    }
    
    // Mise à jour
    UserCoreData *user = matches[0];
    [user setupWithAttributes:attributes];
    [[Config sharedInstance] saveContext];
    
    return user;
}

+ (UserClass*)requestUserWithAttributes:(NSDictionary*)attributes {
    return [[self requestUserAsCoreDataWithAttributes:attributes] localCopy];
}

+ (UserCoreData*)requestUserAsCoreDataWithUser:(UserClass *)user
{
    // Vérifier si le user existe déjà
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCoreData"];
    
    if(user.userId)
        request.predicate = [NSPredicate predicateWithFormat:@"userId = %@", user.userId ];
    else if(user.facebookId)
        request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", user.facebookId ];
    else if(user.nom && user.prenom)
        request.predicate = [NSPredicate predicateWithFormat:@"(nom = %@) AND (prenom = %@)",
                             user.nom, user.prenom];
    else
        return nil;
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestMomentWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    else if ([matches count] == 0) {
        return [self insertWithMemoryReleaseNewUser:user];
    }
    
    // Mise à jour
    UserCoreData *userCoreData = matches[0];
    [userCoreData setupWithUser:user];
    [[Config sharedInstance] saveContext];
    
    return userCoreData;
}

+ (NSArray*)getUsersAsCoreData
{
    return [self getUsersAsCoreDataWithLimit:USERS_NO_LIMIT];
}

+ (NSArray*)getUsers
{
    return [self localCopyOfArray:[self getUsersAsCoreData]];
}

#pragma mark - Local Gestion

- (UserClass*)localCopy
{
    UserClass *user = [[UserClass alloc] init];

    user.userId = self.userId;
    user.nom = self.nom;
    user.prenom = self.prenom;
    user.imageString = self.imageString;
    user.email = self.email;
    user.secondEmail = self.secondEmail;
    user.numeroMobile = self.numeroMobile;
    user.secondPhone = self.secondPhone;
    user.state = self.state;
    user.facebookId = self.facebookId;
    user.uimage = [self uimage];
    user.nb_follows = self.nb_follows;
    user.nb_followers = self.nb_followers;
    user.is_followed = self.is_followed;
    user.descriptionString = self.descriptionString;
    
    return user;
}

+ (NSArray*)localCopyOfArray:(NSArray*)stored {
    if(stored) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[stored count]];
        for( UserCoreData* data in stored ) {
            [array addObject:[data localCopy]];
        }
        return array;
    }
    return nil;
}

#pragma mark - Getters & Setters

- (UIImage*)uimage {
    return [UIImage imageWithData:self.dataImage];
}

- (void)setDataImageWithUIImage:(UIImage *)image {
    self.dataImage = UIImagePNGRepresentation(image);
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
        [LocalNotificationCoreData resetNotifcationsLocal];
        
        // Suppression cookie de connexion automatique
        [[AFMomentAPIClient sharedClient] clearConnexionCookie];
        
        // Unsubscribe to local notifications
        [[PushNotificationManager sharedInstance] removeNotifications];
        
        // Suppression des préférences des push notifications
        [ParametreNotification clearSettingsLocal];
        
#warning Prévenir le server -> arreter push notifications
    }
    
    if(block)
        block();

}

#pragma mark - Release

+ (void)releaseUsersAfterIndex:(NSInteger)max
{
    NSArray *users = [self getUsersAsCoreData];
    
    int taille = [users count];
    for(int i=0; i<taille ; i++) {
        if(i >= max) {
            [[Config sharedInstance].managedObjectContext deleteObject:users[i]];
        }
        i++;
    }
    
    [[Config sharedInstance] saveContext];
}

+ (void)resetUsersLocal
{
    NSArray *users = [UserCoreData getUsersAsCoreData];
    
    for( UserCoreData *u in users ) {
        //NSLog(@"Delete Moment : %@", m);
        [[Config sharedInstance].managedObjectContext deleteObject:u];
    }
    
    [[Config sharedInstance] saveContext];
}

@end
