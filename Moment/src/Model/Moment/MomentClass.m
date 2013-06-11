//
//  MomentClass.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 13/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "MomentClass.h"
#import "UserClass+Mapping.h"
#import "MomentClass+Mapping.h"

@implementation MomentClass

@synthesize adresse = _adresse;
@synthesize dataImage = _dataImage;
@synthesize dateDebut = _dateDebut;
@synthesize dateFin = _dateFin;
@synthesize descriptionString = _descriptionString;
@synthesize guests_coming = _guests_coming;
@synthesize guests_not_coming = _guests_not_coming;
@synthesize guests_number = _guests_number;
@synthesize hashtag = _hashtag;
@synthesize imageString = _imageString;
@synthesize infoLieu = _infoLieu;
@synthesize infoMetro = _infoMetro;
@synthesize momentId = _momentId;
@synthesize nomLieu = _nomLieu;
@synthesize state = _state;
@synthesize titre = _titre;
@synthesize facebookId = _facebookId;
@synthesize notifications = _notifications;
@synthesize owner = _owner;
@synthesize uimage = _uimage;
@synthesize isOpen = _isOpen;
@synthesize isSponso = _isSponso;
@synthesize uniqueURL = _uniqueURL;
@synthesize coverPhotoURL = _coverPhotoURL;

- (void)setupWithAttributes:(NSDictionary*)attributes
{
    if(attributes[@"momentId"])
        self.momentId = attributes[@"momentId"];
    if(attributes[@"titre"])
        self.titre = attributes[@"titre"];
    if(attributes[@"dateDebut"])
        self.dateDebut = attributes[@"dateDebut"];
    if(attributes[@"dateFin"])
        self.dateFin = attributes[@"dateFin"];
    if(attributes[@"isSponso"])
        self.isSponso = attributes[@"isSponso"];
    
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
    
    if(attributes[@"facebookId"])
        self.facebookId = [NSString stringWithFormat:@"%@", attributes[@"facebookId"]];
    
    if(attributes[@"isOpenInvit"])
        self.isOpen = @([attributes[@"isOpenInvit"] boolValue]);
    
    if(attributes[@"privacy"])
        self.privacy = attributes[@"privacy"];
    
    if(attributes[@"unique_url"])
        self.uniqueURL = attributes[@"unique_url"];
    
    if(attributes[@"cover_photo_url"])
        self.coverPhotoURL = attributes[@"cover_photo_url"];
    
    if(attributes[@"owner"]) {
        UserClass *owner = nil;
        NSDictionary *dico = [UserClass mappingToLocalAttributes:attributes[@"owner"]];
        owner = [UserCoreData requestUserWithAttributes:dico];
        
        //NSLog(@"owner = %@", attributes[@"owner"]);
        self.owner = owner;
    }
}

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes
{
    return [self initWithAttributesFromLocal:[MomentClass mappingToLocalWithAttributes:attributes]];
}

- (id)initWithAttributesFromLocal:(NSDictionary*)attributes
{
    self = [super init];
    if(self) {
        [self setupWithAttributes:attributes];
    }
    return self;
}

- (id)initWithFacebookEvent:(FacebookEvent*)event
{
    if(!event)
        return nil;
    
    self = [super init];
    if(self) {
        self.titre = event.name;
        self.state = @(event.rsvp_status);
        self.imageString = event.pictureString;
        
        if(event.owner) {
            self.owner = event.owner;
            NSLog(@"has user");
        }
        else if(event.ownerAttributes[@"id"]) {
            self.owner = [UserCoreData requestUserWithAttributes:@{@"facebookId":event.ownerAttributes[@"id"]}];
            NSLog(@"no user = %@", self.owner);
            NSLog(@"user found = %@", self.owner);
        }
        
        self.adresse = event.location;
        self.dateDebut = event.startTime;
        self.dateFin = event.endTime;
        self.descriptionString = event.descriptionString;
        self.facebookId = event.eventId;
        // self.isOpen = @(!event.isPrivate);
        self.privacy = event.isPrivate ? @(MomentPrivacyPublic) : @(MomentPrivacyOpen);
    }
    return self;
}

+ (NSArray*)arrayOfMomentsWithArrayOfAttributesFromWeb:(NSArray*)array
{    
    NSMutableArray *moments = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for( NSDictionary *attr in array ) {
        if(attr && attr[@"id"])
            [moments addObject:[[MomentClass alloc] initWithAttributesFromWeb:attr]];
    }
    return moments;
}

+ (NSArray*)arrayOfMomentsWithFacebookEvents:(NSArray*)events
{
    NSMutableArray *moments = [[NSMutableArray alloc] initWithCapacity:[events count]];
    for( FacebookEvent *e in events ) {
        [moments addObject:[[MomentClass alloc] initWithFacebookEvent:e]];
    }
    return moments;
}

- (BOOL)isEqual:(id)object
{
    if([object respondsToSelector:@selector(momentId)]) {
        return [self.momentId isEqualToNumber:[object momentId]];
    }
    return NO;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"MOMENT %@ :\n{\ntitre = %@\ndebut = %@\nfin = %@\nimage = %@\nadresse = %@\nfbID = %@\ndescription = \n-----\n%@\n-----\nowner : \n-----\n%@\n-----\n}\n", self.momentId, self.titre, self.dateDebut, self.dateFin, self.imageString, self.adresse, self.facebookId, self.descriptionString, self.owner];
}

@end
