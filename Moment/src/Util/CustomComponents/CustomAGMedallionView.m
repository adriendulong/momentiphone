//
//  CustomAGMedallionView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "CustomAGMedallionView.h"
#import "UIImageView+AFNetworking.h"
#import "AFMomentAPIClient.h"
#import "CropImageUtility.h"

@implementation CustomAGMedallionView

@synthesize imageString = _imageString;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize globalImage = _globalImage;
@synthesize isShinning = _isShinning, isShadow = _isShadow;
@synthesize defaultStyle = _defaultStyle;

- (void)setupIndicator {
       
    // Création de l'indicateur
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    // On centre l'indicateur
    CGRect frame = self.activityIndicatorView.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width)/2.0;
    frame.origin.y = (self.frame.size.height - frame.size.height)/2.0;
    self.activityIndicatorView.frame = frame;
    
    // Defauts
    self.isShinning = NO;
    self.isShadow = NO;
    self.shadowBlur = 1.5f;
    self.defaultStyle = -1;
    
    self.layer.shouldRasterize = YES;
    
    [self addSubview:self.activityIndicatorView];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setupIndicator];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupIndicator];
    }
    return self;
}

- (void)setDefaultImage
{
    if(!self.image)
    {
        switch (self.defaultStyle) {
            case MedallionStyleProfile:
                self.image = [UIImage imageNamed:@"profil_defaut"];
                break;
                
            case MedallionStyleCover:
                self.image = [UIImage imageNamed:@"cover_defaut"];
                break;
        }
    }
}

- (void)setDefaultStyle:(enum MedallionStyle)defaultStyle
{
    _defaultStyle = defaultStyle;
    [self setDefaultImage];
}

- (void)setImage:(UIImage *)imageParam imageString:(NSString*)imageString withSaveBlock:(void (^)(UIImage *image))block {
    
    if( imageParam == nil){
        
        if([imageString length] != 0)
        {
            [self.activityIndicatorView startAnimating];
            
            self.imageString = imageString;
            
            //NSLog(@"Image doesn't exist - URL : %@", imageString);
            
            UIImageView *temp = [[UIImageView alloc] init];
            
            NSURL *url = [NSURL URLWithString:imageString];            
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60*2];
            
            
            [temp setImageWithURLRequest:request
                        placeholderImage:nil
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *imageServer) {
                                    
                                     // Default Picture
                                     if(!imageServer) {
                                         [self setDefaultImage];
                                     }
                                     else {
                                         self.image = imageServer;
                                     }
                                     
                                     if(block)
                                         block(imageServer);
                                     
                                     //NSLog(@"image updated");
                                     [self.activityIndicatorView stopAnimating];
                                 }
                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                     [self.activityIndicatorView stopAnimating];
                                     NSLog(@"CustomAGMedallion Fail to load image : %@", imageString);
                                     NSLog(@"error : %@", error.localizedDescription);
                                     NSLog(@"Response : %d", response.statusCode);
                                 }];
            
            //self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:<#(NSURL *)#>]]
            /*
             [self.imageView 
             setImageWithURLRequest:
             [NSURLRequest requestWithURL: 
             [NSURL URLWithString:_product.imageString]
             cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60]
             placeholderImage:nil 
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             self.moment.image = image;
             [self.activityIndocatorView stopAnimating];
             } 
             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             [self.activityIndocatorView stopAnimating];
             }];
             */
             
        }
        else {
            [self setDefaultImage];
        }
        
    }
    else {
        //NSLog(@"Image exist");
        //[self.roundButton setImage:self.moment.image forState:UIControlStateNormal];
        //[self.roundButton setImage:self.moment.image forState:UIControlStateSelected];
        //[self.roundButton setImage:self.moment.image forState:UIControlStateHighlighted];
        
        self.image = imageParam;
    }
    
}

- (void)setImage:(UIImage *)imageParam {
    [super setImage:[CropImageUtility cropImageToSquare:imageParam]];
}


