//
//  CoreDataManager.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : UIManagedDocument

@property (strong, readonly) NSString *dataBaseName;

- (id) initWithDataBaseName:(NSString*)name;

- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler createIfNecessary:(BOOL)create;
- (void)open;
- (void)saveContext;
- (void)save;
- (void)closeWithSaving:(BOOL)save;
- (void)close;

- (NSArray*)executeRequestWithEntityName:(NSString*)entity
                           withArguments:(NSArray*)arguments
                   withPredicateCreation:(NSPredicate* (^) (NSArray* arguments) )predicateCreation
                      withSortDescriptor:(NSSortDescriptor*)sortDescriptor
                      withSuccessHandler:(NSArray* (^) (NSArray* matches))successBlock
                        withErrorHandler:(void (^) (void) )errorBlock;

@end
