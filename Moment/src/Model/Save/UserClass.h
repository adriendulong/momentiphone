//
//  UserClass.h
//  Moment
//
//  Created by Charlie FANCELLI on 15/10/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserClass : NSObject

@property (readonly) NSInteger userId;
@property (nonatomic, strong) NSString *nom;
@property (nonatomic, strong) NSString *prenom;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *mdp;

@property (nonatomic, strong) NSString *numeroMobile;

@property (nonatomic) NSInteger sexe;

@property (nonatomic, strong) NSString *imageString;
@property (nonatomic, strong) UIImage *image;

- (void)createUserWithEnded:(void (^)(NSArray *))block;

+ (void)loginUserWithUsername:(NSString *)username withPaswword:(NSString *)password WithEnded:(void (^)(BOOL))block;
+ (NSDictionary *) mapping;


- (id)initWithPrenom:(NSString*)prenom nom:(NSString*)nom username:(NSString*)username mdp:(NSString*)mdp;
- (id)initDefault;


@end
