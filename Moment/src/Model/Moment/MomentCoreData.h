//
//  MomentCoreData.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocalNotificationCoreData, UserCoreData;

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
@property (nonatomic, retain) NSNumber * momentId;
@property (nonatomic, retain) NSString * nomLieu;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * titre;
@property (nonatomic, retain) NSNumber * isSponso;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) UserCoreData *owner;
@end

@interface MomentCoreData (CoreDataGeneratedAccessors)

- (void)addNotificationsObject:(LocalNotificationCoreData *)value;
- (void)removeNotificationsObject:(LocalNotificationCoreData *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

@end
