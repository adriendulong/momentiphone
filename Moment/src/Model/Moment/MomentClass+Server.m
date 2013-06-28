//
//  MomentClass+Server.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "MomentClass+Server.h"
#import "MomentClass+Mapping.h"
#import "AFMomentAPIClient.h"
#import "FacebookManager.h"
#import "UserClass+Mapping.h"

@implementation MomentClass (Server)

#pragma mark - Create

+ (AFJSONRequestOperation*)operationCreateMomentWithAttributes:(NSDictionary*)attributes
                                                     withEnded:( void (^) (MomentClass *moment) )block
{
    NSString *path = @"newmoment";
    
    NSMutableDictionary *params = attributes.mutableCopy;
    
    
    NSData *file = nil;
    // Si il y a une image
    if(attributes[@"dataImage"]) {
        
        // Si il n'y a pas d'url pour l'image
        if(!attributes[@"cover_photo_url"])
        {
            // Conversion si nécessaire
            if([attributes[@"dataImage"] isKindOfClass:[UIImage class]]) {
                file = UIImagePNGRepresentation(attributes[@"dataImage"]);
            }
            else if([attributes[@"dataImage"] isKindOfClass:[NSData class]]) {
                file = attributes[@"dataImage"];
            }
            
            [params removeObjectForKey:@"photo"];
        }
        
        
    }
    
    NSDictionary *mapped = [MomentClass mappingToWebWithAttributes:params];
        
    NSMutableURLRequest *request = [[AFMomentAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:mapped constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
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
        
        if(JSON)
        {
            [[AFMomentAPIClient sharedClient] saveHeaderResponse:operation.response];
            
            NSDictionary *attr = (NSDictionary*)JSON;
            MomentClass *moment = [MomentCoreData requestMomentWithAttributes:[MomentClass mappingToLocalWithAttributes:attr]];
            
            //NSLog(@"Reponse = %@", attr);
            //NSLog(@"Moment = %@", moment);
            
            if(block)
                block(moment);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error : %@", error.localizedDescription);
        //NSLog(@"Message : %@", operation.responseString);
        
        if(block)
            block(nil);
        
    }];
    
    //NSLog(@"Body = %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSStringEncodingConversionAllowLossy]);
    
    return operation;
}

+ (void)createMomentWithAttributes:(NSDictionary*)attributes withEnded:( void (^) (MomentClass *moment) )block
{
    AFJSONRequestOperation *operation = [self operationCreateMomentWithAttributes:attributes withEnded:block];
    [operation start];
}

- (AFJSONRequestOperation*)operationCreateMomentFromLocalToServerWithEnded:( void (^) (MomentClass *moment) )block {
    return [MomentClass operationCreateMomentWithAttributes:[self mappingToWeb] withEnded:block];
}

- (void)createMomentFromLocalToServerWithEnded:( void (^) (MomentClass *moment) )block {
    AFJSONRequestOperation *operation = [self operationCreateMomentFromLocalToServerWithEnded:block];
    [operation start];
}

+ (void)createMultipleMomentsWithAttributes:(NSArray*)array
                             withTransition:( void (^) (MomentClass *moment) )transitionBlock
                                  withEnded:(void (^) (void))endBlock
{
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for(NSDictionary *attributes in array) {
        [operations addObject:[self operationCreateMomentWithAttributes:attributes withEnded:transitionBlock]];
    }
    
    [[AFMomentAPIClient sharedClient] enqueueBatchOfHTTPRequestOperations:operations progressBlock:nil
                                                          completionBlock:^(NSArray *operations) {
                                                              if(endBlock)
                                                                  endBlock();
                                                          }];
}

+ (void)createMultipleMomentsFromLocalToServerWithMoments:(NSArray*)array
                             withTransition:( void (^) (MomentClass *moment) )transitionBlock
                                  withEnded:(void (^) (void))endBlock
{
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for(MomentClass *moment in array) {
        [operations addObject:[moment operationCreateMomentFromLocalToServerWithEnded:transitionBlock]];
    }
    
    [[AFMomentAPIClient sharedClient] enqueueBatchOfHTTPRequestOperations:operations progressBlock:nil
                                                          completionBlock:^(NSArray *operations) {
                                                              if(endBlock)
                                                                  endBlock();
                                                          }];
}

#pragma mark - Facebook Events

+ (FacebookEvent*)eventInArray:(NSArray*)events withFbId:(NSString*)fbId
{
    // Find object
    NSIndexSet * set = [events indexesOfObjectsPassingTest:^BOOL(FacebookEvent *e, NSUInteger idx, BOOL *stop) {
        if([e.eventId isEqualToString:fbId]) {
            return YES;
        }
        return NO;
    }];
    
    NSUInteger index = set.lastIndex;
    
    if(index == NSNotFound)
        return nil;
    
    return events[index];
}

+ (void)identifyFacebookEventsOnMoment:(NSArray*)events withEnded:(void (^) (NSDictionary* results))block
{
    if(block)
    {
        NSString *path = @"facebookevents";
        
        NSMutableArray *eventsId = [[NSMutableArray alloc] initWithCapacity:[events count]];
        for(FacebookEvent *e in events) {
            [eventsId addObject:e.eventId];
        }
        
        [[AFMomentAPIClient sharedClient] postPath:path parameters:@{@"events":eventsId} encoding:AFJSONParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            // Réponse
            //NSArray *existAndInvited_id = JSON[@"exist_and_invited"];
            NSArray *exist_id = JSON[@"exist"];
            NSArray *notExist_id = JSON[@"not_exist"];
                        
            // Identification des Facebook Moments
            //NSMutableArray *existAndInvited = [[NSMutableArray alloc] initWithCapacity:[existAndInvited_id count]];
            NSMutableArray *exist = [[NSMutableArray alloc] initWithCapacity:[exist_id count]];
            NSMutableArray *notExist = [[NSMutableArray alloc] initWithCapacity:[notExist_id count]];
            
            // Identification des "Exist And Invited"
            /*
            for( NSNumber *fbId in existAndInvited_id ) {
                FacebookEvent *e = [self eventInArray:events withFbId:fbId];
                e.isAlreadyOnMoment = YES;
                [existAndInvited addObject:e];
            }
             */
            
            // Identification des "Exist"            
            for( NSNumber *fbId in exist_id ) {
                FacebookEvent *e = [self eventInArray:events withFbId:[NSString stringWithFormat:@"%@",fbId]];
                if(e) {
                    e.isAlreadyOnMoment = YES;
                    [exist addObject:e];
                }
            }
            // Identification des "Not Exist"
            for( NSNumber *fbId in notExist_id ) {
                FacebookEvent *e = [self eventInArray:events withFbId:[NSString stringWithFormat:@"%@",fbId]];
                if(e)
                    [notExist addObject:e];
            }
            
            block(@{//@"exist_and_invited":existAndInvited,
                  @"exist":exist,
                  @"not_exist":notExist
                  });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            //NSLog(@"Error = %@", error.localizedDescription);
            //NSLog(@"Message = %@", operation.responseString);
            
            block(nil);
        }];
    }
}

