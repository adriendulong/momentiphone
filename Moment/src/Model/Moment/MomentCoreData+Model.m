//
//  MomentCoreData+Model.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 04/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "MomentCoreData+Model.h"
#import "Config.h"
#import "NSDate+NSDateAdditions.h"
#import "UserCoreData+Model.h"
#import "MomentClass+Mapping.h"
#import "MomentClass+Server.h"
#import "UserClass+Mapping.h"

#define NB_MOMENTS_STORED 20

@implementation MomentCoreData (Model)

#pragma mark - Setup

- (void)setupWithMoment:(MomentClass*)moment
{
    self.titre = moment.titre;
    self.state = moment.state;
    self.imageString = moment.imageString;
    self.dataImage = moment.dataImage;
    self.adresse = moment.adresse;
    self.dateDebut = moment.dateDebut;
    self.dateFin = moment.dateFin;
    self.descriptionString = moment.descriptionString;
    self.facebookId = moment.facebookId;
    self.hashtag = moment.hashtag;
    self.infoLieu = moment.infoLieu;
    self.infoMetro = moment.infoMetro;
    self.momentId = moment.momentId;
    self.nomLieu = moment.nomLieu;
    [self setDataImageWithUIImage:moment.uimage];
    self.guests_coming = moment.guests_coming;
    self.guests_not_coming = moment.guests_not_coming;
    self.guests_number = moment.guests_number;
    self.isOpen = moment.isOpen;
    self.isSponso = moment.isSponso;
    self.owner = [UserCoreData requestUserAsCoreDataWithUser:moment.owner];
    self.uniqueURL = moment.uniqueURL;
    self.nb_photos = moment.nb_photos;
}

- (void)setupWithAttributes:(NSDictionary*)attributes
{
    self.momentId = attributes[@"momentId"];
    self.titre = attributes[@"titre"];
    self.dateDebut = attributes[@"dateDebut"];
    self.dateFin = attributes[@"dateFin"];
    
    /*
     if(attributes[@"facebookId"])
     moment.facebookId = attributes[@"facebookId"];
     */
    
    if(attributes[@"guests_number"]) {
        self.guests_number = attributes[@"guests_number"];
        self.guests_coming = attributes[@"guests_coming"];
        self.guests_not_coming = attributes[@"guests_not_coming"];
    }
    
    if(attributes[@"hashtag"])
        self.hashtag = attributes[@"hashtag"];
    
    if(attributes[@"adresse"])
        self.adresse = attributes[@"adresse"];
    
    if(attributes[@"descriptionString"])
        self.descriptionString = attributes[@"descriptionString"];
    
    if(attributes[@"infoLieu"])
        self.infoLieu = attributes[@"infoLieu"];
    
    if(attributes[@"nomLieu"])
        self.nomLieu = attributes[@"nomLieu"];
    
    if(attributes[@"dataImage"])
        self.dataImage = attributes[@"dataImage"];
    
    if(attributes[@"imageString"])
        self.imageString = attributes[@"imageString"];
    
    if(attributes[@"state"])
        self.state = attributes[@"state"];
    
    if(attributes[@"isOpen"])
        self.isOpen = attributes[@"isOpen"];
    
    if(attributes[@"isSponso"])
        self.isSponso = attributes[@"isSponso"];
    
    if(attributes[@"isOpenInvit"])
        self.isOpen = @([attributes[@"isOpenInvit"] boolValue]);
    
    if(attributes[@"privacy"])
        self.privacy = attributes[@"privacy"];
    
    if(attributes[@"owner"]) {
        UserCoreData *owner = nil;
        NSDictionary *dico = [UserClass mappingToLocalAttributes:attributes[@"owner"]];
        owner = [UserCoreData requestUserAsCoreDataWithAttributes:dico];
        
        self.owner = owner;
    }
    
    if(attributes[@"unique_url"])
        self.uniqueURL = attributes[@"unique_url"];
    
    if(attributes[@"nb_photos"])
        self.nb_photos = attributes[@"nb_photos"];
}

#pragma mark - Persist

