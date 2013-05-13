//
//  Place.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Place.h"
#import "AFNetworking.h"
#import "Config.h"
#import "AFMomentAPIClient.h"

@implementation Place

#pragma mark - HTTP Client

static AFHTTPClient *_httpClient = nil;
static NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/autocomplete";

+ (AFHTTPClient*)httpClient {
    if(!_httpClient) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];;
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [_httpClient setDefaultHeader:@"Accept" value:@"application/json"];
        
        // Ne pas ajouter le '/' à la fin de l'url
    }
    return _httpClient;
}

#pragma mark - Init

- (id)initWithAttributes:(NSDictionary*)attributes
{
    self = [super init];
    if(self) {
        
        self.placeId = attributes[@"id"];
        self.adresse = attributes[@"description"];
        NSArray *terms = attributes[@"terms"];
        if(terms) {
            
            short int count = [terms count];
            if( (count >= 2) && terms[1] && terms[1][@"value"])
                self.titre = terms[1][@"value"];
            else if( (count > 0) && terms[0] && terms[0][@"value"] )
                self.titre = terms[0][@"value"];
            
        }
        
    }
    return self;
}

#pragma mark - Request

+ (void)autocompletionForQuery:(NSString*)query withEnded:(void (^) (NSArray *results))block
{
    if(block)
    {
    
        NSDictionary *params = @{@"input":query,
                                 @"sensor":@"true",
                                 @"key":kGoogleAPIKey};
        
        [[self httpClient] getPath:@"json" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            // Status
            NSString *status = JSON[@"status"];
            
            // Success
            if([status isEqualToString:@"OK"]) {
                
                // Results
                NSArray *predictions = JSON[@"predictions"];
                NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[predictions count]];
                
                for(NSDictionary *attr in predictions) {
                    Place *p = [[Place alloc] initWithAttributes:attr];
                    if(p)
                        [results addObject:p];
                }
                
                block(results);
                
            }
            // No Results
            else if([status isEqualToString:@"ZERO_RESULTS"]) {
                block(@[]);
            }
            // Fail
            else if([status isEqualToString:@"INVALID_REQUEST"] || [status isEqualToString:@"REQUEST_DENIED"]) {
                block(nil);
            }
            // Quota dépassé
            else if([status isEqualToString:@"OVER_QUERY_LIMIT"]) {
                // Prévenir server
                [TestFlight passCheckpoint:@"Google Place - Quota dépassé"];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            HTTP_ERROR(operation, error);
            block(nil);
            
        }];
    
    }

}

@end
