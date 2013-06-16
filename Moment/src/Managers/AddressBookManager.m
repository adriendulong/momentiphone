//
//  AddressBookManager.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "AddressBookManager.h"
#import <AddressBook/AddressBook.h>

@implementation AddressBookManager

+ (NSArray*)getAddressBookList:(ABAddressBookRef)addressBook
{
    if(addressBook)
    {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        
        CFIndex nPeople = CFArrayGetCount(allPeople);
        
        for ( int i = 0; i < nPeople; i++ )
        {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            // Récupérer nom & prénom
            NSString *prenom = [(__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty) uppercaseString];
            NSString *nom = [(__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty) uppercaseString];
            
            // Récupérer numéro de téléphone
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFIndex taille = ABMultiValueGetCount(phoneNumbers);
            NSString *firstPhone = nil, *secondPhone = nil;
            if(taille > 0) { firstPhone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0); }
            if(taille > 1) { secondPhone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 1); }
            
            // Récupérer image si il y en a
            UIImage *image = nil;
            if(ABPersonHasImageData(person)) {
                image = [[UIImage alloc] initWithData:(__bridge_transfer NSData*)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
            }
            
            // Récupérer email
            ABMultiValueRef emailsAddress = ABRecordCopyValue(person, kABPersonEmailProperty);
            taille = ABMultiValueGetCount(emailsAddress);
            NSString *firstEmail = nil, *secondEmail = nil;
            if(taille > 0) { firstEmail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailsAddress, 0); }
            if(taille > 1) { secondEmail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailsAddress, 1); }
            
            // Récupérer adresse
            ABMultiValueRef addressesProperties = ABRecordCopyValue(person, kABPersonAddressProperty);
            taille = ABMultiValueGetCount(addressesProperties);
            NSString *city = nil;
            NSString *country = nil;
            
            if(taille > 0) {
                NSDictionary *dict = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(addressesProperties, (CFIndex)0);
                
                if(dict[(__bridge_transfer NSString*)kABPersonAddressCityKey])
                    city = (NSString*)dict[(__bridge_transfer NSString*)kABPersonAddressCityKey];
                
                if(dict[(__bridge_transfer NSString*)kABPersonAddressCountryKey])
                    country = (NSString*)dict[(__bridge_transfer NSString*)kABPersonAddressCountryKey];
            }
            
            CFRelease(addressesProperties);
            
            // Formatter adresse
            NSString *adresse = nil;
            BOOL cityOk = (city && city.length > 0);
            BOOL countryOK = (country && country.length > 0);
            if( cityOk && countryOK ){
                adresse = [NSString stringWithFormat:@"%@, %@", [city uppercaseString], [country uppercaseString]];
            } else if(city) {
                adresse = [city uppercaseString];
            } else if(country) {
                adresse = [country uppercaseString];
            }
            
            NSMutableDictionary *dico = [[NSMutableDictionary alloc] init];
            if(nom) dico[@"nom"] = nom;
            if(prenom) dico[@"prenom"] = prenom;
            if(image) dico[@"photo"] = image;
            if(adresse) dico[@"adresse"] = adresse;
            if(firstEmail) dico[@"email"] = firstEmail;
            if(secondEmail) dico[@"secondEmail"] = secondEmail;
            if(firstPhone) dico[@"numeroMobile"] = firstPhone;
            if(secondPhone) dico[@"secondPhone"] = secondPhone;
            
            if( firstEmail || firstPhone ) {
                UserClass *user = [[UserClass alloc] initWithAttributesFromLocal:dico];
                if(user && (user.prenom || user.nom) )
                    [list addObject:user];
            }
            
        }
        
        CFRelease(addressBook);
        
        return (NSArray*)list;
    }
    
    return nil;
}

+ (void)accesAddressBookListWithCompletionHandler:(void (^) (NSArray* list))block
{
    ABAddressBookRef addressBook = nil;
    
    // iOS 6
    if([[VersionControl sharedInstance] supportIOS6]) {
        
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus authorisation = ABAddressBookGetAuthorizationStatus();
        
        switch (authorisation) {
                
            case kABAuthorizationStatusNotDetermined:
            {
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    // First time access has been granted, add the contact
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(granted) {
                            if(block)
                                block([self getAddressBookList:addressBook]);
                        }
                        else {
                            NSLog(@"Error acces addressBook : %@", error);
                            if(block)
                                block(nil);
                        }
                    });
                    
                });
            }
            break;
            
            case kABAuthorizationStatusAuthorized:
                // The user has previously given access, add the contact
                if(block)
                    block([self getAddressBookList:addressBook]);
                break;
                
            default:
                // The user has previously denied access
                // Send an alert telling user to change privacy setting in settings app
                NSLog(@"Acces to addressBook not authorized");
                
                [[[UIAlertView alloc] initWithTitle:@"Authorisation manquante"
                                            message:@"Veuillez changer les paramètres de confidentialité de l'iPhone afin d'accéder aux contacts"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil]
                 show];
                break;
        }
        
    }
    // iOS 5
    else {
        addressBook = ABAddressBookCreate();
        
        if(block)
            block([self getAddressBookList:addressBook]);
    }
    
}

@end
