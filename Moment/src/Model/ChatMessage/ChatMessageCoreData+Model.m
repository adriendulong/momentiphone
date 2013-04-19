//
//  ChatMessageCoreData+Model.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatMessageCoreData+Model.h"
#import "Config.h"
#import "UserCoreData+Model.h"
#import "NSDate+NSDateAdditions.h"

#define NB_MESSAGES_STORED 20

@implementation ChatMessageCoreData (Model)

#pragma Persist

+ (void)insertMessage:(ChatMessage*)message
{
    ChatMessageCoreData* storedMessage = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessageCoreData" inManagedObjectContext:[Config sharedInstance].managedObjectContext];
    
    storedMessage.message = message.message;
    storedMessage.date = message.date;
    storedMessage.user = [UserCoreData requestUserAsCoreDataWithUser:message.user];
    storedMessage.messageId = message.messageId;
    
    [[Config sharedInstance] saveContext];
}

+ (void)insertWithMemoryReleaseNewMessage:(ChatMessage*)message {
    // Store new message
    [self insertMessage:message];

    // Release old message if needed
    [self releaseMessagesAfterIndex:NB_MESSAGES_STORED];
}

+ (ChatMessage*)newMessageWithText:(NSString*)text withDate:(NSDate*)date withUser:(UserClass*)user withId:(NSNumber*)messageId
{
    // Allocation
    ChatMessage *message = [[ChatMessage alloc] initWithText:text withDate:date withUser:user withId:messageId];
    
    // Automatic Insert
    [self insertWithMemoryReleaseNewMessage:message];
    
    return message;
}

+ (ChatMessage*)newMessageWithText:(NSString*)text
{
    // Allocation
    ChatMessage *message = [[ChatMessage alloc] initWithText:text];
    
    // Automatic Insert
    [self insertWithMemoryReleaseNewMessage:message];
    
    return message;
}

+ (ChatMessage*)newMessageWithAttributesFromWeb:(NSDictionary*)attributes
{
    // Allocation
    ChatMessage *message = [[ChatMessage alloc] initWithAttributesFromWeb:attributes];
    
    // Automatic Insert
    [self insertWithMemoryReleaseNewMessage:message];
    
    return message;
}

+ (NSArray*)newMessagesWithArrayFromWeb:(NSArray*)array
{
    if([array count] > 0) {
        NSArray *localArray = [ChatMessage arrayWithArrayFromWeb:array];
        ChatMessage *lastLocal = localArray[0];
        ChatMessageCoreData *lastStored = [self getLastMessageAsCoreData];
        
        // Persist if needed
        if( [lastLocal.date isLaterThan:lastStored.date] ) {
            
            for(ChatMessage* message in localArray) {
#warning A améliorer
                [self insertWithMemoryReleaseNewMessage:message];
            }
            
        }
        
        return localArray;
    }
    return array;
}

#pragma mark - Get Messages

- (ChatMessage*)localCopy {
    return [[ChatMessage alloc] initWithText:self.message withDate:self.date withUser:[self.user localCopy] withId:self.messageId];
}

+ (NSArray*)localCopyOfArray:(NSArray*)stored {
    if(stored) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[stored count]];
        for( ChatMessageCoreData* data in stored ) {
            [array addObject:[data localCopy]];
        }
        return array;
    }
    return nil;
}

+ (NSInteger)count {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessageCoreData"];
    [request setIncludesSubentities:NO];
    
    NSError *error = NULL;
    NSInteger count = [[Config sharedInstance].managedObjectContext countForFetchRequest:request error:&error];
    
    if(error || (count == NSNotFound) ) {
        NSLog(@"Error Count Messages : %@", error.localizedDescription);
        abort();
    }
    
    return count;
}

+ (NSArray*)getMessagesAsCoreDataWithLimit:(NSInteger)limit {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessageCoreData"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    request.sortDescriptors = @[sort];
    if(limit > 0)
        request.fetchLimit = limit;
    
    NSError *error = nil;
    NSArray *matches = [[Config sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    //NSLog(@"Local moments = %@", matches);
    
    if( !matches )
    {
        NSLog(@"Error GetMessages : %@", error.localizedDescription);
        abort();
    }
    else {
        //NSLog(@"matches = %@", matches);
        return matches;
    }
        
    
    return nil;
}

+ (ChatMessageCoreData*)getLastMessageAsCoreData {
    NSArray* array = [self getMessagesAsCoreDataWithLimit:1];
    if(array && [array count] > 0)
        return array[0];
    return nil;
}

+ (NSArray*)getMessagesWithLimit:(NSInteger)limit
{
    return [self localCopyOfArray:[self getMessagesAsCoreDataWithLimit:limit]];
}

+ (NSArray*)getLastMessages {
    return [self getMessagesWithLimit:NB_MESSAGES_STORED];
}

#pragma mark - Release

+ (void)releaseMessagesAfterIndex:(NSInteger)max
{
    NSArray *messages = [self getMessagesAsCoreDataWithLimit:CHAT_MESSAGES_NO_LIMIT];
    
    int taille = [messages count];
    for(int i=0; i<taille ; i++) {
        if(i >= max) {
            NSLog(@"delete message = %@", [messages[i] message]);
            [[Config sharedInstance].managedObjectContext deleteObject:messages[i]];
        }
        i++;
    }
    
    [[Config sharedInstance] saveContext];
}

+ (void)resetChatMessagesLocal {
    [self releaseMessagesAfterIndex:0];
}

@end
