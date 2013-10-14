//
//  FacebookTokenCachingStrategy.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 07/06/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

@interface FacebookTokenCachingStrategy : FBSessionTokenCachingStrategy
@property (nonatomic, strong) NSString *tokenFilePath;
- (NSString *) filePath;
@end
