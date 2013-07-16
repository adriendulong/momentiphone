//
//  CagnotteProduct.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 11/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CagnotteProduct.h"
#import "AFNetworking.h"
#import "AFMomentAPIClient.h"
#import "Config.h"

@implementation CagnotteProduct

@synthesize googleId = _googleId;
@synthesize title = _title;
@synthesize descriptionString = _descriptionString;
@synthesize authorName = _authorName;
@synthesize imageURL = _imageURL;
@synthesize image = _image;
@synthesize link = _link;
@synthesize price = _price;
@synthesize currency = _currency;

#pragma mark - HTTP Client

static AFHTTPClient *_httpClient = nil;
static NSString *baseURL = @"https://www.googleapis.com/shopping/search/v1/public/";

+ (AFHTTPClient*)httpClient {
    if(!_httpClient) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];;
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [_httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    }
    return _httpClient;
}

#pragma mark - Init

- (id)initWithAttributesFromWeb:(NSDictionary*)attributes
{
    if(attributes)
    {
        self = [super init];
        if(self) {
            
            attributes = attributes[@"product"];
            if(attributes)
            {
                if(attributes[@"googleId"])
                    self.googleId = attributes[@"googleId"];
                
                if(attributes[@"author"] && attributes[@"author"][@"name"]) {
                    self.authorName = attributes[@"author"][@"name"];
                }
                if(attributes[@"link"]) {
                    self.link = attributes[@"link"];
                }
                if(attributes[@"title"]) {
                    self.title = attributes[@"title"];
                }
                if(attributes[@"images"] && ([attributes[@"images"] count] > 0) && attributes[@"images"][0][@"link"]) {
                    self.imageURL = attributes[@"images"][0][@"link"];
                }
                if([attributes[@"inventories"] count] > 0) {
                    
                    NSDictionary *inventory = attributes[@"inventories"][0];
                    
                    if(inventory)
                    {
                        if(inventory[@"price"])
                            self.price = [inventory[@"price"] floatValue];
                        if(inventory[@"currency"])
                            self.currency = [CagnotteProduct formatedCurrency:inventory[@"currency"]];
                    }
                    
                }
                if(attributes[@"description"]) {
                    self.descriptionString = attributes[@"description"];
                }
            }

        }
        return self;
    }
    
    return nil;
}

+ (NSArray*)arrayWithArrayOfAttributesFromWeb:(NSArray*)array
{
    NSMutableArray *products = [[NSMutableArray alloc] init];
    for(NSDictionary *attr in array) {
        CagnotteProduct *p = [[CagnotteProduct alloc] initWithAttributesFromWeb:attr];
        if(p)
            [products addObject:p];
    }
    return products;
}

#pragma mark - Search

+ (void)searchForQuery:(NSString*)query
          withStartIndex:(NSInteger)startIndex
             withEnded:(void (^) (NSDictionary* results))block
{
    NSString *path = @"products";
    
    //NSLog(@"LOAD INDEX %d", startIndex);
    
    // Query
    NSDictionary *params = @{
                             @"key":kGoogleAPIKey,
                             @"country":[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode],
                             @"q":query,
                             @"startIndex":@((startIndex > 0)? startIndex : 1)//,
                             //@"spelling.enabled":@"true" // Enable Spell Ckecking and Spell Suggestion
                             };
    
    [[self httpClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if(block && JSON)
        {
            NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
            
            // Récupération de la liste des produits
            NSArray *products = [self arrayWithArrayOfAttributesFromWeb:JSON[@"items"]];
            if(products) {
                results[@"products"] = products;
                
                // Suggestion d'orthographe
                /*
                if(JSON[@"spelling"] && JSON[@"spelling"][@"suggestion"]) {
                    results[@"suggestion"] = JSON[@"spelling"][@"suggestion"];
                }
                 */
                
                // Next Page
                NSInteger nextIndex = startIndex + [products count];
                NSInteger total = [JSON[@"totalItems"] intValue];
                if(nextIndex < total) {
                    results[@"startIndex"] = @(nextIndex);
                }
                else
                    results[@"startIndex"] = @(-1);
                
                block(results);

            }
            
            block(nil);
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
        HTTP_ERROR(operation, error);

        if(block) {
            block(nil);
        }
     
    }];
}

+ (NSString*)formatedCurrency:(NSString*)currency
{
    if([currency isEqualToString:@"EUR"])
        return @"€";
    return currency;
}

@end
