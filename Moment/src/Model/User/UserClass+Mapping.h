//
//  UserClass+Mapping.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UserClass.h"

@interface UserClass (Mapping)

+ (NSDictionary *) mappingToLocalAttributes:(NSDictionary*)attributes;
+ (NSDictionary*) mappingToWebWithAttributes:(NSDictionary*)attributes;
+ (NSArray*) mappingArrayToLocalAttributes:(NSArray*)array;
- (NSDictionary*) mappingToWeb;

@end
