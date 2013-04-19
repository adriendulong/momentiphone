//
//  AddressBookManager.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookManager : NSObject

+ (void)accesAddressBookListWithCompletionHandler:(void (^) (NSArray* list))block;

@end
