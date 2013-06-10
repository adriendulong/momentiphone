//
//  CustomExpandingButton.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 06/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "CustomExpandingButton.h"
#import "VersionControl.h"

@implementation CustomExpandingButton

@synthesize firstButton = _firstButton;
@synthesize secondButton = _secondButton;

@synthesize styloImage = _styloImage;
@synthesize validImage = _validImage;
@synthesize refusedImage = _refusedImage;
@synthesize waitingImage = _waitingImage;

@synthesize fondBlanc = _fondBlanc;
@synthesize isShowed = _isShowed;

- (id)initWithImage:(UIImage*)image withButtons:(NSArray*)buttons center:(CGPoint)center frame:(CGRect)frame
{
    self = [super initWithImage:image selectedImage:image toggledImage:image toggledSelectedImage:image buttons:buttons center:center withFrame:frame];
    if(self) {
        _isShowed = NO;
    }
    return self;
}

- (void) initButtonsImages
{
    self.styloImage = [UIImage imageNamed:@"picto_stylo_respond.png"];
    self.validImage = [UIImage imageNamed:@"picto_valid.png"];
    self.refusedImage = [UIImage imageNamed:@"picto_no.png"];
    self.waitingImage = [UIImage imageNamed:@"picto_maybe.png"];
}

- (NSArray*)orderButtonsWithState:(enum UserState)state
{    
    NSArray *images = nil;
    
    switch (state) {
            
        case UserStateValid:
            //NSLog(@"User Valid\n");
            images = @[self.validImage, self.waitingImage, self.refusedImage];
            break;
            
        case UserStateRefused:
            //NSLog(@"User Refused\n");
            images = @[self.refusedImage, self.waitingImage, self.validImage];
            break;
            
        case UserStateWaiting:
        case UserStateUnknown:
        case UserStateNoInvited:
            //NSLog(@"User Waiting : %d\n", state);
            images = @[self.waitingImage, self.refusedImage, self.validImage];
            break;
        
        case UserStateAdmin:
        case UserStateOwner:
            images = @[self.styloImage];
            break;
        
        default:
            NSLog(@"Other state : %d\n", state);
            break;
    }
    
    return images;
}

- (id)initWithDelegate:(NSObject<RNExpandingButtonBarDelegate> *)delegate withState:(enum UserState)state
{
    /* ---------------------------------------------------------
     * Create the center for the main button and origin of animations
     * -------------------------------------------------------*/
    CGPoint center = CGPointMake(285.0f, 107.0f);
    
    // Background
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_respond.png"] ];
    background.contentMode = UIViewContentModeScaleAspectFit;
    
    // Fond blanc
    UIImage *imageBackground = [UIImage imageNamed:@"bg_respond_developped.png"];
    
    imageBackground = [[VersionControl sharedInstance] resizableImageFromImage:imageBackground withCapInsets:UIEdgeInsetsMake(4, 0, 2, 0)  stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    NSInteger startPosition = background.frame.origin.y + 18;
    
    self.fondBlanc = [[UIImageView alloc] initWithImage:imageBackground ];
    CGRect frame = self.fondBlanc.frame;
    frame.origin.x = (background.frame.size.width - frame.size.width)/2.0;
    frame.origin.y = startPosition;
    frame.size.height = 0;
    self.fondBlanc.frame = frame;
    
    // Initialisation des boutons
    [self initButtonsImages];
    
    // Ordre des boutons
    NSArray *imagesBoutons = [self orderButtonsWithState:state];
    
    /* ---------------------------------------------------------
     * Create images that are used for the main button
     * -------------------------------------------------------*/
    UIImage *image = imagesBoutons[0];
    
    /* ---------------------------------------------------------
     * Setup buttons
     * -------------------------------------------------------*/
    // Si on est pas owner
    if([imagesBoutons count] > 1)
    {
        CGRect buttonFrame = CGRectMake(0, 0, 40.0f, 40.0f);
        self.firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.firstButton setFrame:buttonFrame];
        [self.firstButton setImage:imagesBoutons[1] forState:UIControlStateNormal];
        [self.firstButton addTarget:delegate action:@selector(clicRespond:) forControlEvents:UIControlEventTouchUpInside];
        self.firstButton.contentMode = UIViewContentModeScaleAspectFit;
        self.secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.secondButton setImage:imagesBoutons[2] forState:UIControlStateNormal];
        [self.secondButton setFrame:buttonFrame];
        [self.secondButton addTarget:delegate action:@selector(clicRespond:) forControlEvents:UIControlEventTouchUpInside];
        self.secondButton.contentMode = UIViewContentModeScaleAspectFit;
        NSArray *buttons = @[self.firstButton, self.secondButton];
        
        /* ---------------------------------------------------------
         * Init method, passing everything the bar needs to work
         * -------------------------------------------------------*/
        self = [self initWithImage:image withButtons:buttons center:center frame:CGRectMake(0, 0, background.frame.size.width, background.frame.size.height)];
        
        if(self) {
            startPositionExpandingButton = background.frame.origin.y + 18;
            heightExpandingButton = 97;
            
            [self addSubview:self.fondBlanc];
            [self addSubview:background];
            [self sendSubviewToBack:background];
            [self sendSubviewToBack:self.secondButton];
            [self sendSubviewToBack:self.firstButton];
            [self sendSubviewToBack:self.fondBlanc];
            [self setDelegate:delegate];
        }
        
    }
    else
    {
        self = [super initWithFrame:CGRectMake(265, 86, 40, 40)];
        if(self) {
            startPositionExpandingButton = background.frame.origin.y + 18;
            heightExpandingButton = 97;
            
            CGRect frameStylo = CGRectMake(0, 0, image.size.width, image.size.height);
            frameStylo.origin.x = (background.frame.size.width - frameStylo.size.width)/2.0;
            frameStylo.origin.y = (background.frame.size.height - frameStylo.size.height)/2.0;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:image forState:UIControlStateNormal];
            [button setFrame:frameStylo];
            [button addTarget:delegate action:@selector(clicEdit) forControlEvents:UIControlEventTouchUpInside];
            [button setContentMode:UIViewContentModeScaleAspectFit];
            
            [self addSubview:self.fondBlanc];
            [self addSubview:background];
            [self addSubview:button];
        }
    }
    
    return self;
}

- (void) setDefaults
{
    [super setDefaults];
    
    [self setSpin:NO];
    [self setFar:10.0f];
    [self setNear:5.0f];
    [self setPadding:2.0f];
}

- (void)showButtonsAnimated:(BOOL)animated {
    
    CGRect frame = self.fondBlanc.frame;
    frame.origin.y = startPositionExpandingButton - heightExpandingButton;
    frame.size.height = heightExpandingButton;
    
    [UIView animateWithDuration:0.45 animations:^{
        self.fondBlanc.frame = frame;
    }];
    
    [super showButtonsAnimated:animated];
    _isShowed = YES;
}

- (void)hideButtonsAnimated:(BOOL)animated {
    
    CGRect frame = self.fondBlanc.frame;
    frame.origin.y = startPositionExpandingButton;
    frame.size.height = 0;
    
    [UIView animateWithDuration:0.75 animations:^{
        self.fondBlanc.frame = frame;
    }];
    
    [super hideButtonsAnimated:animated];
    _isShowed = NO;
}

@end