//#define DEBUG_IMPORT_FACEBOOK_EVENT
+ (void)importFacebookEventsWithEnded:(void (^) (NSArray *events, NSArray* moments))block
{
        
    // Update Facebook Id
    [[FacebookManager sharedInstance] updateCurrentUserFacebookIdOnServer:^(BOOL success) {
        
        if(success)
        {
            // Get Facebook Events
            [[FacebookManager sharedInstance] getEventsWithEnded:^(NSArray *events) {
                
                if (!events || [events count] == 0) {
                    if(block)
                        block(nil, nil);
                } else {
                    // Identifier quels évenements sont déjà sur Moment
                    [self identifyFacebookEventsOnMoment:events withEnded:^(NSDictionary *results) {
                        
                        // Facebook Events à afficher
                        NSArray *fb_exist = results[@"exist"];
                        NSArray *fb_notExist = results[@"not_exist"];
                        
                        // --------- Créer Moments qui ne sont pas sur le server ---
                        NSMutableArray *moments_notExist = [MomentClass arrayOfMomentsWithFacebookEvents:fb_notExist].mutableCopy;
                        
#ifdef DEBUG_IMPORT_FACEBOOK_EVENT
                        NSLog(@"\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ NOT EXISTED $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n");
#endif
                        
                        __block int i = 0;
                        // Création sur le server
                        [MomentClass createMultipleMomentsFromLocalToServerWithMoments:moments_notExist
                                                                        withTransition:
                         ^(MomentClass *moment) {
                             
                             if(block) {
                                 
#ifdef DEBUG_IMPORT_FACEBOOK_EVENT
                                 NSLog(@"\n-------------------------------------------------------------------\n");
                                 NSLog(@"MOMENT\n : {\n %@ \n}", moment);
                                 NSLog(@"OWNER : {\n %@ \n}", moment.owner);
                                 NSLog(@"\n-------------------------------------------------------------------\n");
#endif
                                 
                                 
                                 if(moment)
                                 {
                                     // Update moments with server attributes
                                     [moments_notExist replaceObjectAtIndex:i withObject:moment];
                                 }
                             }
                             i++;
                             
                         } withEnded:
                         ^{
                             
#ifdef DEBUG_IMPORT_FACEBOOK_EVENT
                             NSLog(@"\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ EXISTED $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n");
#endif
                             
                             // Création NotExist terminée -> Création locale des fb_exist
                             NSMutableArray *moments_exist = [MomentClass arrayOfMomentsWithFacebookEvents:fb_exist].mutableCopy;
                             
                             
                             // ----- Ajouter en tant qu'invité aux moments déjà existant -> Requete de création ----
                             i = 0;
                             [MomentClass createMultipleMomentsFromLocalToServerWithMoments:moments_exist
                                                                             withTransition:
                              ^(MomentClass *moment) {
                                  
                                  if(block) {
                                      
#ifdef DEBUG_IMPORT_FACEBOOK_EVENT
                                      NSLog(@"\n-------------------------------------------------------------------\n");
                                      NSLog(@"MOMENT\n : {\n %@ \n}", moment);
                                      NSLog(@"OWNER : {\n %@ \n}", moment.owner);
                                      NSLog(@"\n-------------------------------------------------------------------\n");
#endif
                                      
                                      
                                      // Update moments with server attributes
                                      [moments_exist replaceObjectAtIndex:i withObject:moment];
                                  }
                                  i++;
                                  
                              } withEnded:^{
                                  
                                  if(block) {
                                      //  ----- Facebook Events par ordre chronologique -----
                                      int taille = [fb_exist count] + [fb_notExist count];
                                      NSMutableArray *fb = [[NSMutableArray alloc] initWithCapacity:taille];
                                      [fb addObjectsFromArray:fb_exist];
                                      [fb addObjectsFromArray:fb_notExist];
                                      [fb sortUsingComparator:^NSComparisonResult(FacebookEvent *e1, FacebookEvent *e2) {
                                          return [e1.startTime compare:e2.startTime];
                                      }];
                                      
                                      //  ----- Moments par ordre chronologique -----
                                      NSMutableArray *moments = [[NSMutableArray alloc] initWithCapacity:taille];
                                      [moments addObjectsFromArray:moments_exist];
                                      [moments addObjectsFromArray:moments_notExist];
                                      [moments sortUsingComparator:^NSComparisonResult( MomentClass *m1, MomentClass *m2) {
                                          return [m1.dateDebut compare:m2.dateDebut];
                                      }];
                                      
#ifdef DEBUG_IMPORT_FACEBOOK_EVENT
                                      NSLog(@"\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ FIN $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n");
                                      
                                      NSLog(@"\n-------------------------------------------------------------------\n");
                                      NSLog(@"MOMENT\n : {\n %@ \n}", moments);
                                      NSLog(@"EVENTS : {\n %@ \n}", fb);
                                      NSLog(@"\n-------------------------------------------------------------------\n");
#endif
                                      
                                      // Retourne tableaux
                                      block(fb, moments);
                                  }
                                  
                              }]; // Fin Moments Exists
                             
                             
                         }]; // Fin Moments Not Exists
                        
                        
                    }];// Fin identifyFacebookEvents
                }
                
                
            }];
        }
        else
        {
            block(nil, nil);
        }
        
    }];
}

