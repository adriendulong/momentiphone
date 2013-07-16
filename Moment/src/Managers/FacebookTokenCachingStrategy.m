//
//  FacebookTokenCachingStrategy.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "FacebookTokenCachingStrategy.h"

// Local cache - unique file info
static NSString* kFBTokenInfoStorageFile = @"FBTokenInfo.plist";

@implementation FacebookTokenCachingStrategy

- (id)init
{
    self = [super init];
    if (self) {
        _tokenFilePath = [self filePath];
    }
    return self;
}

#pragma mark - IO

- (NSString *) filePath {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return [documentsDirectory stringByAppendingPathComponent:kFBTokenInfoStorageFile];
}

- (void) writeData:(NSDictionary *) data {
    //NSLog(@"File = %@ and Data = %@", self.tokenFilePath, data);
    /*
    BOOL success = [data writeToFile:self.tokenFilePath atomically:YES];
    if (!success) {
        NSLog(@"Error writing to file");
    }
    */
     
    [data writeToFile:self.tokenFilePath atomically:YES];
}

- (NSDictionary *) readData {
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:self.tokenFilePath];
    //NSLog(@"File = %@ and data = %@", self.tokenFilePath, data);
    return data;
}

#pragma mark - FBSessionTokenCachingStrategy

- (void)cacheFBAccessTokenData:(FBAccessTokenData *)accessToken {
    NSDictionary *tokenInformation = [accessToken dictionary];
    [self writeData:tokenInformation];
}

- (FBAccessTokenData *)fetchFBAccessTokenData
{
    NSDictionary *tokenInformation = [self readData];
    if (nil == tokenInformation) {
        return nil;
    } else {
        return [FBAccessTokenData createTokenFromDictionary:tokenInformation];
    }
}

- (void)clearToken
{
    [self writeData:[NSDictionary dictionaryWithObjectsAndKeys:nil]];
}

@end
