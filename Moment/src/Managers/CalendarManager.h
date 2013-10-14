//
//  CalendarManager.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 03/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "MomentClass.h"

@interface CalendarManager : NSObject <UIAlertViewDelegate>

+ (void)addNewEventFromMoment:(MomentClass*)moment;

@end
