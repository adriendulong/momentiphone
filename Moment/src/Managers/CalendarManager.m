//
//  CalendarManager.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 03/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CalendarManager.h"
#import "MTStatusBarOverlay.h"

static UIAlertView *addEventAlertView = nil;
static MomentClass *currentMoment = nil;

@implementation CalendarManager

+ (void)accesEventStoreWithEnded:(void (^) (EKEventStore *eventStore) )block
{
    if(block)
    {
        
        EKEventStore* eventStore = [[EKEventStore alloc] init];
        
        // iOS 6 and later
        if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            
            // Get Authorisation
            EKAuthorizationStatus authorisation = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        
            switch (authorisation) {
                    
                // First Authorisation Request
                case EKAuthorizationStatusNotDetermined:
                {
                    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                        
                        // Success
                        if(!error) {
                            block(eventStore);
                        }
                        // Error
                        else {
                            NSLog(@"EKEventStore Authorisation Access Fail");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CalendarManager_EventStoreAccessFail_Title", nil)
                                                            message:NSLocalizedString(@"CalendarManager_EventStoreAccessFail_Message", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                                  otherButtonTitles:nil] show];
                            });
                        }
                    }];
                }
                break;
                    
                // Authorized
                case EKAuthorizationStatusAuthorized: {
                    block(eventStore);
                }
                break;
                    
                // Error
                default:
                    NSLog(@"EKEventStore Authorisation Not Valid");
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CalendarManager_EventStoreAccessRefused_Title", nil)
                                                message:NSLocalizedString(@"CalendarManager_EventStoreAccessRefused_Message", nil)
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                      otherButtonTitles:nil] show];
                    break;
            }
            
            
        }
        // iOS 5
        else {
            block(eventStore);
        }
    }
    
}

+ (void)addNewEventFromMoment:(MomentClass*)moment withEnded:(void (^) (BOOL success))block
{
    dispatch_queue_t eventCreationQueue = dispatch_queue_create("EventCreationQueue", NULL);
    dispatch_async(eventCreationQueue, ^{
        
        [self accesEventStoreWithEnded:^(EKEventStore *eventStore) {
            
            // Create a new event
            EKEvent *myEvent = [EKEvent eventWithEventStore:eventStore];
            
            // Date début et Fin
            if(moment.dateDebut && moment.dateFin) {
                myEvent.allDay = NO;
                myEvent.startDate = moment.dateDebut;
                myEvent.endDate = moment.dateFin;
            }
            // Une seule limite
            else if(moment.dateDebut || moment.dateFin) {
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.calendar = [NSCalendar currentCalendar];
                df.timeZone = [NSTimeZone systemTimeZone];
                df.locale = [NSLocale currentLocale];
                df.dateFormat = @"hhmm";
                
                // Date Début seulement
                if(moment.dateDebut) {
                    
                    myEvent.startDate = moment.dateDebut;
                    
                    // Minuit ou pas d'heure -> All Day
                    if([[df stringFromDate:moment.dateDebut] isEqualToString:@"0000"]) {
                        myEvent.allDay = YES;
                    }
                    // Heure début fixée -> Heure Fin Automatique : +1h
                    else {
                        myEvent.allDay = NO;
                        myEvent.endDate = [moment.dateDebut dateByAddingTimeInterval:60*60];
                    }
                }
                // Date Fin seulement
                else {
                    
                    myEvent.endDate = moment.dateFin;
                    
                    // Minuit ou pas d'heure -> All Day
                    if([[df stringFromDate:moment.dateFin] isEqualToString:@"0000"]) {
                        myEvent.allDay = YES;
                    }
                    // Heure fin fixée -> Heure début Automatique : -1h
                    else {
                        myEvent.allDay = NO;
                        myEvent.endDate = [moment.dateFin dateByAddingTimeInterval:-60*60];
                    }
                    
                }
                
            }

            myEvent.title = moment.titre;
            myEvent.calendar = [eventStore defaultCalendarForNewEvents];
            if(moment.adresse)
                myEvent.location = moment.adresse;
            if(moment.descriptionString)
                myEvent.notes = moment.descriptionString;
            myEvent.alarms = @[];
            myEvent.timeZone = [NSTimeZone systemTimeZone];
            
            // Save and commit
            NSError *error = nil;
            [eventStore saveEvent:myEvent span:EKSpanThisEvent commit:YES error:&error];
            
            // Handle error
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    
                    if(block)
                        block(YES);
                    NSLog(@"the event saved and committed correctly with identifier %@", myEvent.eventIdentifier);
                    
                } else {
                    
                    if(block)
                        block(NO);
                    
                    NSLog(@"there was an error saving and committing the event");
                }
            });
            
        }];
        
    });
    dispatch_release(eventCreationQueue);
}

+ (void)addNewEventFromMoment:(MomentClass*)moment
{
    [self accesEventStoreWithEnded:^(EKEventStore *eventStore) {
        
        // On cherche les events correspondant
        NSDate *start = moment.dateDebut ?: [NSDate dateWithTimeIntervalSince1970:0]; // Depuis 1970
        NSDate *end = moment.dateFin ?: [NSDate dateWithTimeIntervalSinceNow:3600*24*7*52]; // 1 an dans le futur
        
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:start endDate:end calendars:@[[eventStore defaultCalendarForNewEvents]]];
        NSArray *matches = [eventStore eventsMatchingPredicate:predicate];
        
        // Création de l'alertview si elle n'est pas déjà allouée
        if(!addEventAlertView) {
            addEventAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CalendarManager_EventCreation_AskUserAlertView_Title", nil)
                                                           message:NSLocalizedString(@"CalendarManager_EventCreation_AskUserAlertView_Message", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"AlertView_Button_Cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"AlertView_Button_OK", nil), nil];
        }
        
        // Si il n'y en a pas ==> Demande à l'utilisateur
        if([matches count] == 0)
        {
            currentMoment = moment;
            [addEventAlertView show];
        }
        else if(matches) {
            
            /*
             * Le Prédicate retourne les dates correspondant à l'interval
             * --> Vérification manuelle de l'égalité des dates <--
             */
            
            BOOL add = YES;
            for( EKEvent *event in matches )
            {
                if( [event.startDate isEqualToDate:moment.dateDebut] && [event.endDate isEqualToDate:moment.dateFin] && [event.title isEqualToString:moment.titre] )
                {
                    add = NO;
                    break;
                }
            }
            
            // Demande à l'utilisateur pour l'ajout de l'évènement
            if(add) {
                currentMoment = moment;
                [addEventAlertView show];
            }
            
        }
    }];

}

#pragma mark - UIAlertView Delegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        // OK
        case 1:
            
            // Ajout du moment
            [self addNewEventFromMoment:currentMoment withEnded:^(BOOL success) {
                if(success) {
                    [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:NSLocalizedString(@"CalendarManager_EventCreationSuccees", nil)
                                                                           duration:1.0
                                                                           animated:YES];
                }
                else {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CalendarManager_EventCreationFail_Title", nil)
                                                message:NSLocalizedString(@"CalendarManager_EventCreationFail_Message", nil)
                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"AlertView_Button_OK", nil)
                                      otherButtonTitles:nil]
                     show];
                }
            }];
            break;
    }
    
    currentMoment = nil;
}

@end