#pragma mark - Get Moments

+ (void) getMomentsForUser:(UserClass*)user withEnded:(void (^) (NSArray* moments))block
{
    NSString *path = [NSString stringWithFormat:@"momentsofuser/%d", user.userId.intValue];
        
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(block)
            block([MomentClass arrayOfMomentsWithArrayOfAttributesFromWeb:JSON[@"moments"]]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error = %@", error.localizedDescription);
        //NSLog(@"Message = %@", operation.responseString);
        
        if(block)
            block(nil);
        
    } waitUntilFinisehd:NO];
    
}

+ (void) getMomentsServerWithEnded:(void (^)(BOOL success))block waitUntilFinished:(BOOL)waitUntilFinished
{
    
    NSString *path = @"moments";
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *moments = JSON[@"moments"];
        [MomentCoreData updateMomentsWithArray:moments];
        
        if(block)
            block(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error = %@", error.localizedDescription);
        //NSLog(@"Message = %@", operation.responseString);
        
        if(block)
            block(NO);
        
    } waitUntilFinisehd:waitUntilFinished];
    
}

+ (void) getMomentsServerWithEnded:(void (^)(BOOL))block
{
    [self getMomentsServerWithEnded:block waitUntilFinished:NO];
}

+ (void) getMomentsServerAfterDate:(NSDate*)date
                     timeDirection:(enum TimeDirectiion)timeDirection
                              user:(UserClass*)user
                         withEnded:(void (^) (NSArray* moments))block
{
    static NSDateFormatter *df = nil;
    
    if(!df) {
        df = [[NSDateFormatter alloc] init];
        df.locale = [NSLocale currentLocale];
        df.timeZone = [NSTimeZone systemTimeZone];
        df.calendar = [NSCalendar currentCalendar];
        df.dateFormat = @"yyyy-MM-dd";
    }
    
    NSString *path = nil;
    if(user) {
        path = [NSString stringWithFormat:@"momentsafter/%@/%d/%@", [df stringFromDate:date], timeDirection, user.userId];
    }
    else {
        path = [NSString stringWithFormat:@"momentsafter/%@/%d", [df stringFromDate:date], timeDirection];
    }
        
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSArray *array = JSON[@"moments"];
        //NSLog(@"moments = %@", array);
        
        // Stockage Temporaire uniquement
        NSArray *moments = [MomentClass arrayOfMomentsWithArrayOfAttributesFromWeb:array];
        
        if(block)
            block(moments);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error = %@", error.localizedDescription);
        //NSLog(@"Message = %@", operation.responseString);
        
        if(block)
            block(nil);
        
    }];
}