- (void)drawRect:(CGRect)rect
{
    // Image rect
    CGRect imageRect = CGRectMake((self.borderWidth),
                                  (self.borderWidth) ,
                                  rect.size.width - (self.borderWidth * 2),
                                  rect.size.height - (self.borderWidth * 2));
    
    // Start working with the mask
    CGColorSpaceRef maskColorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef mainMaskContextRef = CGBitmapContextCreate(NULL,
                                                            rect.size.width,
                                                            rect.size.height,
                                                            8,
                                                            rect.size.width,
                                                            maskColorSpaceRef,
                                                            0);
    CGContextRef shineMaskContextRef = CGBitmapContextCreate(NULL,
                                                             rect.size.width,
                                                             rect.size.height,
                                                             8,
                                                             rect.size.width,
                                                             maskColorSpaceRef,
                                                             0);
    CGColorSpaceRelease(maskColorSpaceRef);
    CGContextSetFillColorWithColor(mainMaskContextRef, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(shineMaskContextRef, [UIColor blackColor].CGColor);
    CGContextFillRect(mainMaskContextRef, rect);
    CGContextFillRect(shineMaskContextRef, rect);
    CGContextSetFillColorWithColor(mainMaskContextRef, [UIColor whiteColor].CGColor);
    
    if( self.isShinning )
        CGContextSetFillColorWithColor(shineMaskContextRef, [UIColor whiteColor].CGColor);
    
    // Create main mask shape
    CGContextMoveToPoint(mainMaskContextRef, 0, 0);
    CGContextAddEllipseInRect(mainMaskContextRef, imageRect);
    CGContextFillPath(mainMaskContextRef);
    
    // Create shine mask shape
    if( self.isShinning ) {
        CGContextTranslateCTM(shineMaskContextRef, -(rect.size.width / 4), rect.size.height / 4 * 3);
        CGContextRotateCTM(shineMaskContextRef, -45.f);
        CGContextMoveToPoint(shineMaskContextRef, 0, 0);
        CGContextFillRect(shineMaskContextRef, CGRectMake(0,
                                                          0,
                                                          rect.size.width / 8 * 5,
                                                          rect.size.height));
    }
    
    CGImageRef mainMaskImageRef = CGBitmapContextCreateImage(mainMaskContextRef);
    CGImageRef shineMaskImageRef = CGBitmapContextCreateImage(shineMaskContextRef);
    CGContextRelease(mainMaskContextRef);
    CGContextRelease(shineMaskContextRef);
    // Done with mask context
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(contextRef);
    
    CGImageRef imageRef = CGImageCreateWithMask(self.image.CGImage, mainMaskImageRef);
    
    CGContextTranslateCTM(contextRef, 0, rect.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    CGContextSaveGState(contextRef);
    
    // Draw image
    CGContextDrawImage(contextRef, rect, imageRef);
    
    CGContextRestoreGState(contextRef);
    CGContextSaveGState(contextRef);
    
    // Clip to shine's mask
    CGContextClipToMask(contextRef, self.bounds, mainMaskImageRef);
    CGContextClipToMask(contextRef, self.bounds, shineMaskImageRef);
    CGContextSetBlendMode(contextRef, kCGBlendModeLighten);
    CGContextDrawLinearGradient(contextRef, [self alphaGradient], CGPointMake(0, 0), CGPointMake(0, self.bounds.size.height), 0);
    
    CGImageRelease(mainMaskImageRef);
    CGImageRelease(shineMaskImageRef);
    CGImageRelease(imageRef);
    // Done with image
    
    CGContextRestoreGState(contextRef);
    
    CGContextSetLineWidth(contextRef, self.borderWidth);
    CGContextSetStrokeColorWithColor(contextRef, self.borderColor.CGColor);
    CGContextMoveToPoint(contextRef, 0, 0);
    CGContextAddEllipseInRect(contextRef, imageRect);
    
    // Intern shadow
    CGContextSaveGState(contextRef);
    CGContextSetShadowWithColor(contextRef, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    CGContextStrokePath(contextRef);
    
    // On recouvre l'ombre l'externe
    CGContextRestoreGState(contextRef);
    
    CGRect temp = imageRect;
    temp.origin.x -= self.borderWidth/2.0;
    temp.origin.y -= self.borderWidth/2.0;
    temp.size.width += self.borderWidth;
    temp.size.height += self.borderWidth;
    CGContextAddEllipseInRect(contextRef, temp);
    
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
    
    // Drop shadow
    if( self.isShadow ) {
        CGContextSetShadowWithColor(contextRef, 
                                    self.shadowOffset, 
                                    self.shadowBlur, 
                                    self.shadowColor.CGColor);
        
        CGContextStrokePath(contextRef);
        CGContextRestoreGState(contextRef);
    }
    
}

@end
