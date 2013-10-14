//
//  CustomUIImageView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 31/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "CustomUIImageView.h"
#import "UIImageView+AFNetworking.h"
#import "AFMomentAPIClient.h"

@implementation CustomUIImageView

@synthesize imageString = _imageString;
@synthesize activityIndicatorView = _activityIndicatorView;

- (void)setup {
    
    // Création de l'indicateur
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    
    // On centre l'indicateur
    CGRect frame = self.activityIndicatorView.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width)/2.0;
    frame.origin.y = (self.frame.size.height - frame.size.height)/2.0;
    self.activityIndicatorView.frame = frame;
    
    [self addSubview:self.activityIndicatorView];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setImage:(UIImage *)image
     imageString:(NSString*)imageString
     placeHolder:(UIImage *)placeHolder
   withSaveBlock:( void (^) (UIImage* image) )block
{

    if( image == nil){
        
        if([imageString length] > 0)
        {
            // On centre l'indicateur
            CGRect frame = self.activityIndicatorView.frame;
            frame.origin.x = (self.frame.size.width - frame.size.width)/2.0;
            frame.origin.y = (self.frame.size.height - frame.size.height)/2.0;
            self.activityIndicatorView.frame = frame;
            
            [self.activityIndicatorView startAnimating];
            
            self.imageString = imageString;
            
            //NSLog(@"Image doesn't exist - URL : %@", imageString);
            __weak CustomUIImageView *varInstance = self;
  
            NSURL *url = [NSURL URLWithString:imageString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
                                    
            [self setImageWithURLRequest:request
                        placeholderImage:placeHolder
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *imageServer) {
                                    
                                     if(imageServer)
                                         varInstance.image = imageServer;
                                     else
                                         varInstance.image = placeHolder;
                                     
                                     if(block)
                                         block(imageServer);
                                     
                                     [varInstance.activityIndicatorView stopAnimating];
            }
                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                     [varInstance.activityIndicatorView stopAnimating];
                                     //NSLog(@"CustomUIimage Fail to load image : %@", imageString);
                                     //NSLog(@"error : %@", error.localizedDescription);
                                     //NSLog(@"Response : %d", response.statusCode);
            }];
            
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
        else
            self.image = placeHolder;
        
    }
    else {
        //NSLog(@"Image exist");
        //[self.roundButton setImage:self.moment.image forState:UIControlStateNormal];
        //[self.roundButton setImage:self.moment.image forState:UIControlStateSelected];
        //[self.roundButton setImage:self.moment.image forState:UIControlStateHighlighted];
        
        self.image = image;
    }
    
}

- (void)setImage:(UIImage *)image
     imageString:(NSString*)imageString
   withSaveBlock:( void (^) (UIImage* image) )block
{
    [self setImage:image
       imageString:imageString
       placeHolder:[UIImage imageNamed:@"cover_defaut"]
     withSaveBlock:block];
}

@end
