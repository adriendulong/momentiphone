//
//  MomentClass+Mapping.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "MomentClass+Mapping.h"

static NSDateFormatter *fullDateFormatter = nil;
static NSDateFormatter *smallDateFormatter = nil;

@implementation MomentClass (Mapping)

+ (NSDictionary*) mappingToLocalWithAttributes:(NSDictionary*)attributes
{
    // Empeche le mapping d'un dictionnaire dans le bon format
    if( !attributes[@"ios_mapping"] || [attributes[@"ios_mapping"] isEqualToString:@"WEB"] )
    {
        
        NSString *startDate = attributes[@"startDate"];
        NSString *endDate = attributes[@"endDate"];
        NSString *startTime = attributes[@"startTime"];
        NSString *endTime = attributes[@"entTime"];
        
        if(!fullDateFormatter) {
            fullDateFormatter = [[NSDateFormatter alloc] init];
            fullDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
            fullDateFormatter.timeZone = [NSTimeZone defaultTimeZone];
            fullDateFormatter.dateFormat = @"YYYY-MM-dd-HH:mm:ss";
        }
        
        if(!smallDateFormatter){
            smallDateFormatter = [[NSDateFormatter alloc] init];
            smallDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
            smallDateFormatter.timeZone = [NSTimeZone defaultTimeZone];
            smallDateFormatter.dateFormat = @"YYYY-MM-dd";
        }
        
        
        NSDate *start = nil;
        NSDate *end = nil;
        
        // Si une heure est fournie
        if( startTime || endTime ) {
            
            if(startTime) {
                start = [fullDateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@", startDate, startTime]];
            }
            
            if(endTime) {
                end = [fullDateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@", endDate, endTime] ];
            }
        }
        
        // Si au moins une heure n'a pas été fournie
        if( !startTime || !endTime ) {
            
            if(!startTime) {
                start = [smallDateFormatter dateFromString:startDate];
            }
            
            if(!endTime) {
                end = [smallDateFormatter dateFromString:endDate];
            }
            
        }
        
        if(!start)
            start = [NSDate date];
        if(!end)
            end = [NSDate date];
        
        NSMutableDictionary *dico = @{
                                      @"ios_mapping":@"LOCAL",
                                      @"momentId":attributes[@"id"],
                                      @"dateDebut":start,
                                      @"dateFin":end,
                                      @"titre":attributes[@"name"]
                                      }.mutableCopy;
        
        if(attributes[@"guests_number"]) {
            dico[@"guests_number"] = attributes[@"guests_number"];
            dico[@"guests_coming"] = attributes[@"guests_coming"];
            dico[@"guests_not_coming"] = attributes[@"guests_not_coming"];
        }
        
        if(attributes[@"facebookId"])
            dico[@"facebookId"] = attributes[@"facebookId"];
        
        if(attributes[@"hashtag"])
            dico[@"hashtag"] = attributes[@"hashtag"];
        
        if(attributes[@"description"])
            dico[@"descriptionString"] = attributes[@"description"];
        
        if(attributes[@"placeInformations"])
            dico[@"infoLieu"] = attributes[@"placeInformations"];
        
        if(attributes[@"address"])
            dico[@"adresse"] = attributes[@"address"];
        
        if(attributes[@"cover_photo_url"])
            dico[@"imageString"] = attributes[@"cover_photo_url"];
        
        if(attributes[@"owner"])
            dico[@"owner"] = attributes[@"owner"];
        
#warning first Key a changer avec la clé renvoyé depuis web
        if(attributes[@"nomLieu"])
            dico[@"nomLieu"] = attributes[@"nomLieu"];
        
        if(attributes[@"user_state"])
            dico[@"state"] = attributes[@"user_state"];
        
        if(attributes[@"isOpen"])
            dico[@"isOpen"] = attributes[@"isOpen"];
        
        if(attributes[@"is_sponso"])
            dico[@"isSponso"] = attributes[@"is_sponso"];
        
        return dico;
    }
    
    return attributes;
}

+ (NSDictionary *) mappingToWebWithAttributes:(NSDictionary*)attributes {
    
    // Empeche le mapping d'un dictionnaire dans le bon format
    if( !attributes[@"ios_mapping"] || [attributes[@"ios_mapping"] isEqualToString:@"LOCAL"] )
    {
        NSDateFormatter *dfJour = [[NSDateFormatter alloc] init];
        dfJour.dateFormat = @"YYYY-MM-dd";
        
        NSDateFormatter *dfHeure = [[NSDateFormatter alloc] init];
        dfHeure.dateFormat = @"HH:mm";
        
        NSMutableDictionary *dico = @{
                                      @"ios_mapping":@"WEB",
                                      @"address":attributes[@"adresse"],
                                      @"startDate":[dfJour stringFromDate:attributes[@"dateDebut"]],
                                      @"endDate":[dfJour stringFromDate:attributes[@"dateFin"]],
                                      @"startTime":[dfHeure stringFromDate:attributes[@"dateDebut"]],
                                      @"endTime":[dfHeure stringFromDate:attributes[@"dateFin"]],
                                      @"name":attributes[@"titre"]
                                      }.mutableCopy;
        
        if(attributes[@"momentId"])
            dico[@"id"] = attributes[@"momentId"];
        
        if(attributes[@"facebookId"])
            dico[@"facebookId"] = attributes[@"facebookId"];
        
        if(attributes[@"hashtag"])
            dico[@"hashtag"] = attributes[@"hashtag"];
        
        if(attributes[@"descriptionString"])
            dico[@"description"] = attributes[@"descriptionString"];
        
        if(attributes[@"infoLieu"])
            dico[@"placeInformations"] = attributes[@"infoLieu"];
        
        if(attributes[@"dataImage"])
            dico[@"photo"] = attributes[@"dataImage"];
        
        if(attributes[@"owner"])
            dico[@"owner"] = attributes[@"owner"];
        
#warning second key a changer avec la clé web
        if(attributes[@"nomLieu"])
            dico[@"nomLieu"] = attributes[@"nomLieu"];
        
        if(attributes[@"state"])
            dico[@"user_state"] = attributes[@"state"];
        
        if(attributes[@"isOpen"])
            dico[@"isOpen"] = attributes[@"isOpen"];
        
        if(attributes[@"isSponso"])
            dico[@"is_sponso"] = attributes[@"is_sponso"];
        
        return dico;
    }
    
    return attributes;
}

- (NSDictionary *) mappingToWeb
{
    //NSLog(@"\n--------------------------------------------------------------------------\n---------------------------------- DEBUT ---------------------------------\n--------------------------------------------------------------------------\n");
    
    //NSLog(@"ME = %@", self);
    
    NSDateFormatter *dfJour = [[NSDateFormatter alloc] init];
    dfJour.dateFormat = @"YYYY-MM-dd";
    
    NSDateFormatter *dfHeure = [[NSDateFormatter alloc] init];
    dfHeure.dateFormat = @"HH:mm";
    
    NSMutableDictionary *dico = [[NSMutableDictionary alloc] init];
    dico[@"ios_mapping"] = @"WEB";
    
    if(self.dateDebut) {
        dico[@"startDate"] = [dfJour stringFromDate:self.dateDebut];
        dico[@"startTime"] = [dfHeure stringFromDate:self.dateDebut];
    }
    else if(self.dateFin) {
        dico[@"startDate"] = [dfJour stringFromDate:[self.dateFin dateByAddingTimeInterval:-24*3600]];
        dico[@"startTime"] = [dfHeure stringFromDate:self.dateFin];
    }
    
    if(self.dateFin) {
        dico[@"endDate"] = [dfJour stringFromDate:self.dateFin];
        dico[@"endTime"] = [dfHeure stringFromDate:self.dateFin];
    }
    else if(self.dateDebut) {
        dico[@"endDate"] = [dfJour stringFromDate:[self.dateDebut dateByAddingTimeInterval:24*3600]];
        dico[@"endTime"] = [dfHeure stringFromDate:self.dateDebut];
    }
    
    if(self.imageString)
        dico[@"photo_url"] = self.imageString;
    
    if(self.titre)
        dico[@"name"] = self.titre;
    else
        dico[@"name"] = @"Unknown";
    
    if(self.adresse)
        dico[@"address"] = self.adresse;
    else
        dico[@"address"] = @"Unknwon";
    
    if(self.facebookId)
        dico[@"facebookId"] = self.facebookId;
    
    if(self.hashtag)
        dico[@"hashtag"] = self.hashtag;
    
    if(self.descriptionString)
        dico[@"description"] = self.descriptionString;
    
    if(self.infoLieu)
        dico[@"placeInformations"] = self.infoLieu;
    
    if(self.owner) {
        if(self.owner.facebookId)
            dico[@"owner_facebookId"] = self.owner.facebookId;
        if(self.owner.prenom)
            dico[@"owner_firstname"] = self.owner.prenom;
        if(self.owner.nom)
            dico[@"owner_lastname"] = self.owner.nom;
        if(self.owner.imageString)
            dico[@"owner_picture_url"] = self.owner.imageString;
    }
    
    if(self.imageString)
        dico[@"photo_url"] = self.imageString;
    else if(self.dataImage)
        dico[@"photo"] = self.dataImage;
    
#warning key a changer avec la clé web
    if(self.nomLieu)
        dico[@"nomLieu"] = self.nomLieu;
    
    if(self.state)
        dico[@"state"] = self.state;
    
    if(self.isOpen)
        dico[@"isOpen"] = self.isOpen;
    
    if(self.isSponso)
        dico[@"is_sponso"] = self.isSponso;
    
    //NSLog(@"\n--------------------------------------------------------------------------\n--------------------------------------------------------------------------\n");
    
    //NSLog(@"* = %@", dico);
    
    //NSLog(@"\n--------------------------------------------------------------------------\n---------------------------------- FIN ---------------------------------\n--------------------------------------------------------------------------\n");
    
    return dico.copy;
}


@end