+ (MomentCoreData*)insertMoment:(MomentClass*)moment
{
    MomentCoreData* storedMoment = [NSEntityDescription insertNewObjectForEntityForName:@"MomentCoreData" inManagedObjectContext:[Config sharedInstance].managedObjectContext];
    
    [storedMoment setupWithMoment:moment];
    
    [[Config sharedInstance] saveContext];
    
    return storedMoment;
}
/*
+ (MomentCoreData*)insertWithMemoryReleaseNewMoment:(MomentClass*)moment
{
    // Store new moment
    MomentCoreData *storedMoment = [self insertMoment:moment];
    
    // Release old moment if needed
    [self releaseMomentsAfterIndex:NB_MOMENTS_STORED];
    
    return storedMoment;
}
*/
+ (MomentClass*)newMomentWithAttributesFromLocal:(NSDictionary*)attributes
{    
    MomentClass *moment = [[MomentClass alloc] initWithAttributesFromLocal:attributes];
    [self insertMoment:moment];
    
    return moment;
}

+ (MomentClass*)newMomentWithAttributesFromWeb:(NSDictionary*)attributes
{
    MomentClass *moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes];
    [self insertMoment:moment];
    
    return moment;
}

+ (MomentClass*)newMomentWithFacebookEvent:(FacebookEvent*)event
{
    if(!event)
        return nil;
    
    MomentClass *moment = [[MomentClass alloc] initWithFacebookEvent:event];
    [self insertMoment:moment];
    
    return moment;
}


#pragma mark - Local Gestion

- (MomentClass*)localCopy
{
    MomentClass *moment = [[MomentClass alloc] init];
    moment.titre = self.titre;
    moment.state = self.state;
    moment.imageString = self.imageString;
    moment.adresse = self.adresse;
    moment.dateDebut = self.dateDebut;
    moment.dateFin = self.dateFin;
    moment.descriptionString = self.descriptionString;
    moment.facebookId = self.facebookId;
    moment.hashtag = self.hashtag;
    moment.infoLieu = self.infoLieu;
    moment.infoMetro = self.infoMetro;
    moment.momentId = self.momentId;
    moment.nomLieu = self.nomLieu;
    moment.uimage = self.uimage;
    moment.guests_number = self.guests_number;
    moment.guests_not_coming = self.guests_not_coming;
    moment.guests_coming = self.guests_coming;
    moment.isOpen = self.isOpen;
    moment.isSponso = self.isSponso;
    moment.owner = [self.owner localCopy];
    moment.privacy = self.privacy;
    moment.uniqueURL = self.uniqueURL;
    moment.nb_photos = self.nb_photos;
    //moment.notifications = self.notifications;
    
    return moment;
}

+ (NSArray*)localCopyOfArray:(NSArray*)stored {
    if(stored) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[stored count]];
        for( MomentCoreData* data in stored ) {
            [array addObject:[data localCopy]];
        }
        return array;
    }
    return nil;
}

#pragma mark - Count

+ (NSInteger)count {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MomentCoreData"];
    [request setIncludesSubentities:NO];
    
    NSError *error = NULL;
    NSInteger count = [[Config sharedInstance].managedObjectContext countForFetchRequest:request error:&error];
    
    if(error || (count == NSNotFound) ) {
        NSLog(@"Error Count Moments : %@", error.localizedDescription);
        abort();
    }
    
    return count;
}

