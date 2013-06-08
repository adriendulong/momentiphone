//
//  Config.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 01/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "Config.h"
#import "TTTAttributedLabel.h"

static NSString *fontName = @"Numans-Regular";

@implementation Config

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton

static Config *sharedInstance = nil;

+ (Config*)sharedInstance {
    if(sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

#pragma mark - CoreData


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Moment" withExtension:@"mom"]; // ou @"momd"
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // URL
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Moment.sqlite"];
    
    // Handle Automatic Version Migration
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @(YES),
                              NSInferMappingModelAutomaticallyOption : @(YES)
                              };
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Font

- (UIFont*)defaultFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Numans" size:size];
}

- (void)updateTTTAttributedString:(NSMutableAttributedString*)mutableString withFontSize:(CGFloat)size onRange:(NSRange)range
{
    CTFontRef ctfont = CTFontCreateWithName((__bridge CFStringRef)fontName, size, NULL);
    if(ctfont) {
        [mutableString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)ctfont range:range];
        CFRelease(ctfont);
    }
}

- (void)updateTTTAttributedString:(NSMutableAttributedString*)mutableString withColor:(UIColor*)color onRange:(NSRange)range
{
    [mutableString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[color CGColor] range:range];
}


#pragma mark - Colors

- (UIColor*)orangeColor {
    return [UIColor colorWithHex:0xff9a04];
}

- (UIColor*)textColor {
    return [UIColor colorWithHex:0x787474];
}

#pragma mark - Image Cropping

- (UIImage*)scaleAndCropImage:(UIImage*)sourceImage forSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*)imageWithMaxSize:(UIImage*)image maxSize:(CGFloat)maxImageSize
{    
    // Si l'image est trop grande, on la redimentionne
    if( (image.size.width > maxImageSize) || (image.size.height > maxImageSize) )
    {
        CGFloat scale = (image.size.width > image.size.height)?maxImageSize/image.size.width:maxImageSize/image.size.height;
        CGFloat width = image.size.width*scale, height = image.size.height*scale;
        
        UIGraphicsBeginImageContext(CGSizeMake(width,height));
        [image drawInRect:CGRectMake(0,0,width, height)];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM (context, -M_PI/4.0);
        
        UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return croppedImage;
    }
    
    return image;
}

#pragma mark - Regex Validation

- (BOOL)isNumeric:(NSString*)s
{
    NSScanner *sc = [NSScanner scannerWithString:s];
    if ( [sc scanFloat:NULL] )
    {
        return [sc isAtEnd];
    }
    return NO;
}

- (NSString*)formatedPhoneNumber:(NSString*)phoneNumber
{
    return [[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (BOOL)isValidEmail:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)isValidPhoneNumber:(NSString*)phoneNumber
{
    NSString *regex = @"0[1-9]((([0-9]{2}){4})|((\\s[0-9]{2}){4})|((-[0-9]{2}){4}))";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:phoneNumber];
}

- (BOOL)isMobilePhoneNumber:(NSString*)phoneNumber forceValidation:(BOOL)force
{
    if(force) {
        NSString *regex = @"0[67]((([0-9]{2}){4})|((\\s[0-9]{2}){4})|((-[0-9]{2}){4}))";
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        return [test evaluateWithObject:phoneNumber];
    }

    NSString *start = [phoneNumber substringWithRange:NSMakeRange(0, 2)];
    return [start isEqualToString:@"06"] || [start isEqualToString:@"07"];
}

#pragma mark - Cover Image

- (NSString*)coverImageFullPath {
    
    NSString *name = [NSString stringWithFormat:@"coverImage_%@.png", [UserCoreData getCurrentUser].userId];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
    													 NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths lastObject];
    return [documentsDirectory stringByAppendingPathComponent:name];
}

- (void)saveNewCoverImage:(UIImage *)image {
    
    NSData *data = UIImagePNGRepresentation(image);    
    NSString *fullPath = [self coverImageFullPath];
    
    // Delete previous cover if it exist
    [self deleteFileAtPath:fullPath];
    
    // Save new cover
    if([data writeToFile:fullPath atomically:YES])
    {
        // Succes -> Notify
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChangeCover object:image];
    }
}

- (UIImage*)coverImage {
    
    UIImage *image = [UIImage imageWithContentsOfFile:[self coverImageFullPath]];
    
    // Load default image if needed
    if(!image)
        image = [UIImage imageNamed:@"photo.png"];
    
    return image;
}

- (void)deleteFileAtPath:(NSString*)fullPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
        
    NSError *error = nil;
    if( [fileManager fileExistsAtPath:fullPath] ){
    	if( ![fileManager removeItemAtPath:fullPath error:&error] ) {
    		NSLog(@"Failed deleting background image file %@", error);
    		// the write below should fail. Add your own flag and check below.
    	}
    }
}

- (void)deleteCoverImage
{
    NSString *fullPath = [self coverImageFullPath];
    [self deleteFileAtPath:fullPath];
}

#pragma mark - Texte Formatage

- (NSString*)twitterShareTextForMoment:(MomentClass*)moment nbMaxCaracters:(NSInteger)nbMaxCarac
{
    // Limitation à 160 caractères max
    NSString *format = @"Bon Moment @%@ !";
    NSInteger taille = moment.titre.length + format.length - 2;
    NSString *initialText = nil;
    NSInteger tailleRestante;
    
    // Titre seul trop grand = ne pas afficher titre
    if(moment.titre.length >= nbMaxCarac) {
        initialText = @"Bon Moment !";
        tailleRestante = 0;
    }
    // Taille totale assez petite
    else if(taille <= nbMaxCarac) {
        initialText = [NSString stringWithFormat:format, moment.titre];
        tailleRestante = nbMaxCarac - taille;
    }
    // Taille totale trop grande
    else {
        NSInteger lastPosition = nbMaxCarac - (format.length - 2) - 3;
        // Réduction du titre
        if(lastPosition > 0) {
            NSString *titre = [NSString stringWithFormat:@"%@...", [moment.titre substringWithRange:NSMakeRange(0, lastPosition)]];
            initialText = [NSString stringWithFormat:format, titre];
            tailleRestante = 0;
        }
        // Pas la place de réduire le titre = ne pas afficher le titre
        else {
            initialText = [NSMutableString stringWithFormat:format, moment.titre];
            tailleRestante = nbMaxCarac - taille;
        }
    }
    
    return initialText;
}

@end
