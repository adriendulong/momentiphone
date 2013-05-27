//
//  UserClass+Mapping.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UserClass+Mapping.h"

@implementation UserClass (Mapping)

+ (NSDictionary *) mappingToLocalAttributes:(NSDictionary*)attributes {
    
    NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] init];
    
    if(attributes[@"email"])
        newAttributes[@"email"] = attributes[@"email"];
    if(attributes[@"lastname"])
        newAttributes[@"nom"] = attributes[@"lastname"];
    if(attributes[@"firstname"])
        newAttributes[@"prenom"] = attributes[@"firstname"];
    if(attributes[@"id"])
        newAttributes[@"userId"] = attributes[@"id"];
    
    if(attributes[@"profile_picture_url"])
        newAttributes[@"imageString"] = attributes[@"profile_picture_url"];
    if(attributes[@"phone"])
        newAttributes[@"numeroMobile"] = attributes[@"phone"];
    if(attributes[@"secondPhone"])
        newAttributes[@"secondPhone"] = attributes[@"secondPhone"];
    if(attributes[@"facebookId"])
        newAttributes[@"facebookId"] = attributes[@"facebookId"];
    if(attributes[@"email"])
        newAttributes[@"email"] = attributes[@"email"];
    if(attributes[@"secondEmail"])
        newAttributes[@"secondEmail"] = attributes[@"secondEmail"];
    if(attributes[@"isAdmin"])
        newAttributes[@"isAdmin"] = attributes[@"isAdmin"];
    
    if(attributes[@"nb_followers"])
        newAttributes[@"nb_followers"] = attributes[@"nb_followers"];
    if(attributes[@"nb_follows"])
        newAttributes[@"nb_follows"] = attributes[@"nb_follows"];
    if(attributes[@"nb_moments"])
        newAttributes[@"nb_moments"] = attributes[@"nb_moments"];
    if(attributes[@"nb_photos"])
        newAttributes[@"nb_photos"] = attributes[@"nb_photos"];
    if(attributes[@"is_followed"])
        newAttributes[@"is_followed"] = attributes[@"is_followed"];
    if(attributes[@"description"])
        newAttributes[@"description"] = attributes[@"description"];
    
    //NSLog(@"Mapped : %@", newAttributes);
    
    return newAttributes;
}

+ (NSDictionary*) mappingToWebWithAttributes:(NSDictionary*)attributes
{
    NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] init];
    if(attributes[@"userId"])
        newAttributes[@"id"] = attributes[@"userId"];
    if(attributes[@"email"])
        newAttributes[@"email"] = attributes[@"email"];
    if(attributes[@"nom"])
        newAttributes[@"lastname"] = attributes[@"nom"];
    if(attributes[@"prenom"])
        newAttributes[@"firstname"] = attributes[@"prenom"];
    if(attributes[@"password"])
        newAttributes[@"password"] = attributes[@"password"];
    if(attributes[@"imageString"])
        newAttributes[@"profile_picture_url"] = attributes[@"imageString"];
    if(attributes[@"numeroMobile"])
        newAttributes[@"phone"] = attributes[@"numeroMobile"];
    if(attributes[@"secondPhone"])
        newAttributes[@"secondPhone"] = attributes[@"secondPhone"];
    if(attributes[@"facebookId"])
        newAttributes[@"facebookId"] = attributes[@"facebookId"];
    if(attributes[@"secondEmail"])
        newAttributes[@"secondEmail"] = attributes[@"secondEmail"];
    if(attributes[@"description"])
        newAttributes[@"description"] = attributes[@"description"];
        
    return newAttributes;
}

+ (NSArray*) mappingArrayToLocalAttributes:(NSArray*)array
{    
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for( NSDictionary *attr in array) {
        [newArray addObject:[UserClass mappingToLocalAttributes:attr]];
    }
    return newArray;
}

- (NSDictionary*) mappingToWeb
{
    NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] init];
    if(self.userId)
        newAttributes[@"id"] = self.userId;
    if(self.email)
        newAttributes[@"email"] = self.email;
    if(self.nom)
        newAttributes[@"lastname"] = self.nom;
    if(self.prenom)
        newAttributes[@"firstname"] = self.prenom;
    
    // Optionnels
    if(self.imageString)
        newAttributes[@"profile_picture_url"] = self.imageString;
    if(self.numeroMobile)
        newAttributes[@"phone"] = self.numeroMobile;
    if(self.secondPhone)
        newAttributes[@"secondPhone"] = self.secondPhone;
    if(self.facebookId)
        newAttributes[@"facebookId"] = self.facebookId;
    if(self.secondEmail)
        newAttributes[@"secondEmail"] = self.secondEmail;
    if(self.descriptionString)
        newAttributes[@"description"] = self.descriptionString;
    
    return newAttributes;
}

@end
