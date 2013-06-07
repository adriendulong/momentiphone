//
//  TimeLineCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 12/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "TimeLineCell.h"

@implementation TimeLineCell

@synthesize timeLineDelegate = _timeLineDelegate;
@synthesize moment = _moment;
@synthesize row = _row;
@synthesize medallion = _medallion;
@synthesize titre = _titre;
@synthesize centerView = _centerView;

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.2, 0.2);
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.5;
    view.layer.masksToBounds  = NO;
}

- (id)initWithMoment:(MomentClass*)param
        withDelegate:(id <TimeLineDelegate>)delegate
             withRow:(NSInteger)row
     reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        // Init
        self.moment = param;
        self.timeLineDelegate = delegate;
        self.row = row;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"TimeLineCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setUserInteractionEnabled:YES];
        
        // Centrer en fonction de la taille
        CGRect frame = self.centerView.frame;
        frame.origin.x = (self.timeLineDelegate.size.width - frame.size.width)/2.0;
        self.centerView.frame = frame;
                
        // Titre
        self.titre.text = self.moment.titre;
        [self addShadowToView:self.titre];
        
        // Image
        self.medallion.borderWidth = 1.5;
        self.medallion.defaultStyle = MedallionStyleCover;
        __weak TimeLineCell *dp = self;
        [self.medallion addTarget:self action:@selector(medallionClic) forControlEvents:UIControlEventTouchUpInside];
        [self.medallion setImage:self.moment.uimage imageString:self.moment.imageString withSaveBlock:^(UIImage *image) {
            [dp.moment setUimage:image];
        }];
        
    }
    return self;
}

- (void)medallionClic {
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Timeline"
     withAction:@"Clic Bouton"
     withLabel:@"Clic Grossissement"
     withValue:nil];
    
    //NSLog(@"clic on button %d with moment %d", button.tag, self.moment.momentId);
    [self.timeLineDelegate updateSelectedMoment:self.moment atRow:self.row];
}

- (void)willDisappear {
    
    //CGRect frame = self.frame;
    //frame.origin.y += frame.size.height/1.5;
    
    /*
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        //self.frame = frame;
    }];
    */
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0;
    } completion:nil];
    
    
    
    /*
    [UIView beginAnimations:@"TimeLineCellWillDisappear" context:nil];
    //self.transform = CGAffineTransformScale(self.transform, 1.3, 1.3);
    self.alpha = 0;
    //self.transform = CGAffineTransformMakeScale(1.5 , 1.5);
    [UIView commitAnimations];
    */
    
}

@end
