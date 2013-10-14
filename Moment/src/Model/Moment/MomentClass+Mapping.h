//
//  MomentClass+Mapping.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "MomentClass.h"

@interface MomentClass (Mapping)

+ (NSDictionary*) mappingToLocalWithAttributes:(NSDictionary*)attributes;
+ (NSDictionary *) mappingToWebWithAttributes:(NSDictionary*)attributes;
- (NSDictionary *) mappingToWeb;

@end
