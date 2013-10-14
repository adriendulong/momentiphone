//
//  Place.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (nonatomic, strong) NSString *adresse;
@property (nonatomic, strong) NSString *titre;
@property (nonatomic, strong) NSString *placeId;

- (id)initWithAttributes:(NSDictionary*)attributes;

+ (void)autocompletionForQuery:(NSString*)query withEnded:(void (^) (NSArray *results))block;

@end
