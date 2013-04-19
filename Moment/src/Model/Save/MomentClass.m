//
//  MomentClass.m
//  Moment
//
//  Created by Charlie FANCELLI on 01/11/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

//#import "AFTGoandupAPIClient.h"
#import "MomentClass.h"
//#import "MessageServeur.h"

//#import "NSObject+JTObjectMapping.h"

static NSInteger nbId = 0;

@implementation MomentClass

@synthesize momentId = _momentId;
@synthesize dateCreation = _dateCreation;
@synthesize dateModification = _dateModification;
@synthesize dateDebut = _dateDebut;
@synthesize dateFin = _dateFin;

@synthesize descriptionString = _descriptionString;
@synthesize titre = _titre;
@synthesize hashtag = _hashtag;

@synthesize nomLieu = _nomLieu;
@synthesize numeroEtRue = _numeroEtRue;
@synthesize ville = _ville;
@synthesize codePostal = _codePostal;
@synthesize infoMetro = _infoMetro;
@synthesize infoLieu = _infoLieu;

@synthesize state = _state;

@synthesize users = _users;
@synthesize usersWaiting = _usersWaiting;
@synthesize usersRefused = _usersRefused;

@synthesize owner = _owner;

@synthesize imageString = _imageString;
@synthesize image = _image;

#pragma mark - Init

-(id)initWithDefaut
{
    return [self initWithAttributes:nil];
}

- (id)initWithAttributes:(NSDictionary *)attributes
{
#warning A ré-implémenter
    self = [super init];
    if (self) {
        _momentId = nbId;
        nbId++;
        
        _owner = [[UserClass alloc] initWithPrenom:@"Max" nom:@"Baudot" username:@"Max" mdp:@"mdp"];
        
        _titre = [NSString stringWithFormat:@"Moment %d", _momentId];
        _hashtag = @"hashtag";
        
        _dateCreation = [NSDate date];
        _dateModification = [NSDate date];
        _dateDebut = [NSDate dateWithTimeIntervalSinceNow:7*24*3600];
        _dateFin = [NSDate dateWithTimeIntervalSinceNow:14*24*3600];
        
        _descriptionString = @"Forte sermonem plebis odio tum tum Q et in coniunctissime sermonem Meministi essem enim vel admodum in ut coniunctissime ut.\nForte sermonem plebis odio tum tum Q et in coniunctissime sermonem Meministi essem enim vel admodum in ut coniunctissime ut.";
        
        _nomLieu = @"A la maison";
        _numeroEtRue = @"50 cours de la reine";
        _ville = @"Paris";
        _codePostal = @"75006";
         
        _infoMetro = @"Nation - Ligne 4 / 2";
        _infoLieu = @"5eme étage - Code : 18543";
        
        if(nbId%3)
        {
            _image = [UIImage imageNamed:@"kenny.jpg"];
        }
        else
            _imageString = [NSString stringWithFormat:@"coucou"];
    }
    
    return self;
}

#pragma mark -

/*
+ (NSDictionary *) mapping{
    NSDictionary *mapping = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"momentId", @"id",
                             @"dateCreation", @"date_creation",
                             @"titre",@"titre",
                             [UserClass mappingWithKey:@"users"
                                               mapping:[UserClass mapping]], @"users",
                             [UserClass mappingWithKey:@"usersWaiting"
                                               mapping:[UserClass mapping]], @"users_waiting",
                             [UserClass mappingWithKey:@"usersRefused"
                                               mapping:[UserClass mapping]], @"users_refused",
                             nil];
    
    return mapping;
}
*/

+ (void) getMomentsWithOptions:(NSDictionary *)options success:(void (^)(NSArray *))block{
    //NSString *path = @"user/moments";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    //ajout des options
    for( NSString *key in options ){
        [params setObject:[options objectForKey:key] forKey:key];
    }
    
    /*
    [[AFTGoandupAPIClient sharedClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[JSON count]];
        
        //chaque commercant
        for (NSDictionary *attributes in JSON) {
            NSLog(@"attributes : %@", attributes);
            MomentClass *moment = [MomentClass objectFromJSONObject:attributes mapping:[MomentClass mapping]];
            [mutableArray addObject:moment];            
            NSLog(@"moment : %@", moment.usersRefused);
        }

        if (block) {
            block(mutableArray);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MessageServeur showMessage:operation withError:error];
        
        if (block) {
            block(nil);
        }
    }];
    */ 
    
}

#pragma mark - Debug

-(NSString*)description
{
    return [NSString stringWithFormat:@"{\nmoment id = %d\nimage = %@\nimageString = %@\n}", _momentId, _image, _imageString];
}

@end
