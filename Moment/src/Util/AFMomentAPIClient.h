//
//  AFMomentAPIClient.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

// Gestion Erreur HTTP
#define HTTP_ERROR(operation, error) \
{ \
TFLog(@"[Line %d]", __LINE__ ); \
TFLog(@"%s\nFAIL status %d", __PRETTY_FUNCTION__, operation.response.statusCode); \
TFLog(@"Error : %@", error.localizedDescription); \
TFLog(@"Reponse = %@", operation.responseString); \
}

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@interface AFMomentAPIClient : AFHTTPClient

// --- Singleton ---
+ (AFMomentAPIClient*)sharedClient;

// --- Cookies ---
- (void)saveHeaderResponse:(NSHTTPURLResponse*)response;
- (void)checkConnexionCookieWithEnded:(void (^) (void))block;
- (void)clearConnexionCookie;

// --- Requests ---
// Generic
- (void)request:(NSString*)methode
           path:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished;

// GET
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished;

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// POST
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
        encoding:(AFHTTPClientParameterEncoding)parameterEnconding
         success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished;

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
        encoding:(AFHTTPClientParameterEncoding)parameterEnconding
         success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