// Blindage --> Supprime moment déjà présent en local
+ (void) getMomentsServerAfterDateOfMoment:(MomentClass*)moment
                             timeDirection:(enum TimeDirectiion)timeDirection
                                      user:(UserClass*)user
                                 withEnded:(void (^) (NSArray* moments))block
{
    if(block)
    {
        [self getMomentsServerAfterDate:moment.dateDebut
                          timeDirection:timeDirection
                                   user:user
                              withEnded:^(NSArray *moments) {
            
            NSMutableArray *array = moments.mutableCopy;
            if([array containsObject:moment]) {
                [array removeObject:moment];
            }
            
            block(array);
        }];
    }
}

+ (void)getInfosMomentWithId:(NSInteger)momentId
                   withEnded:(void (^) (NSDictionary* attributes) )block
           waitUntilFinished:(BOOL)waitUntilFinished
{
    NSString *path = [NSString stringWithFormat:@"moment/%d", momentId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(JSON && block) {
            block([MomentClass mappingToLocalWithAttributes:JSON]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
    
}

+ (void)getInfosMomentWithId:(NSInteger)momentId
                   withEnded:(void (^) (NSDictionary* attributes) )block
{
    [self getInfosMomentWithId:momentId withEnded:block waitUntilFinished:NO];
}

#pragma mark - Update

- (void)updateMomentFromServerWithEnded:(void (^) (BOOL success) )block
                      waitUntilFinished:(BOOL)waitUntilFinished
{
    [MomentClass getInfosMomentWithId:self.momentId.intValue
                            withEnded:^(NSDictionary *attributes) {
        if(attributes) {
            [self setupWithAttributes:attributes];
            if(block) block(YES);
        }
        else if(block)
            block(NO);
    } waitUntilFinished:waitUntilFinished];
}

- (void)updateMomentFromServerWithEnded:(void (^) (BOOL success) )block {
    [self updateMomentFromServerWithEnded:block waitUntilFinished:NO];
}

- (void)updateCurrentUserState:(enum UserState)state withEnded:(void (^) (BOOL success) )block
{
    NSString *path = [NSString stringWithFormat:@"state/%d/%d", self.momentId.intValue, state];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
                
        //NSLog(@"Change state : %@", JSON);
        
        // Update RSVP on facebook
        if(self.facebookId)
        {
            [[FacebookManager sharedInstance] updateRSVP:state moment:self withEnded:^(BOOL success) {
                
                /*
                if(success) {
                    NSLog(@"Change Facebook RSVP Success");
                }
                else {
                    NSLog(@"Change Facebook RSVP Fail");
                }
                 */
                
            }];
        }
        
        if(block) {
            self.state = @(state);
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        TFLog(@"State sended : %d", state);
        
        if(block)
            block(NO);
        
    }];
}

- (void)updateUserWithIdAsAdmin:(NSInteger)userId withEnded:(void (^) (BOOL success) )block
{
    NSString *path = [NSString stringWithFormat:@"admin/%d/%d", self.momentId.intValue, userId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
                
        //NSLog(@"Admin : %@", JSON);
        
        if(block) {
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
        
    }];
}


- (void)updateMomentFromLocalToServerWithEnded:(void (^) (BOOL success))block
{
    NSString *path = [NSString stringWithFormat:@"moment/%@", self.momentId];
    
    NSMutableDictionary *params = [self mappingToWeb].mutableCopy;
    
    //NSLog(@"Params = %@", params);
    
    NSData *file = nil;
    // Si il y a une image
    if(params[@"photo"]) {
        
        // Conversion si nécessaire
        if([params[@"photo"] isKindOfClass:[UIImage class]]) {
            file = UIImagePNGRepresentation(params[@"photo"]);
        }
        else if([params[@"photo"] isKindOfClass:[NSData class]]) {
            file = params[@"photo"];
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
        
        //NSLog(@"Moment Modified = %@", JSON);
        //NSLog(@"Local Moment = %@", self);
        // Save Headers
        [[AFMomentAPIClient sharedClient] saveHeaderResponse:operation.response];
        
        // Save URL
        if(file) {
            self.imageString = JSON[@"photo"];
            self.dataImage = nil;
            self.uimage = nil;
        }
        
        // Mettre à jour CoreData
        [MomentCoreData updateMoment:self];
                
        if(block)
            block(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
        //NSLog(@"Error : %@", error.localizedDescription);
        //NSLog(@"Message : %@", operation.responseString);
                
        if(block)
            block(NO);
        
    }];
    
    [operation start];
}

/*
- (void)togglePrivacyWithEnded:(void (^) (BOOL success))block
{
    NSString *path = [NSString stringWithFormat:@"openmoment/%@", self.momentId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        //NSLog(@"reponse = %@", JSON);
        
        if(block) {
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
        
    }];
    
}
 */


#pragma mark - Photos

- (void)getPhotosWithEnded:( void (^) (NSArray* photos) )block
{
    NSString *path = [NSString stringWithFormat:@"photosmoment/%d", self.momentId.intValue];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
                        
        if(block) {
            block([Photos arrayWithArrayFromWeb:JSON[@"photos"]]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
        
    }];
}

- (AFJSONRequestOperation*)operationSendPhoto:(UIImage*)photo
                                    withStart:(void (^) (UIImage *photo))startBlock
                              withProgression:(void (^) (CGFloat progress))progressBlock
                                    withEnded:(void (^) (Photos *photo))endBlock
{
    NSString *path = [NSString stringWithFormat:@"addphoto/%d", self.momentId.intValue];
    
    NSData *file = nil;
    if(photo) {
        file = UIImagePNGRepresentation(photo);
    }
    
    NSMutableURLRequest *request = [[AFMomentAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        if(file)
            [formData appendPartWithFileData:file name:@"photo" fileName:@"photo.png" mimeType:@"image/png"];
    }];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:30.0];
    
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    if(progressBlock) {
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            CGFloat progression = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
            progressBlock(progression);
        }];
    }
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        [[AFMomentAPIClient sharedClient] saveHeaderResponse:operation.response];
        
        Photos *photo = [[Photos alloc] initWithAttributesFromWeb:JSON[@"success"]];
        
        // Notify Facebook Notification
        if(self.facebookId)
        {
            [[FacebookManager sharedInstance] postMessageOnEventWall:self photo:photo withEnded:^(BOOL success) {
                if(!success) {
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Facebook Notification Fail - Photo %d - Moment %@", photo.photoId, self.momentId]];
                }
            }];
        }
        
        if(endBlock)
            endBlock(photo);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error : %@", error.localizedDescription);
        //NSLog(@"Message : %@", operation.responseString);
        
        if(endBlock)
            endBlock(nil);
        
    }];
    
    if(startBlock)
        startBlock(photo);
    
    return operation;
}

