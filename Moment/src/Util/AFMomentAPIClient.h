//
//  AFMomentAPIClient.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 10/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

/*
 * Client HTTP
 *  -> Toutes les requêtes vers le server utilisent cette classe
 *  -> Conversion automatique des réponses du server (NSArray ou NSDictionnary)
 */

// Gestion Erreur HTTP
#define HTTP_ERROR(operation, error) \
{ \
TFLog(@"[Line %d]", __LINE__ ); \
TFLog(@"%s\nFAIL status %d", __PRETTY_FUNCTION__, operation.response.statusCode); \
TFLog(@"Error : %@", error.localizedDescription); \
TFLog(@"Reponse = %@", operation.responseString); \
[TestFlight passCheckpoint:[NSString stringWithFormat:@"HTTP_ERROR : %s", __PRETTY_FUNCTION__]]; \
}

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@interface AFMomentAPIClient : AFHTTPClient

// --- Singleton ---
+ (AFMomentAPIClient*)sharedClient;

// --- Cookies ---
//  -> Méthode d'authentification : stocke le cookie renvoyé depuis le server à chaque requête
//  -> Envoi le cookie automatiquement pour chaque nouvelle requête
// ---------------
- (void)saveHeaderResponse:(NSHTTPURLResponse*)response;
- (void)checkConnexionCookieWithEnded:(void (^) (void))block;
- (void)clearConnexionCookie;

// --- Requests ---
// Generic
// -> Params
//      - methode : méthode HTTP utilisée lors de la requête
//      - path : url visée
//      - parameters : paramètres de la requête
//      - encoding : Type d'encodage de la requête
//                      AFFormURLParameterEncoding pour les paramètres simples
//                      AFJSONParameterEncoding pour les paramètres complexes
//      - success : block effectué en cas de réussite de la requête
//      - failure : block effectué en cas d'echec de la requête
//      - waitUntilFinished : Requête synchrone ou asynchrone
- (void)request:(NSString*)methode
           path:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished;

// ------------------------ GET -----------------------
// -> Méthode = GET
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished;

// -> waitUntilFinished = NO
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
       encoding:(AFHTTPClientParameterEncoding)parameterEnconding
        success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// ----------------------- POST ------------------------
// -> Méthode = POST
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
        encoding:(AFHTTPClientParameterEncoding)parameterEnconding
         success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
waitUntilFinisehd:(BOOL)waitUntilFinished;

// -> waitUntilFinished = NO
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
        encoding:(AFHTTPClientParameterEncoding)parameterEnconding
         success:(void (^)(AFHTTPRequestOperation *operation, id JSON))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
