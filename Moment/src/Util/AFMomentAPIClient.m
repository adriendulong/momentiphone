//
//  AFMomentAPIClient.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "AFMomentAPIClient.h"

#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"

//@"http://ec2-54-228-139-53.eu-west-1.compute.amazonaws.com";
//@"http://api.appmoment.fr/";
//@"http://92.146.87.91:5000";
//@"http://apitest.appmoment.fr";
static NSString * const kAFBaseURLString = @"http://api.appmoment.fr";
static NSString * const kAFLastHeaderResponse = @"lastHeaderResponse";

@implementation AFMomentAPIClient

#pragma mark - Singleton

+ (AFMomentAPIClient *)sharedClient {
    static AFMomentAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFMomentAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFBaseURLString]];
    });
    
    return _sharedClient;
}

#pragma mark - Init

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    //Authentification basique
    //[self setAuthorizationHeaderWithUsername:@"api" password:@"api"];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    //Gestion de l'authentification
    //[self setDefaultHeader:@"Authorization" value:@"WSSE profile=\"UsernameToken\""];
    
    return self;
}

#pragma mark - Cookies

- (void)saveHeaderResponse:(NSHTTPURLResponse*)response {
    [[NSUserDefaults standardUserDefaults] setObject:response.allHeaderFields forKey:kAFLastHeaderResponse];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkConnexionCookieWithEnded:(void (^) (void))block
{
    // Récupération header stocké
    NSDictionary *header = [[NSUserDefaults standardUserDefaults] objectForKey:kAFLastHeaderResponse];
    if(header) {
        NSHTTPCookie *cookie = [NSHTTPCookie cookiesWithResponseHeaderFields:header forURL:[AFMomentAPIClient sharedClient].baseURL ][0];
        
        //NSLog(@"Last cookie = %@", cookie);
        
        // Enregistrement du cookie
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        
        if(block)
            block(); //[self entrerDansMomentAnimated:NO];
    }
}

- (void)clearConnexionCookie {
    
    // Suppression du cookie
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        //NSLog(@"cookie - %@ - %@ - %@ - %@ - deleted", cookie.name, cookie.path, cookie.comment, cookie.expiresDate );
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    // Suppression du header enregistré
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAFLastHeaderResponse];
}

#pragma mark - Requests

// Generic

- (void)request:(NSString*)methode
           path:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    
    [self setParameterEncoding:parameterEnconding];
    
    NSURLRequest *request = [self requestWithMethod:methode path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
    
        // Save Automatic Connexion cookie
        [self saveHeaderResponse:operation.response];
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        if(success) {
            success(operation, JSON);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        if(failure) {
            failure(operation, error);
        }
        
    }];
    
    [self enqueueHTTPRequestOperation:operation];
    
    if(waitUntilFinished)
        [operation waitUntilFinished];

}

// GET

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished
{
    [self request:@"GET"
             path:path
       parameters:parameters
         encoding:parameterEnconding
          success:success
          failure:failure
waitUntilFinisehd:waitUntilFinished];
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self request:@"GET"
             path:path
       parameters:parameters
         encoding:parameterEnconding
          success:success
          failure:failure
waitUntilFinisehd:NO];
}

// POST

- (void)postPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished
{
    [self request:@"POST"
             path:path
       parameters:parameters
         encoding:parameterEnconding
          success:success
          failure:failure
waitUntilFinisehd:waitUntilFinished];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
        encoding:(AFHTTPClientParameterEncoding)parameterEnconding
         success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self request:@"POST"
             path:path
       parameters:parameters
         encoding:parameterEnconding
          success:success
          failure:failure
waitUntilFinisehd:NO];
}


@end
