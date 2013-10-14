//
//  ChatMessage+Server.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatMessage.h"
#import "MomentClass.h"

@interface ChatMessage (Server)

// Get Message
+ (void)getMessagesForMoment:(MomentClass*)moment atPage:(NSInteger)page withEnded:( void (^) (NSDictionary* attributes) )block;
+ (void)getMessageWithId:(NSInteger)messageId withEnded:(void (^) (ChatMessage* message))block;

// Send Message
+ (void)sendNewMessageForMoment:(MomentClass*)moment withText:(NSString*)texte withEnded:( void (^) (ChatMessage* message) )block;

@end
