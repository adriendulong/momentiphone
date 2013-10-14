//
//  MomentClass.h
//  Moment
//
//  Created by Charlie FANCELLI on 01/11/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UserClass.h"

@interface MomentClass : NSObject

@property (readonly) NSUInteger momentId;

@property (readonly, strong) NSDate *dateCreation;
@property (readonly, strong) NSDate *dateModification;
@property (readonly, strong) NSDate *dateDebut;
@property (readonly, strong) NSDate *dateFin;

@property (readonly, strong) NSString *descriptionString;
@property (readonly, strong) NSString *titre;
@property (readonly, strong) NSString *hashtag;

@property (readonly, strong) NSString *nomLieu;
@property (readonly, strong) NSString *numeroEtRue;
@property (readonly, strong) NSString *codePostal;
@property (readonly, strong) NSString *ville;
@property (readonly, strong) NSString *infoMetro;
@property (readonly, strong) NSString *infoLieu;

@property (readonly) NSInteger state;

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *usersWaiting;
@property (nonatomic, strong) NSArray *usersRefused;

@property (nonatomic, strong) UserClass *owner;

@property (readonly, strong) NSString *imageString;
@property (nonatomic, strong) UIImage *image;

-(id)initWithDefaut;

- (id)initWithAttributes:(NSDictionary *)attributes;
+ (void) getMomentsWithOptions:(NSDictionary *)options success:(void (^)(NSArray *))block;
+ (NSDictionary *) mapping;

@end
