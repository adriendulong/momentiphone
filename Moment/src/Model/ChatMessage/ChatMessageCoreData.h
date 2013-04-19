//
//  ChatMessageCoreData.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 11/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserCoreData;

@interface ChatMessageCoreData : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) UserCoreData *user;

@end
