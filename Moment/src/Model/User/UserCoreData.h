//
//  UserCoreData.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 03/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessageCoreData, MomentCoreData;

@interface UserCoreData : NSManagedObject

@property (nonatomic, retain) NSData * dataImage;
@property (nonatomic, retain) NSString * descriptionString;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * imageString;
@property (nonatomic, retain) NSNumber * is_followed;
@property (nonatomic, retain) NSNumber * nb_followers;
@property (nonatomic, retain) NSNumber * nb_follows;
@property (nonatomic, retain) NSString * nom;
@property (nonatomic, retain) NSString * numeroMobile;
@property (nonatomic, retain) NSString * prenom;
@property (nonatomic, retain) NSString * secondEmail;
@property (nonatomic, retain) NSString * secondPhone;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * privacy;
@property (nonatomic, retain) NSNumber * request_follower;
@property (nonatomic, retain) NSNumber * request_follow_me;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *moments;
@end

@interface UserCoreData (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(ChatMessageCoreData *)value;
- (void)removeMessagesObject:(ChatMessageCoreData *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addMomentsObject:(MomentCoreData *)value;
- (void)removeMomentsObject:(MomentCoreData *)value;
- (void)addMoments:(NSSet *)values;
- (void)removeMoments:(NSSet *)values;

@end
