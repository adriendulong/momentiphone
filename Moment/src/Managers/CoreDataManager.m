//
//  CoreDataManager.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "CoreDataManager.h"
#import "Config.h"

@implementation CoreDataManager

@synthesize dataBaseName = _dataBaseName;

#pragma mark - init

- (id) initWithDataBaseName:(NSString*)name {
    
    NSURL *documentDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *url = [documentDirectoryURL URLByAppendingPathComponent:name];
    
    self = [super initWithFileURL:url];
    if(self) {
        _dataBaseName = name;
        if(DEBUG_DATABASE)NSLog(@"DataBase has been created");
    }

    return self;
}

#pragma mark - Open / Close
- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler createIfNecessary:(BOOL)create {
    
    if(DEBUG_DATABASE)NSLog(@"open DataBase");
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:self.fileURL.path] ) {
        if(DEBUG_DATABASE)NSLog(@"File exist");
        [super openWithCompletionHandler:completionHandler];
    }
    else if(create) {
        if(DEBUG_DATABASE)NSLog(@"File doesn't exist - create it");
        [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success) {
                if(DEBUG_DATABASE)NSLog(@"Création fichier DataBase success");
                [super openWithCompletionHandler:completionHandler];
            }
            else {
                if(DEBUG_DATABASE)NSLog(@"Création fichier DataBase fail");

            }
        }];
        
    }
    else
        if(DEBUG_DATABASE)NSLog(@"File doesn't exist - don't create it");
    
}

- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler {
    [self openWithCompletionHandler:completionHandler createIfNecessary:NO];
}

- (void)open {
    [self openWithCompletionHandler:nil createIfNecessary:YES];
}

- (void)saveContext
{
    // Save
    NSError *error;
    [self.managedObjectContext save:&error];
    
    if(error) {
        NSLog(@"ERROR SAVE CONTEXT\n==> \"%@\"", error.localizedDescription);
        abort();
#warning DEBUG abort
    }
}

- (void)save {
    //NSLog(@"save called");
    
    [self saveContext];
    
    [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        
        if(DEBUG_DATABASE) {
            if(success)
                NSLog(@"DataBase has been saved");
            else
                NSLog(@"Fail to save DataBase");
        }
        
    }];
}

- (void)closeWithSaving:(BOOL)save {
    
    if(save)
        [self save];
    
    [self closeWithCompletionHandler:^(BOOL success) {
        if(DEBUG_DATABASE) {
            if(success)
                NSLog(@"DataBase Close Success");
            else
                NSLog(@"DataBase Close Fail");
        }
    }];
}

- (void)close {
    [self closeWithSaving:YES];
}

#pragma mark - Request

- (NSArray*)executeRequestWithEntityName:(NSString*)entity
                           withArguments:(NSArray*)arguments
                   withPredicateCreation:(NSPredicate* (^) (NSArray* arguments) )predicateCreation
                      withSortDescriptor:(NSSortDescriptor*)sortDescriptor
                      withSuccessHandler:(NSArray* (^) (NSArray* matches))successBlock
                        withErrorHandler:(void (^) (void) )errorBlock {
    
    // Request creation
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    request.predicate = predicateCreation(arguments);
    
    if(sortDescriptor)
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    // Exectution
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    // Success Handler
    if( matches ) {
        
        // Si un handler est passé en paramètre, on l'utilise
        if(successBlock)
            return successBlock(matches);
        
        // Sinon, on retourne le tableau tel quel
        return matches;
    }
    
    // Error Handler
    errorBlock();
    
    return nil;
}

@end
