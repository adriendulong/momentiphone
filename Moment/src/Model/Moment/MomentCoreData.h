//
//  MomentCoreData.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserCoreData;

@interface MomentCoreData : NSManagedObject

@property (nonatomic, retain) NSString * adresse;
@property (nonatomic, retain) NSData * dataImage;
@property (nonatomic, retain) NSDate * dateDebut;
@property (nonatomic, retain) NSDate * dateFin;
@property (nonatomic, retain) NSString * descriptionString;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSNumber * guests_coming;
@property (nonatomic, retain) NSNumber * guests_not_coming;
@property (nonatomic, retain) NSNumber * guests_number;
@property (nonatomic, retain) NSString * hashtag;
@property (nonatomic, retain) NSString * imageString;
@property (nonatomic, retain) NSString * infoLieu;
@property (nonatomic, retain) NSString * infoMetro;
@property (nonatomic, retain) NSNumber * isOpen;
@property (nonatomic, retain) NSNumber * isSponso;
@property (nonatomic, retain) NSNumber * momentId;
@property (nonatomic, retain) NSString * nomLieu;
@property (nonatomic, retain) NSNumber * privacy;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * titre;
@property (nonatomic, retain) UserCoreData *owner;

@end