- (void)sendPhoto:(UIImage*)photo
        withStart:(void (^) (UIImage *photo))startBlock
        withProgression:(void (^) (CGFloat progress))progressBlock
        withEnded:(void (^) (Photos *photo))endBlock
{
    AFJSONRequestOperation *operation = [self operationSendPhoto:photo
                                                       withStart:startBlock
                                                 withProgression:progressBlock
                                                       withEnded:endBlock];
    
    [operation start];
}

- (void)sendArrayOfPhotos:(NSArray*)array
                withStart:(void (^) (UIImage *photo))startBlock
          withProgression:(void (^) (CGFloat progress))progressBlock
           withTransition:(void (^) (Photos *photo))transitionBlock
                withEnded:(void (^) (void))endBlock
{
    // Tableau exist
    if(array)
    {

        int taille = [array count];
        
        // Tableau non vide
        if(taille > 0)
        {
            // Utilisé pour la condition d'arret
            taille = taille - 1;
            
            // Envoi successif des photos --> Block Récursif
            __block void (^recursifEndBlock) (Photos *photo);
            __block int i = 0;
            
            // Block
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            recursifEndBlock = [^(Photos *photo) {
                
                // Save
                if(transitionBlock)
                    transitionBlock(photo);
                
                // Fin
                if(i == taille)
                {
                    if(endBlock)
                        endBlock();
                }
                // Photo suivante
                else
                {
                    // Send
                    i++;
                    [self sendPhoto:array[i]
                          withStart:startBlock
                    withProgression:progressBlock
                          withEnded:recursifEndBlock];
                }
                
            } copy];
 #pragma clang diagnostic pop
            
            // Envoi de la première photo
            [self sendPhoto:array[0]
                  withStart:startBlock
            withProgression:progressBlock
                  withEnded:recursifEndBlock];
        }
        
    }
}

