//
//  TextFieldAutocompletionManager.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTAutocompleteTextField.h"

typedef enum {
    TextFieldAutocompletionTypeEmail = 1<<8,
    TextFieldAutocompletionTypeEmailFavoris = 1<<7,
    TextFieldAutocompletionTypeHashtag = 1<<6,
} TextFieldAutocompletionType;

@interface TextFieldAutocompletionManager : NSObject <HTAutocompleteDataSource>

@property (nonatomic, strong) NSURL *favoriteEmailsFileLocation;
@property (nonatomic, strong) NSURL *documentDirectory;
@property (nonatomic, strong) NSArray *favoriteEmails;

+ (TextFieldAutocompletionManager*)sharedInstance;
- (void)addEmailToFavoriteEmails:(NSString*)email;
- (void)clearFavoriteEmails;

@end
