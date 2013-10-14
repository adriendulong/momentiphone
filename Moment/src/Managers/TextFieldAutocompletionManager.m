//
//  TextFieldAutocompletionManager.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//
//  Inspired From HTAutocompleteManager.m
//  HotelTonight by Jonathan Sibley on 12/6/12.
//

#import "TextFieldAutocompletionManager.h"
#import "HTAutocompleteTextField.h"

static TextFieldAutocompletionManager *sharedManager = nil;

@implementation TextFieldAutocompletionManager

@synthesize favoriteEmailsFileLocation = _favoriteEmailsFileLocation;
@synthesize documentDirectory = _documentDirectory;
@synthesize favoriteEmails = _favoriteEmails;

+ (TextFieldAutocompletionManager*)sharedInstance {
    
    if(!sharedManager) {
        static dispatch_once_t done;
        dispatch_once(&done, ^{
            sharedManager = [[TextFieldAutocompletionManager alloc] init];
        });
    }
	return sharedManager;
}

#pragma mark - Preferences loading

- (void)addEmailToFavoriteEmails:(NSString*)email
{
    if(email)
    {
        NSArray *emails = [self favoriteEmails];
        
        if( ![emails containsObject:email] ) {
            NSMutableArray *newArray = [NSMutableArray arrayWithObject:email];
            
            if(emails && ([emails count] > 0) ) {
                [newArray addObjectsFromArray:emails];
                self.favoriteEmails = emails;
            }
            
            [newArray writeToURL:self.favoriteEmailsFileLocation atomically:YES];
        }
    }
}

- (void)clearFavoriteEmails
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.favoriteEmailsFileLocation error:&error];
    if(error) {
        NSLog(@"Error : fail to remove favorite emails file :\n%@", error.localizedDescription);
    }
}

- (NSArray*)defaultEmails
{
    NSURL *url = [NSURL URLWithString:@"defaultEmails" relativeToURL:self.documentDirectory];
    NSArray *loaded = [NSArray arrayWithContentsOfURL:url];
    
    if(!loaded) {
        loaded = @[@"gmail.com", @"yahoo.com", @"hotmail.com", @"hotmail.fr", @"msn.com", @"msn.fr", @"aol.com", @"comcast.net", @"ece.fr", @"me.com", @"msn.com", @"live.com", @"sbcglobal.net", @"ymail.com", @"att.net", @"mac.com", @"cox.net", @"verizon.net", @"hotmail.co.uk", @"bellsouth.net", @"rocketmail.com", @"aim.com", @"yahoo.co.uk", @"earthlink.net", @"charter.net", @"optonline.net", @"shaw.ca", @"yahoo.ca", @"googlemail.com", @"mail.com", @"qq.com", @"btinternet.com", @"mail.ru", @"live.co.uk",
            @"naver.com", @"rogers.com", @"juno.com", @"yahoo.com.tw", @"live.ca", @"walla.com", @"163.com", @"roadrunner.com",
            @"telus.net", @"embarqmail.com", @"hotmail.fr", @"pacbell.net", @"sky.com", @"sympatico.ca", @"cfl.rr.com",
            @"tampabay.rr.com", @"q.com", @"yahoo.co.in", @"yahoo.fr", @"hotmail.ca", @"windstream.net", @"hotmail.it",
            @"web.de", @"asu.edu", @"gmx.de", @"gmx.com", @"insightbb.com", @"netscape.net", @"icloud.com", @"frontier.com",
            @"126.com", @"hanmail.net", @"suddenlink.net", @"netzero.net", @"mindspring.com", @"ail.com", @"windowslive.com",
            @"netzero.com", @"yahoo.co", @"email.com", @"yahoo.com.hk", @"yandex.ru", @"mchsi.com", @"cableone.net",
            @"yahoo.com.cn", @"yahoo.es", @"yahoo.com.br", @"cornell.edu", @"ucla.edu", @"us.army.mil", @"excite.com",
            @"ntlworld.com", @"usc.edu", @"nate.com", @"outlook.com", @"nc.rr.com", @"prodigy.net", @"wi.rr.com",
            @"videotron.ca", @"yahoo.it", @"yahoo.com.au", @"umich.edu", @"ameritech.net", @"libero.it", @"yahoo.de",
            @"rochester.rr.com", @"cs.com", @"frontiernet.net", @"swbell.net", @"msu.edu", @"ptd.net", @"proxymail.facebook.com",
            @"hotmail.es", @"austin.rr.com", @"nyu.edu", @"sina.com", @"centurytel.net", @"usa.net", @"nycap.rr.com",
            @"uci.edu", @"hotmail.de", @"yahoo.com.sg", @"gmai.com", @"email.arizona.edu", @"yahoo.com.mx", @"ufl.edu",
            @"bigpond.com", @"unlv.nevada.edu", @"yahoo.cn", @"ca.rr.com", @"google.com", @"yahoo.co.id", @"inbox.com",
            @"fuse.net", @"hawaii.rr.com", @"talktalk.net", @"gmx.net", @"walla.co.il", @"ucdavis.edu", @"carolina.rr.com",
            @"comcast.com", @"gmsil.com", @"live.fr", @"blueyonder.co.uk", @"live.cn", @"hitmail.com", @"cogeco.ca",
            @"abv.bg", @"tds.net", @"centurylink.net", @"yahoo.com.vn", @"uol.com.br", @"osu.edu", @"san.rr.com",
            @"rcn.com", @"umn.edu", @"live.nl", @"live.com.au", @"tx.rr.com", @"eircom.net", @"sasktel.net", @"post.harvard.edu",
            @"snet.net", @"wowway.com", @"live.it", @"hoteltonight.com", @"att.com", @"yaho.com", @"vt.edu", @"rambler.ru",
            @"temple.edu", @"cinci.rr.com"];
        [loaded writeToURL:url atomically:YES];
    }
    
    return loaded;
}