#pragma mark - Suppression

- (void)deleteWithEnded:(void (^) (BOOL success))block
{
    NSString *path = [NSString stringWithFormat:@"delmoment/%@", self.momentId];
    
    //NSLog(@"delete moment path = %@", path);
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(block) {
            block(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(NO);
        
    }];
    
}

#pragma mark - Invites

- (void)inviteNewGuest:(NSArray*)users withEnded:( void (^) (BOOL success) )block
{
    NSString *path = [NSString stringWithFormat:@"newguests/%d", self.momentId.intValue];
    
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
        NSMutableDictionary *newUser = [MomentClass englobeUserWithAdminAttributeFromWeb:user admin:isAdmin];
        [final addObject:newUser];
    }
    return final;
}

- (void)getInvitedUsersWithAdminEncapsulation:(BOOL)adminEncapsulation
                      withEnded:( void (^) (NSDictionary* invites) )block
{
    NSString *path = [NSString stringWithFormat:@"guests/%d", self.momentId.intValue];
    
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
                                                  admin = [MomentClass englobeUserArrayWithAdminAttributesFromWeb:admin admin:YES];
                                                  if(owner)
                                                      owner = [MomentClass englobeUserWithAdminAttributeFromWeb:owner admin:YES];
                                                  
                                                  // Convert non admins
                                                  maybe = [MomentClass englobeUserArrayWithAdminAttributesFromWeb:maybe admin:NO];
                                                  coming = [MomentClass englobeUserArrayWithAdminAttributesFromWeb:coming admin:NO];
                                                  not_coming = [MomentClass englobeUserArrayWithAdminAttributesFromWeb:not_coming admin:NO];
                                                  unknown = [MomentClass englobeUserArrayWithAdminAttributesFromWeb:unknown admin:NO];
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

- (void)getInvitedUsersWithEnded:( void (^) (NSDictionary* invites) )block {
    [self getInvitedUsersWithAdminEncapsulation:YES withEnded:block];
}


@end
