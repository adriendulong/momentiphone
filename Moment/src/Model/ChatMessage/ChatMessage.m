//
//  ChatMessage.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 16/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatMessage.h"
#import "UserCoreData+Model.h"
#import "UserClass+Mapping.h"

@implementation ChatMessage

@synthesize message = _message;
@synthesize date = _date;
@synthesize user = _user;
@synthesize messageId = _messageId;

- (void)setupWithAttributes:(NSDictionary*)attributes {
    self.message = attributes[@"message"];
    self.date = [NSDate dateWithTimeIntervalSince1970:[attributes[@"time"] doubleValue]];
    self.user = [[UserClass alloc] initWithAttributesFromLocal:attributes[@"user"]];
    self.messageId = attributes[@"messageId"];
}

- (id)initWithText:(NSString*)text withDate:(NSDate*)date withUser:(UserClass*)user withId:(NSNumber*)messageId
{
    self = [super init];
    if(self) {
        self.message = text;
        self.date = date;
        self.user = user;
        self.messageId = messageId;
    }
    return self;
}

- (id)initWithText:(NSString*)text {
    return [self initWithText:text withDate:[NSDate date] withUser:[UserCoreData getCurrentUser] withId:nil];
}

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes
{
    self = [super init];
    if(self) {
        
        NSMutableDictionary *dico = [[NSMutableDictionary alloc] init];
        dico[@"message"] = attributes[@"message"];
        dico[@"time"] = attributes[@"time"];
        dico[@"user"] = [UserClass mappingToLocalAttributes:attributes[@"user"]];
        if(attributes[@"id"])
            dico[@"messageId"] = attributes[@"id"];
        
        [self setupWithAttributes:dico];
    }
    return self;
}

+ (NSArray*)arrayWithArrayFromWeb:(NSArray*)array
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for( NSDictionary* attributes in array ) {
        [newArray addObject:[[ChatMessage alloc] initWithAttributesFromWeb:attributes]];
    }
/*
#warning Peut etre inutil
    [newArray sortUsingComparator:^NSComparisonResult(ChatMessage* obj1, ChatMessage* obj2) {
        return [obj1.date compare:obj2.date];
    }];
    */
    /*
    for( ChatMessage* message in newArray )
        NSLog(@"messages = \n message = \"%@\"\n date = %@\n user = %@", message.message, message.date, message.user);
    */
    return newArray;
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[self class]]) {
        ChatMessage *m = (ChatMessage*)object;
        
        // Si il y a une ID
        if(m.messageId && [object messageId] ) {
            BOOL result = [self.messageId isEqualToNumber:m.messageId];
            return result;
        }
    }
    return NO;
}

#pragma mark - Debug

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ - \n message = \"%@\"\n date = %@\n user = %@", [super description], self.message, self.date, self.user ];
}

@end