+ (NSArray*)getMomentsAsCoreDataWithLimit:(NSInteger)limit {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MomentCoreData"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"dateDebut" ascending:YES];
    request.sortDescriptors = @[sort];
    if(limit > 0)
        request.fetchLimit = limit;
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    //NSLog(@"Local moments = %@", matches);
    
    if( !matches )
    {
        NSLog(@"Error GetMoments : %@", error.localizedDescription);
        abort();
    }
    else {
        //NSLog(@"matches = %@", matches);
        return matches;
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

#pragma mark - Get moment

+ (MomentCoreData*)requestMomentAsCoreDataWithAttributes:(NSDictionary*)attributes
{
    // Vérifier si le moment existe déjà
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MomentCoreData"];
    //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"momentId" ascending:YES];
    //request.sortDescriptors = @[sort];
    request.predicate = [NSPredicate predicateWithFormat:@"momentId = %@", attributes[@"momentId"] ];
    
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestMomentWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    // --- Aucun résultat -> Création du moment ---
    else if ([matches count] == 0) {
        
        if(attributes[@"momentId"])
        {
            MomentClass *moment = [[MomentClass alloc] initWithAttributesFromLocal:attributes];
            
            // Si les informations passées en paramètres sont complètes -> Retourne Nouveau Moment initialisé
            if(attributes[@"dateDebut"] && attributes[@"dateFin"] && attributes[@"adresse"]) {
                return [self insertMoment:moment];
            }
                        
            // Sinon récupère informations depuis le server
            [moment updateMomentFromServerWithEnded:^(BOOL success) {

            } waitUntilFinished:YES];
            
            return [self insertMoment:moment];
        }

    }
    
    // --- Moment trouvé ---
    
    // Si les informations du moment sont complètes -> Retourne moment
    MomentCoreData *moment = matches[0];
    if(moment.momentId && moment.dateDebut && moment.dateFin && moment.adresse) {
        return moment;
    }
    
    // Sinon récupère informations depuis le server
    [MomentClass getInfosMomentWithId:moment.momentId.intValue withEnded:^(NSDictionary *attributes) {
        if (attributes) {
            [moment setupWithAttributes:attributes];
            [[Config sharedInstance] saveContext];
        }
    } waitUntilFinished:YES];
    
    return moment;
}

+ (MomentClass*)requestMomentWithAttributes:(NSDictionary *)attributes {
    return [[self requestMomentAsCoreDataWithAttributes:attributes] localCopy];
}

+ (MomentCoreData*)requestMomentAsCoreDataWithFacebookEvent:(FacebookEvent*)event
{
    // Vérifier si le moment existe déjà
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MomentCoreData"];
    //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"momentId" ascending:YES];
    //request.sortDescriptors = @[sort];
    request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", event.eventId ];
    
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestMomentWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    else if ([matches count] == 0) {
        MomentClass *moment = [[MomentClass alloc] initWithFacebookEvent:event];
        return [self insertMoment:moment];
    }
    
    return matches[0];
}

+ (MomentClass*)requestMomentWithFacebookEvent:(FacebookEvent *)event {
    return [[self requestMomentAsCoreDataWithFacebookEvent:event] localCopy];
}

+ (MomentCoreData*)requestMomentAsCoreDataWithMoment:(MomentClass *)moment
{
    // Vérifier si le moment existe déjà
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MomentCoreData"];
    //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"momentId" ascending:YES];
    //request.sortDescriptors = @[sort];
    request.predicate = [NSPredicate predicateWithFormat:@"momentId = %@", moment.momentId ];
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    if( !matches ) {
        NSLog(@"Error RequestMomentWithAttriubtes : %@", error.localizedDescription);
        abort();
    }
    else if ([matches count] == 0) {
        return [self insertMoment:moment];
    }
    
    return matches[0];
}

+ (NSArray*)getMomentsAsCoreData
{
    return [self getMomentsAsCoreDataWithLimit:MOMENTS_NO_LIMIT];
}

+ (NSArray*)getMoments
{
    NSArray *moments = [self getMomentsAsCoreData];
    return [self localCopyOfArray:moments];
}

#pragma mark - Update

+ (void)updateMoment:(MomentClass*)moment
{
    MomentCoreData *momentCoreData = [MomentCoreData requestMomentAsCoreDataWithMoment:moment];
    [momentCoreData setupWithMoment:moment];
    [[Config sharedInstance] saveContext];
    
    //NSLog(@"####### CoreData #######\n%@\n#####################", momentCoreData);
}

+ (void)updateMomentsWithArray:(NSArray*)array 
{
    
    NSMutableArray *momentIdCoreData = [NSMutableArray array];
    
    for (MomentClass *momentCD in [MomentCoreData getMoments]) {
        [momentIdCoreData addObject:momentCD.momentId];
    }    
    
    // Construction de la requete
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MomentCoreData"];
    NSError *error = nil;
    NSArray *match = nil;
    
    //NSLog(@"Array = %@", array);
    
    // On traite tous les moments passés en paramètres
    for(NSDictionary *attributes in array)
    {        
        request.predicate = [NSPredicate predicateWithFormat:@"momentId = %@", attributes[@"id"] ];
        match = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
        
        if( !match ){
            NSLog(@"Error updateMomentsWithArray : %@", error.localizedDescription);
            abort();
        }
        else {
            
            // Update les données CoreData d'après les données reçus
            MomentClass *moment = [[MomentClass alloc] initWithAttributesFromWeb:attributes];
            [self updateMoment:moment];
            
            if ([momentIdCoreData containsObject:moment.momentId]) {
                [momentIdCoreData removeObject:moment.momentId];
            }
            
        }
        
    }
    
    for (NSNumber *momentId in momentIdCoreData) {
        for (MomentClass *moment in [MomentCoreData getMoments]) {
            if ([moment.momentId isEqualToNumber:momentId]) {
                //NSLog(@"Suppression du moment (%@) : %@",moment.momentId, moment.titre);
                [self deleteMoment:moment];
            }
        }
    }
    
}

#pragma mark - Release

+ (void)releaseMomentsAfterIndex:(NSInteger)max
{
    NSArray *moments = [self getMomentsAsCoreData];
    
    int taille = [moments count];
    for(int i=0; i<taille ; i++) {
        if(i >= max) {
            //NSLog(@"delete moment = %@", [moments[i] titre]);
            [[Config sharedInstance].managedObjectContext deleteObject:moments[i]];
        }
        i++;
    }
    
    [[Config sharedInstance] saveContext];
}

+ (void)resetMomentsLocal
{
    NSArray *moments = [MomentCoreData getMomentsAsCoreData];
    
    for( MomentCoreData *m in moments ) {
        //NSLog(@"Delete Moment : %@", m);
        [[Config sharedInstance].managedObjectContext deleteObject:m];
    }
    
    [[Config sharedInstance] saveContext];
}

+ (void)deleteMomentsWhileEnteringBackground
{
    // On récupère tous les moments
    // -> Ils sont triés par date de début ascendant
    NSMutableArray *moments = [[MomentCoreData getMomentsAsCoreData] mutableCopy];
    
    // Si il y a moins de 20 moments, on ne supprime pas
    if([moments count] <= 20)
        return;
    
    // Identifier le moment le plus proche d'aujourd'hui    
    NSInteger row = 0, tempRow = -1;
    NSDate *today = [NSDate date];
    NSTimeInterval timeInterval = [((MomentCoreData*)moments[0]).dateDebut timeIntervalSinceDate:today], temp = 0;
    for(MomentCoreData *m in moments)
    {
        tempRow++;
        temp = [m.dateDebut timeIntervalSinceDate:today];
        if ( abs(temp) < abs(timeInterval) ) {
            row = tempRow;
            timeInterval = temp;
        }
    }
    // Le moment le plus proche d'aujourd'hui est à l'index "row"
    
    // On enlève les 20 moments les plus proche d'aujourd'hui du tableau
    NSInteger nb = 0;
    NSInteger length;
    while( (nb <= 20) && ((length = [moments count]) > 0) )
    {
        if((row < length) && (row >= 0) ) {
            [moments removeObjectAtIndex:row];
            nb++;
        }
        else if(row == 0) {
            row++;
        }
        else if(row == length) {
            row--;
        }
    }
    
    // Enregistrer la tentative de suppression
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMomentsDeleteTry];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Supprimer tous les autres moments
    @try {
        for(MomentCoreData* m in moments) {
            [[Config sharedInstance].managedObjectContext deleteObject:m];
        }
        [[Config sharedInstance] saveContext];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMomentsDeleteTry];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    @catch (NSException *exception) {
        // Enregistrer l'erreur
        [[NSUserDefaults standardUserDefaults] setValue:exception.description forKey:kMomentsDeleteFail];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // TestFlight
        //[TestFlight passCheckpoint:kMomentsDeleteFail];
        
        // Google Analytics
        //[[[GAI sharedInstance] defaultTracker] sendException:NO withNSException:exception];
        
        [[[UIAlertView alloc]
          initWithTitle:@"CoreData Error"
          message:exception.description
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
        NSLog(@"Core Data Moment Fail : %@", exception.description);
    }
    @finally {
        
    }
    
}

+ (void)deleteMoment:(MomentClass*)moment
{
    MomentCoreData *m = [MomentCoreData requestMomentAsCoreDataWithMoment:moment];
    [[Config sharedInstance].managedObjectContext deleteObject:m];
    [[Config sharedInstance] saveContext];
}

#pragma mark - Debug

-(NSString*)description
{
    return [NSString stringWithFormat:@"{ moment id = %@ - titre = %@ - description = %@ - infoLieu = %@ - hastag = %@ - image = %@ - imageString = %@ - facebookId = %@ - nb_photos = %@\n}", self.momentId, self.titre, self.descriptionString, self.infoLieu, self.hashtag, self.uimage, self.imageString, self.facebookId, self.nb_photos];
}

@end
