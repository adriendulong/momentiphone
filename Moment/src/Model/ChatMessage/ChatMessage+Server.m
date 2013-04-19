//
//  ChatMessage+Server.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatMessage.h"
#import "ChatMessage+Server.h"
#import "AFMomentAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "ChatMessageCoreData+Model.h"

@implementation ChatMessage (Server)

#pragma mark - Get Message

+ (void)getMessagesForMoment:(MomentClass*)moment atPage:(NSInteger)page withEnded:( void (^) (NSDictionary* attributes) )block
{
    NSString *path = [NSString stringWithFormat:@"lastchats/%d/%d", moment.momentId.intValue, page];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
                
        NSArray *messages = (NSArray*)JSON[@"chats"];
        //NSLog(@"messages = %@", messages);
        NSNumber *nextPage = JSON[@"next_page"];
        //NSLog(@"next page = %@", nextPage);
        
        NSDictionary *attributes = @{
                                     @"chats":[ChatMessageCoreData newMessagesWithArrayFromWeb:messages],
                                     @"next_page": nextPage ?: @(page)
                                     };
        
        //NSLog(@"attributs locals : %@", attributes);
        
        if(block) {
            block(attributes);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(@{@"chats":[ChatMessageCoreData getLastMessages],
                  @"next_page":@(1),
                  @"failure":@(YES)});
    }];
    
}

+ (void)getMessageWithId:(NSInteger)messageId withEnded:(void (^) (ChatMessage* message))block
{
    NSString *path = [NSString stringWithFormat:@"chat/%d", messageId];
    
    [[AFMomentAPIClient sharedClient] getPath:path parameters:nil encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(block) {
            ChatMessage *message = [[ChatMessage alloc] initWithAttributesFromWeb:JSON[@"chat"]];
            block(message);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
    }];
    
}

+ (void)sendNewMessageForMoment:(MomentClass*)moment withText:(NSString*)texte withEnded:( void (^) (ChatMessage* message) )block
{
    NSString *path = [NSString stringWithFormat:@"newchat/%d", moment.momentId.intValue];
    
    NSDictionary *params = @{@"message":texte};
    
    [[AFMomentAPIClient sharedClient] postPath:path parameters:params encoding:AFFormURLParameterEncoding success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        //NSLog(@"reponse = %@", operation.responseString);
        
        // Alloc and persist in CoreData
        ChatMessage* message = [ChatMessageCoreData newMessageWithText:texte];
        
        if(block) {
            block(message);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HTTP_ERROR(operation, error);
        
        if(block)
            block(nil);
    }];
    
}

@end
