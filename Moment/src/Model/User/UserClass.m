//
//  UserClass.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UserClass.h"
#import "UserClass+Mapping.h"

@implementation UserClass

@synthesize uimage = _uimage;
@synthesize email = _email;
@synthesize facebookId = _facebookId;
@synthesize imageString = _imageString;
@synthesize nom = _nom;
@synthesize numeroMobile = _numeroMobile;
@synthesize prenom = _prenom;
@synthesize secondEmail = _secondEmail;
@synthesize secondPhone = _secondPhone;
@synthesize state = _state;
@synthesize userId = _userId;
@synthesize nb_followers = _nb_followers;
@synthesize nb_follows = _nb_follows;
@synthesize is_followed = _is_followed;
@synthesize descriptionString = _descriptionString;

#pragma mark - Setup

- (void)setupWithAttributesFromLocal:(NSDictionary*)attributes
{
    if(attributes[@"userId"])
        self.userId = @([attributes[@"userId"] intValue]);
    if(attributes[@"nom"])
        self.nom = attributes[@"nom"];
    if(attributes[@"prenom"])
        self.prenom = attributes[@"prenom"];
    if(attributes[@"imageString"])
        self.imageString = attributes[@"imageString"];
    if(attributes[@"dataImage"] && [attributes[@"dataImage"] isKindOfClass:[NSData class]])
        self.uimage = [[UIImage alloc] initWithData:attributes[@"dataImage"]];
    if(attributes[@"photo"] && [attributes[@"photo"] isKindOfClass:[UIImage class]])
        self.uimage = attributes[@"photo"];
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
        self.nb_follows = attributes[@"nb_follows"];
    if(attributes[@"nb_followers"])
        self.nb_followers = attributes[@"nb_followers"];
    if(attributes[@"is_followed"])
        self.is_followed = attributes[@"is_followed"];
    if(attributes[@"description"])
        self.descriptionString = attributes[@"description"];
}

- (void)setupWithAttributesFromWeb:(NSDictionary*)attributes {
    [self setupWithAttributesFromLocal:[UserClass mappingToLocalAttributes:attributes]];
}

#pragma mark - Init

- (id)initWithAttributesFromLocal:(NSDictionary*)attributes
{
    self = [super init];
    if(self) {
        [self setupWithAttributesFromLocal:attributes];
    }
    return self;
}

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes {
    self = [super init];
    if(self) {
        [self setupWithAttributesFromWeb:attributes];
    }
    return self;
}

+ (NSArray*)arrayOfUsersWithArrayOfAttributesFromLocal:(NSArray*)arrayAttributes
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[arrayAttributes count]];
    for( NSDictionary *attr in arrayAttributes ) {
        // Stockage temporaire uniquement --> Pour ne pas surcharger la BDD
        [array addObject:[[UserClass alloc] initWithAttributesFromLocal:attr]];
    }
    return array;
}

+ (NSArray*)arrayOfUsersWithArrayOfAttributesFromWeb:(NSArray*)arrayAttributes
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[arrayAttributes count]];
    for( NSDictionary *attr in arrayAttributes ) {
        // Stockage temporaire uniquement --> Pour ne pas surcharger la BDD
        [array addObject:[[UserClass alloc] initWithAttributesFromWeb:attr]];
    }
    return array;
}

#pragma mark - Comparaison

- (BOOL)isEqual:(id)object
{
    if([object respondsToSelector:@selector(userId)] && [object userId]) {
        return [self.userId isEqualToNumber:[object userId]];
    }
    return NO;
}

#pragma mark - Util

- (NSString*)formatedUsername {
    return [self formatedUsernameWithStyle:UsernameStyleUppercase];
}

- (NSString*)formatedUsernameWithStyle:(enum UsernameStyle)style {
    return [UserClass formatedUsernameWithFirstname:self.prenom lastname:self.nom style:style];
}

+ (NSString*)formatedUsernameWithFirstname:(NSString*)firstname
                                  lastname:(NSString*)lastname
                                     style:(enum UsernameStyle)style
{
    // Nom de l'expéditeur
    NSString *username = nil;
    NSString *prenom = nil;
    NSString *nom = nil;
    
    // Style
    switch (style) {
        case UsernameStyleUppercase:
            prenom = firstname.uppercaseString;
            nom = lastname.uppercaseString;
            break;
            
        case UsernameStyleCapitalized:
            prenom = firstname.capitalizedString;
            nom = lastname.capitalizedString;
            break;
            
        case UsernameStyleUnchanged:
            prenom = firstname;
            nom = lastname;
            break;
    }
    
    // Format
    if(lastname && firstname) {
        username = [NSString stringWithFormat:@"%@ %@", prenom, nom];
    }
    else if(lastname || firstname) {
        if(firstname)
            username = prenom;
        else
            username = nom;
    }
    
    return username ?: @"";
}

#pragma mark - Debug

- (NSString*)description {
    return [NSString stringWithFormat:@"USER %@ :\n{\nnom = %@\nprenom = %@\nfacebookId = %@\npictureString = %@\n}\n", self.userId, self.nom, self.prenom, self.facebookId, self.imageString];
}

@end
