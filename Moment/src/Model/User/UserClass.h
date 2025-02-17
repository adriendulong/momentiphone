//
//  UserClass.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

enum UsernameStyle {
    UsernameStyleUppercase = 0,
    UsernameStyleCapitalized = 1,
    UsernameStyleUnchanged = 2
    };

enum UserSex {
    UserSexMale = 0,
    UserSexFemale = 1
    };

@interface UserClass : NSObject

@property (nonatomic, strong) UIImage * uimage;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * facebookId;
@property (nonatomic, strong) NSString * imageString;
@property (nonatomic, strong) NSString * nom;
@property (nonatomic, strong) NSString * numeroMobile;
@property (nonatomic, strong) NSString * prenom;
@property (nonatomic, strong) NSString * secondEmail;
@property (nonatomic, strong) NSString * secondPhone;
@property (nonatomic, strong) NSNumber * state;
@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSNumber *nb_follows;
@property (nonatomic, strong) NSNumber *nb_followers;
@property (nonatomic, strong) NSNumber *nb_moments;
@property (nonatomic, strong) NSNumber *nb_photos;
@property (nonatomic, strong) NSNumber *is_followed;
@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic, strong) NSNumber *privacy;
@property (nonatomic, strong) NSNumber *request_follower;
@property (nonatomic, strong) NSNumber *request_follow_me;
@property (nonatomic) enum UserSex sex;

// Setup
- (void)setupWithAttributesFromLocal:(NSDictionary*)attributes;
- (void)setupWithAttributesFromWeb:(NSDictionary*)attributes;

// Init
- (id)initWithAttributesFromLocal:(NSDictionary*)attributes;
- (id)initWithAttributesFromWeb:(NSDictionary*)attributes;

+ (NSArray*)arrayOfUsersWithArrayOfAttributesFromLocal:(NSArray*)arrayAttributes;
+ (NSArray*)arrayOfUsersWithArrayOfAttributesFromWeb:(NSArray*)arrayAttributes;

// Util
- (NSString*)formatedUsername;
- (NSString*)formatedUsernameWithStyle:(enum UsernameStyle)style;
+ (NSString*)formatedUsernameWithFirstname:(NSString*)firstname
                                  lastname:(NSString*)lastname
                                     style:(enum UsernameStyle)style;

@end
