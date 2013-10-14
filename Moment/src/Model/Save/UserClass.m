//
//  UserClass.m
//  Moment
//
//  Created by Charlie FANCELLI on 15/10/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "UserClass.h"

//#import "AFTGoandupAPIClient.h"
//#import "AFHTTPRequestOperation.h"
//#import "MessageServeur.h"

@implementation UserClass

@synthesize userId = _userId;
@synthesize nom = _nom;
@synthesize prenom = _prenom;
@synthesize numeroMobile = _numeroMobile;
@synthesize sexe = _sexe;
@synthesize email = _email;
@synthesize username = _username;
@synthesize mdp = _mdp;

@synthesize imageString = _imageString;
@synthesize image = _image;

#pragma mark - Debug Init

- (id)initWithPrenom:(NSString*)prenom nom:(NSString*)nom username:(NSString*)username mdp:(NSString*)mdp {
    static NSInteger nbId = 0;
    
    self = [super init];
    if(self) {
        
        _userId = nbId;
        nbId++;
        
        self.nom = nom;
        self.prenom = prenom;
        self.username = username;
        self.mdp = mdp;
        self.sexe = 0;
        self.numeroMobile = 0;
        self.email = nil;
        self.imageString = nil;
        self.image = [UIImage imageNamed:@"demo1.png"];
        
    }
    return self;
}

- (id)initDefault {
    self = [self initWithPrenom:@"Mathieu" nom:@"Pieraggi" username:@"matt" mdp:@"mdp"];
    return self;
}

#pragma mark - Init

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+SSSS"];
    
    _userId = [[attributes objectForKey:@"id"] integerValue];
    _nom = [attributes objectForKey:@"nom"];
    _prenom = [attributes objectForKey:@"prenom"];
    _numeroMobile = [attributes objectForKey:@"numero_mobile"];
    _sexe = [[attributes objectForKey:@"sexe"] integerValue];
    _email = [attributes objectForKey:@"email"];
    _username = [attributes objectForKey:@"username"];
    
    return self;
}

+ (NSDictionary *) mapping{
    NSDictionary *mapping = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"userId", @"id",
                             @"nom", @"nom",
                             @"prenom",@"prenom",
                             @"numeroMobile",@"numero_mobile",
                             @"sexe",@"sexe",
                             @"email",@"email",
                             @"username",@"username",
                             nil];
    
    return mapping;
}

- (NSMutableDictionary *)serialize{
    NSMutableDictionary *userParams = [[NSMutableDictionary alloc] init];
    
    [userParams setValue:_nom forKey:@"nom"];
    [userParams setValue:_prenom forKey:@"prenom"];
    [userParams setValue:_email forKey:@"email"];
    [userParams setValue:_email forKey:@"username"];
    [userParams setValue:_mdp forKey:@"plainPassword"];
    [userParams setValue:_numeroMobile forKey:@"numeroMobile"];
    [userParams setValue:[NSNumber numberWithInt:_sexe] forKey:@"sexe"];
    
    return userParams;
}


+ (void)loginUserWithUsername:(NSString *)username withPaswword:(NSString *)password WithEnded:(void (^)(BOOL))block {
    
    /*
    NSLog(@"ON LOG LE USER !");
    
    NSString *path = @"login";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:username forKey:@"_username"];
    [params setObject:password forKey:@"_password"];
    
    NSLog(@"Envoyé : %@", params);
    
    [[AFTGoandupAPIClient sharedClient] postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {        
        NSString *token = [JSON valueForKey:@"token"];
        if( token ){
            //loader le User dans la cond -- code métier
            
            if (block) {
                block(YES);
            }
        }
        if (block) {
            block(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MessageServeur showMessage:operation withError:error];
        
        if (block) {
            block(NO);
        }
    }];
     */
    
    if([username isEqualToString:@"username"] && [password isEqualToString:@"password"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:@"userLoged"];
        block(YES);
    }
    else {
        block(NO);
    }    
}


- (void)createUserWithEnded:(void (^)(NSArray *))block {
    
    NSLog(@"ON CREE LE USER !");
    
    //NSString *path = @"create";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params setObject:[self serialize] forKey:@"user"];
    [params setObject:@"1" forKey:@"debug"];
    
    NSLog(@"Envoyé : %@", params);
    
    /*
    [[AFTGoandupAPIClient sharedClient] postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[JSON count]];
        
        NSLog(@"Reçu : %@", JSON);
        
        for (NSDictionary *attributes in JSON) {
            
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableArray]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MessageServeur showMessage:operation withError:error];
        
        if (block) {
            block(nil);
        }
    }];
    */

}

@end
