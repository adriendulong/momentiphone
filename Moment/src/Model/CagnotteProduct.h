//
//  CagnotteProduct.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 11/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CagnotteProduct : NSObject

@property (nonatomic, strong) NSString *googleId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic) CGFloat price;
@property (nonatomic, strong) NSString *authorName;

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes;
+ (NSArray*)arrayWithArrayOfAttributesFromWeb:(NSArray*)array;

+ (void)searchForQuery:(NSString*)query
        withStartIndex:(NSInteger)startIndex
             withEnded:(void (^) (NSDictionary* results))block;

@end