#pragma mark - HTAutocompleteTextFieldDelegate

- (NSString *)textField:(HTAutocompleteTextField *)textField
    completionForPrefix:(NSString *)prefix
             ignoreCase:(BOOL)ignoreCase
{
    if (textField.autocompleteType&TextFieldAutocompletionTypeEmail)
    {
        static dispatch_once_t onceToken;
        static NSArray *autocompleteArray;
        
        dispatch_once(&onceToken, ^
                      {
                          autocompleteArray = [self defaultEmails];
                      });
        
        
        if(textField.autocompleteType&TextFieldAutocompletionTypeEmailFavoris)
        {
            // Si un email favoris est rentré
            if([prefix length] > 2) {
                NSRange emailRange;
                for(NSString *email in [self favoriteEmails]) {
                    emailRange = [email rangeOfString:prefix];
                    if(emailRange.location != NSNotFound) {
                        return [email stringByReplacingCharactersInRange:emailRange withString:@""];
                    }
                }
            }
        }
        
        // Check that text field contains an @
        NSRange atSignRange = [prefix rangeOfString:@"@"];
        if (atSignRange.location == NSNotFound)
        {
            return @"";
        }
        
        // Stop autocomplete if user types dot after domain
        NSString *domainAndTLD = [prefix substringFromIndex:atSignRange.location];
        NSRange rangeOfDot = [domainAndTLD rangeOfString:@"."];
        if (rangeOfDot.location != NSNotFound)
        {
            return @"";
        }
        
        // Check that there aren't two @-signs
        NSArray *textComponents = [prefix componentsSeparatedByString:@"@"];
        if ([textComponents count] > 2)
        {
            return @"";
        }
        
        if ([textComponents count] > 1)
        {
            // If no domain is entered, use the first domain in the list
            if ([(NSString *)textComponents[1] length] == 0)
            {
                return [autocompleteArray objectAtIndex:0];
            }
            
            NSString *textAfterAtSign = textComponents[1];
            
            NSString *stringToLookFor;
            if (ignoreCase)
            {
                stringToLookFor = [textAfterAtSign lowercaseString];
            }
            else
            {
                stringToLookFor = textAfterAtSign;
            }
            
            for (NSString *stringFromReference in autocompleteArray)
            {
                NSString *stringToCompare;
                if (ignoreCase)
                {
                    stringToCompare = [stringFromReference lowercaseString];
                }
                else
                {
                    stringToCompare = stringFromReference;
                }
                
                if ([stringToCompare hasPrefix:stringToLookFor])
                {
                    return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
                }
                
            }
        }
    }
    
    if (textField.autocompleteType&TextFieldAutocompletionTypeHashtag)
    {
        static dispatch_once_t colorOnceToken;
        static NSArray *colorAutocompleteArray;
        dispatch_once(&colorOnceToken, ^
                      {
                          colorAutocompleteArray = @[ @"Blue",
                                                      @"Yellow",
                                                      @"Green",
                                                      @"Magenta",
                                                      @"Yellow",
                                                      @"Orange",
                                                      @"Red",
                                                      @"Cyan"];
                      });
        
        NSString *stringToLookFor;
        if (ignoreCase)
        {
            stringToLookFor = [prefix lowercaseString];
        }
        else
        {
            stringToLookFor = prefix;
        }
        
        for (NSString *stringFromReference in colorAutocompleteArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    
    return @"";
}

#pragma mark - Getters & Setters

- (NSURL*)favoriteEmailsFileLocation
{
    if(!_favoriteEmailsFileLocation) {
        _favoriteEmailsFileLocation = [NSURL URLWithString:@"FavoriteEmails" relativeToURL:self.documentDirectory];
    }
    return _favoriteEmailsFileLocation;
}

- (NSURL*)documentDirectory
{
    if(!_documentDirectory) {
        _documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                     inDomains:NSUserDomainMask]
                                                         lastObject];
    }
    return _documentDirectory;
}

- (NSArray*)favoriteEmails
{
    if(!_favoriteEmails) {
        _favoriteEmails = [NSArray arrayWithContentsOfURL:self.favoriteEmailsFileLocation];
    }
    return _favoriteEmails;
}

@end
