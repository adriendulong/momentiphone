//
//  ChatMessage.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 16/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserClass.h"

@interface ChatMessage : NSObject

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) UserClass *user;
@property (nonatomic, strong) NSNumber *messageId;

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes;
- (id)initWithText:(NSString*)text withDate:(NSDate*)date withUser:(UserClass*)user withId:(NSNumber*)messageId;
- (id)initWithText:(NSString*)text;

+ (NSArray*)arrayWithArrayFromWeb:(NSArray*)array;

@end
