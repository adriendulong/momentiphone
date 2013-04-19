//
//  MomentClass.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 13/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCoreData+Model.h"
#import "FacebookEvent.h"

@interface MomentClass : NSObject

@property (nonatomic, strong) NSString * adresse;
@property (nonatomic, strong) NSData * dataImage;
@property (nonatomic, strong) NSDate * dateDebut;
@property (nonatomic, strong) NSDate * dateFin;
@property (nonatomic, strong) NSString * descriptionString;
@property (nonatomic, strong) NSNumber * guests_coming;
@property (nonatomic, strong) NSNumber * guests_not_coming;
@property (nonatomic, strong) NSNumber * guests_number;
@property (nonatomic, strong) NSString * hashtag;
@property (nonatomic, strong) NSString * imageString;
@property (nonatomic, strong) NSString * infoLieu;
@property (nonatomic, strong) NSString * infoMetro;
@property (nonatomic, strong) NSNumber * momentId;
@property (nonatomic, strong) NSString * nomLieu;
@property (nonatomic, strong) NSNumber * state;
@property (nonatomic, strong) NSString * titre;
@property (nonatomic, strong) NSString * facebookId;
@property (nonatomic, strong) NSSet *notifications;
@property (nonatomic, strong) UserClass *owner;
@property (nonatomic, strong) UIImage *uimage;
@property (nonatomic, strong) NSNumber *isOpen;
@property (nonatomic, strong) NSNumber *isSponso;

// Init
- (void)setupWithAttributes:(NSDictionary*)attributes;
- (id)initWithAttributesFromLocal:(NSDictionary*)attributes;
- (id)initWithAttributesFromWeb:(NSDictionary*)attributes;
- (id)initWithFacebookEvent:(FacebookEvent*)event;

+ (NSArray*)arrayOfMomentsWithArrayOfAttributesFromWeb:(NSArray*)array;
+ (NSArray*)arrayOfMomentsWithFacebookEvents:(NSArray*)events;

@end
