//
//  FacebookEvent.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FacebookEvent.h"
#import "FacebookManager.h"

static NSString *kFbRSVPComing = @"attending";
static NSString *kFbRSVPMaybe = @"unsure";
static NSString *kFbRSVPRefused = @"declined";
static NSString *kFbRSVPUnknown = @"not_replied";

static NSDateFormatter *dateFormatter = nil;

@implementation FacebookEvent {
    @private
    NSCondition *synchroneCondition;
    BOOL ownerLoaded;
}

@synthesize eventId = _eventId;
@synthesize name = _name;
@synthesize descriptionString = _descriptionString;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize location = _location;
@synthesize privacy = _privacy;
@synthesize venue = _venue;
@synthesize picture = _picture;
@synthesize pictureString = _pictureString;
@synthesize rsvp_status = _rsvp_status;
@synthesize ownerAttributes = _ownerAttributes;
@synthesize owner = _owner;
@synthesize isAlreadyOnMoment;
@synthesize invited = _invited;

+ (enum UserState)mappRSVP:(NSString*)rsvp
{
    if([rsvp isEqualToString:kFbRSVPComing])
        return UserStateValid;
    if([rsvp isEqualToString:kFbRSVPMaybe])
        return UserStateWaiting;
    if([rsvp isEqualToString:kFbRSVPRefused])
        return UserStateRefused;
    if([rsvp isEqualToString:kFbRSVPUnknown])
        return UserStateUnknown;
    return nil;
}

+ (enum MomentPrivacy)mappPrivacy:(NSString*)privacy
{
    if([privacy isEqualToString:@"OPEN"])
        return MomentPrivacyOpen;
    if([privacy isEqualToString:@"SECRET"])
        return MomentPrivacySecret;
    // FRIENDS
    return MomentPrivacyFriends;
}

- (void)setupOwner:(NSString*)ownerId withEnded:(void (^) (FacebookEvent *event))block
{
    [[FacebookManager sharedInstance] getUserInformationsWithId:ownerId withEnded:^(UserClass *user) {
        
        self.owner = user;
        if(block)
            block(self);
    }];
}

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.calendar = [NSCalendar currentCalendar];
            dateFormatter.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.locale = [NSLocale currentLocale];
        }
        
        // Pas d'heure fournie
        if([attributes[@"is_date_only"] boolValue]) {
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
        // Heure fournie
        else {
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+SSSS"];
        }
        
        _eventId = attributes[@"id"];
        self.name = attributes[@"name"];
        self.descriptionString = attributes[@"description"];
        self.startTime = [dateFormatter dateFromString:[attributes objectForKey:@"start_time"]];
        self.endTime = [dateFormatter dateFromString:[attributes objectForKey:@"end_time"]];
        self.location = attributes[@"location"];
        self.privacy = [FacebookEvent mappPrivacy:attributes[@"privacy"]];
        self.venue = attributes[@"venue"];
        self.rsvp_status = [FacebookEvent mappRSVP:attributes[@"rsvp_status"]];
        self.isAlreadyOnMoment = NO;
        self.invited = attributes[@"invited"];
        
        // Cover Picture
        if(attributes[@"cover"]) {
            self.pictureString = attributes[@"cover"][@"source"];
        }
         else if(attributes[@"picture"]) {
             
             NSString *path = attributes[@"picture"][@"data"][@"url"];
             NSURL *url = [NSURL URLWithString:path];
             NSData *data = [NSData dataWithContentsOfURL:url];
             UIImage *img = [[UIImage alloc] initWithData:data];
             CGSize size = img.size;
             
             //NSLog(@"size = %@",NSStringFromCGSize(size));
             
             if (size.height == 50 && size.width == 50) {
                 
                 [[FacebookManager sharedInstance] getCoverEventWithID:_eventId withEnded:^(NSString *pic_url) {
                     while ([pic_url isEqualToString:nil]) {
                         // If A job is finished, a flag should be set. and the flag can be a exit condition of this while loop
                         
                         // This executes another run loop.
                         [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                     }
                     
                     //NSLog(@"pic_url = %@", pic_url);
                     
                     self.pictureString = pic_url;
                 }];
             } else {
                 self.pictureString = attributes[@"picture"][@"data"][@"url"];
             }
         }
        
        // Current User ID
        NSString *userId = [UserCoreData getCurrentUser].facebookId;
        
        // Admin ?
        if(attributes[@"admins"])
        {
            NSArray *admins = attributes[@"admins"][@"data"];
            for( NSDictionary* admin in admins ) {
                
                // Si le user est admin
                if([admin[@"id"] isEqualToString:userId]) {
                    self.rsvp_status = UserStateAdmin;
                    break;
                }
                
            }
        }
        
        // Owner ?
        NSDictionary *owner = attributes[@"owner"];
        // Si le user est le owner
        if( [owner[@"id"] isEqualToString:userId] ) {
            // Update RSVP Status
            self.rsvp_status = UserStateOwner;
        }
        else {
            self.ownerAttributes = owner;
        }
                
        
    }
    return self;
}

+ (void)arrayWithArrayOfEvents:(NSArray*)eventsArray
                withArrayOfOwnerId:(NSArray*)ownerIdsArray
                         withEnded:(void (^) (NSArray *events))block
{
    // Tableau exist
    if(eventsArray && ownerIdsArray)
    {
        
        int taille = [eventsArray count];
        
        // Tableau non vide
        if(taille > 0)
        {            
            // Utilisé pour la condition d'arret
            taille = taille - 1;
            
            // Envoi successif  --> Block Récursif
            __block void (^recursifEndBlock) (NSDictionary *attr);
            __block int i;
            
            
            //  -------------- Block -------------
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            recursifEndBlock = [^(NSString *oID) {
                
                // Fin
                if(i == taille)
                {
                    if(block)
                        block(eventsArray);
                }
                else
                {
                    // Créer
                    FacebookEvent *e = eventsArray[i];
                    // Setup Owner
                    [e setupOwner:oID withEnded:^(FacebookEvent *event) {
                                                
                        // Suivant
                        i++;
                        recursifEndBlock(ownerIdsArray[i]);
                    }];
                }
                
            } copy];
#pragma clang diagnostic pop
            // -----------------------------------
            
            
            // Premier appel
            i = 0;
            recursifEndBlock(ownerIdsArray[i]);
            
        }
        
    }
    
}

- (NSString*)description {
    return [NSString stringWithFormat:@"FACEBOOK EVENT %@ :\n{\nNOM : %@\nADRESSE : %@\nRSVP : %d\nOWNER:\n{\n %@ \n}\nINVITED:\n{\n %@ \n}\n-----------\n", self.eventId, self.name, self.location, self.rsvp_status, self.owner, self.invited];
}


@end
