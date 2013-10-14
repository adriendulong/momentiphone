//
//  ChatMessageCoreData+Model.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatMessageCoreData.h"
#import "ChatMessage.h"

#define CHAT_MESSAGES_NO_LIMIT -1

@interface ChatMessageCoreData (Model)

// Persist
+ (void)insertWithMemoryReleaseNewMessage:(ChatMessage*)message;
+ (ChatMessage*)newMessageWithText:(NSString*)text withDate:(NSDate*)date withUser:(UserClass*)user withId:(NSNumber*)messageId;
+ (ChatMessage*)newMessageWithText:(NSString*)text;
+ (ChatMessage*)newMessageWithAttributesFromWeb:(NSDictionary*)attributes;
+ (NSArray*)newMessagesWithArrayFromWeb:(NSArray*)array;;

// Request
- (ChatMessage*)localCopy;
+ (NSArray*)localCopyOfArray:(NSArray*)stored;
+ (NSArray*)getMessagesWithLimit:(NSInteger)limit;
+ (NSArray*)getLastMessages;

// Release
+ (void)releaseMessagesAfterIndex:(NSInteger)max;
+ (void)resetChatMessagesLocal;

@end
